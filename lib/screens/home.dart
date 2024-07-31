import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import '../models/data.dart';
import '../models/entry.dart';
import '../models/nav.dart';

// Filter entries based on the navigation info
List<Entry?> filterEntries(Data data, Nav nav) {
  List<Entry?> entries = [];
  if (nav.currentCategoryId != null) {
    entries = data.entries
        .where((i) => i!.feed!.category!.id == nav.currentCategoryId)
        .toList();
  } else if (nav.currentFeedId != null) {
    entries =
        data.entries.where((i) => i!.feedId == nav.currentFeedId).toList();
  } else {
    entries = data.entries
        .where((i) =>
            i!.feed!.hideGlobally == false &&
            i.feed!.category!.hideGlobally == false)
        .toList();
  }
  return entries;
}

// Implements the action buttons in a widget to display an 'Undo' action in a
// snackbar.
// See https://medium.com/@ksheremet/flutter-showing-snackbar-within-the-widget-that-builds-a-scaffold-3a817635aeb2
class MyHomeMarkRead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done_all),
      onPressed: () async {
        final nav = Provider.of<Nav>(context, listen: false);
        final data = Provider.of<Data>(context, listen: false);
        final entryIds = filterEntries(data, nav)
            .where((entry) => entry!.status == 'unread')
            .map((entry) => entry!.id)
            .toList();
        final snackBar = SnackBar(
          content: Text('${entryIds.length} item(s) mark read'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              data.unread(entryIds);
            },
          ),
        );
        try {
          await data.read(entryIds);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('An error occured!\n$e')));
        }
      },
    );
  }
}

class MyHomePopupMenu extends StatefulWidget {
  @override
  MyHomePopupMenuState createState() {
    return MyHomePopupMenuState();
  }
}

class MyHomePopupMenuState extends State<MyHomePopupMenu> {
  late bool _read;
  late bool _asc;
  late bool _starred;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  // Load preferences
  void _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _read = (prefs.getBool('read') ?? false);
      _asc = (prefs.getBool('asc') ?? false);
      _starred = (prefs.getBool('starred') ?? false);
    });
  }

  // Save preferences
  void _savePref(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (value == 'read') {
        prefs.setBool('read', !_read);
        _read = !_read;
      } else if (value == 'asc') {
        prefs.setBool('asc', !_asc);
        _asc = !_asc;
      } else if (value == 'star') {
        prefs.setBool('starred', !_starred);
        _starred = !_starred;
      }
    });
    final data = Provider.of<Data>(context, listen: false);
    data.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: _savePref,
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> list = [];
        list.add(
          CheckedPopupMenuItem(
            child: Text(
              'Get read articles',
            ),
            value: 'read',
            checked: _read,
          ),
        );
        list.add(
          CheckedPopupMenuItem(
            child: Text(
              'Oldest first',
            ),
            value: 'asc',
            checked: _asc,
          ),
        );
        list.add(
          CheckedPopupMenuItem(
            child: Text(
              'Favorites',
            ),
            value: 'star',
            checked: _starred,
          ),
        );
        return list;
      },
    );
  }
}

class MyHomeEntryList extends StatelessWidget {
  MyHomeEntryList({Key? key, required this.data, required this.nav})
      : super(key: key);
  final Data data;
  final Nav nav;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // Mark entries as read when scrolling
  void _markReadOnScroll(List<Entry?> entries) {
    int topItemIndex = itemPositionsListener.itemPositions.value.first.index;
    if (topItemIndex > 1) {
      List<Entry?> scrolledPastEntries = entries.sublist(0, topItemIndex ~/ 2);
      List<int?> entryIds = scrolledPastEntries
          .where((entry) => entry!.status == 'unread')
          .map((entry) => entry!.id)
          .toList();

      // Workaround for the following behavior:
      // - Go to feed A, scroll a few items
      // - Go to feed B
      // => feed B is already scrolled and items are set to read.
      if (entryIds.length == 1) {
        data.read(entryIds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Entry?> entries = filterEntries(data, nav);
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    // Listener for marking entries as read on scroll
    itemPositionsListener.itemPositions.addListener(() async {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool("markReadOnScroll") ?? false) {
        _markReadOnScroll(entries);
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        data.refresh();
      },
      child: ScrollablePositionedList.builder(
        itemCount: entries.length * 2,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final Entry entry = entries[i ~/ 2]!;
          return GestureDetector(
            child: ListTile(
              title: Text(
                '${entry.title}',
                style: TextStyle(
                  color: (entry.status == 'unread'
                      ? null
                      : Theme.of(context).disabledColor),
                  fontStyle: (entry.status == 'unread'
                      ? FontStyle.normal
                      : FontStyle.italic),
                ),
              ),
              subtitle: Row(children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (nav.currentFeedId == null) Text(entry.feed!.title!),
                    Row(children: <Widget>[
                      Text(
                          DateFormat('yyy-MM-dd HH:mm')
                              .format(DateTime.parse(entry.publishedAt!))
                          
                      ),
                      Text(
                        ' :: ${entry.readingTime} min read',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]),
                  ]),
                  if (entry.starred!) Spacer(),
                  if (entry.starred!) Icon(Icons.star, color: Colors.amber),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/entry',
                  arguments: entry,
                );
                final List<int?> entryIds = [entry.id];
                data.read(entryIds);
              },
              onLongPress: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String entryOnLongPress =
                    (prefs.getString('entryOnLongPress') ?? 'read');
                if (entryOnLongPress == 'read') {
                  final List<int?> entryIds = [entry.id];
                  entry.status == 'unread'
                      ? data.read(entryIds)
                      : data.unread(entryIds);
                } else if (entryOnLongPress == 'favorite') {
                  data.toggleStar(entry.id);
                }
              },
            ),
            onHorizontalDragEnd: (details) async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              String? entrySwipe;
              if (details.velocity.pixelsPerSecond.dx < 0) {
                entrySwipe = (prefs.getString('entrySwipeLeft') ?? 'no');
              } else if (details.velocity.pixelsPerSecond.dx > 0) {
                entrySwipe = (prefs.getString('entrySwipeRight') ?? 'no');
              }

              if (entrySwipe == 'read') {
                final List<int?> entryIds = [entry.id];
                entry.status == 'unread'
                    ? data.read(entryIds)
                    : data.unread(entryIds);
              } else if (entrySwipe == 'favorite') {
                data.toggleStar(entry.id);
              }
            },
          );
        },
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<Nav>(
          builder: (context, nav, child) {
            return Text(nav.appBarTitle!);
          },
        ),
        // action button
        actions: <Widget>[
          MyHomePopupMenu(),
        ],
      ),
      body: Center(
        child: Consumer2<Data, Nav>(
          builder: (context, data, nav, child) {
            if (data.isRefresh) {
              return CircularProgressIndicator();
            } else {
              // By default, show a loading spinner.
              return MyHomeEntryList(data: data, nav: nav);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Spacer(),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
            MyHomeMarkRead(),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
