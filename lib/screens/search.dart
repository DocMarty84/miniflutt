import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/data.dart';
import '../models/nav.dart';

class MySearchAppBar extends StatelessWidget with PreferredSizeWidget {
  MySearchAppBar({Key key, @required this.data, @required this.nav})
      : super(key: key);
  final Data data;
  final Nav nav;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.headline6.color;
    return AppBar(
      title: TextField(
        autofocus: true,
        style: TextStyle(color: color),
        decoration: InputDecoration(
          hintText: 'Search for...',
          hintStyle: TextStyle(color: color),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
        ),
        onSubmitted: (value) async {
          data.refresh(search: value);
          nav.set(null, null, value);
          Navigator.pop(context);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final List<String> history =
              (prefs.getStringList('history') ?? <String>[]);
          history.remove(value);
          history.insert(0, value);
          prefs.setStringList('history', history);
        },
      ),
    );
  }
}

// Create a Form widget.
class MySearchHistory extends StatefulWidget {
  MySearchHistory({Key key, @required this.data, @required this.nav})
      : super(key: key);
  final Data data;
  final Nav nav;

  @override
  MySearchHistoryState createState() {
    return MySearchHistoryState(data: data, nav: nav);
  }
}

class MySearchHistoryState extends State<MySearchHistory> {
  MySearchHistoryState({Key key, @required this.data, @required this.nav});
  final Data data;
  final Nav nav;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  // Load preferences
  void _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = (prefs.getStringList('history') ?? _history);
    });
  }

  List<Widget> _buildHistory() {
    return _history.map<Widget>((item) {
      return ListTile(
        title: Text(item),
        leading: Icon(Icons.history),
        onTap: () {
          data.refresh(search: item);
          nav.set(null, null, item);
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
            ListTile(
              title: Text('Clear history'),
              leading: Icon(Icons.delete),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.remove('history');
                setState(() => _history = []);
              },
            ),
          ] +
          _buildHistory(),
    );
  }
}

class MySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Data>(context, listen: false);
    final nav = Provider.of<Nav>(context, listen: false);
    return Scaffold(
      appBar: MySearchAppBar(data: data, nav: nav),
      body: MySearchHistory(data: data, nav: nav),
    );
  }
}
