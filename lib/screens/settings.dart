import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/accounts.dart';
import '../models/entry_style.dart';
import '../models/data_all.dart';
import '../models/settings.dart';

class MySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Consumer<Settings>(
        builder: (context, settings, child) {
          if (settings.isLoad) {
            return CircularProgressIndicator();
          } else {
            return MySettingsForm(settings: settings);
          }
        },
      ),
    );
  }
}

// Create a Form widget.
class MySettingsForm extends StatefulWidget {
  MySettingsForm({Key? key, required this.settings}) : super(key: key);
  final Settings settings;

  @override
  MySettingsFormState createState() {
    return MySettingsFormState(settings: settings);
  }
}

// Create a corresponding State class.
class MySettingsFormState extends State<MySettingsForm> {
  MySettingsFormState({Key? key, required this.settings});
  final Settings settings;

  final _formKey = GlobalKey<FormState>();
  final _actionsEntry = <DropdownMenuItem>[
    DropdownMenuItem(child: Text('Do nothing'), value: 'no'),
    DropdownMenuItem(child: Text('Mark as read/unread'), value: 'read'),
    DropdownMenuItem(child: Text('Mark as favorite'), value: 'favorite'),
    DropdownMenuItem(
      child: Text('Save to third-party services'),
      value: 'save',
    ),
  ];
  final _actionsFeed = <DropdownMenuItem>[
    DropdownMenuItem(child: Text('Do nothing'), value: 'no'),
    DropdownMenuItem(child: Text('Mark as read/unread'), value: 'read'),
  ];
  final _fontSize = <DropdownMenuItem>[
    DropdownMenuItem(child: Text('Small'), value: 'small'),
    DropdownMenuItem(child: Text('Medium'), value: 'medium'),
    DropdownMenuItem(child: Text('Large'), value: 'large'),
    DropdownMenuItem(child: Text('XLarge'), value: 'xlarge'),
  ];

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          // Keep the last fields above the navigation bar
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Accounts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.all(0.0),
              ),
              Consumer<Accounts>(
                builder: (context, accounts, child) {
                  return Column(
                    children:
                        accounts.accounts.map<Widget>((account) {
                          return ListTile(
                            title: Text(account.label),
                            trailing: account.id == accounts.activeId
                                ? Icon(Icons.check)
                                : null,
                            contentPadding: EdgeInsets.all(0.0),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/account',
                                arguments: account,
                              );
                            },
                          );
                        }).toList() +
                        <Widget>[
                          ListTile(
                            title: Text('Add account'),
                            trailing: Icon(Icons.add),
                            contentPadding: EdgeInsets.all(0.0),
                            onTap: () {
                              Navigator.pushNamed(context, '/account');
                            },
                          ),
                        ],
                  );
                },
              ),
              ListTile(
                title: Text(
                  'User Actions in Lists',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.all(0.0),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Mark entries read on scroll',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Switch(
                    value: settings.markReadOnScroll,
                    onChanged: (val) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("markReadOnScroll", val);
                      setState(() => settings.markReadOnScroll = val);
                    },
                  ),
                ],
              ),
              DropdownButtonFormField(
                initialValue: settings.entryOnLongPress,
                items: _actionsEntry,
                decoration: InputDecoration(labelText: 'Long press on article'),
                onChanged: (dynamic val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entryOnLongPress', val);
                  setState(() => settings.entryOnLongPress = val);
                },
              ),
              DropdownButtonFormField(
                initialValue: settings.entrySwipeLeft,
                items: _actionsEntry,
                decoration: InputDecoration(labelText: 'Swipe left on article'),
                onChanged: (dynamic val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entrySwipeLeft', val);
                  setState(() => settings.entrySwipeLeft = val);
                },
              ),
              DropdownButtonFormField(
                initialValue: settings.entrySwipeRight,
                items: _actionsEntry,
                decoration: InputDecoration(
                  labelText: 'Swipe right on article',
                ),
                onChanged: (dynamic val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entrySwipeRight', val);
                  setState(() => settings.entrySwipeRight = val);
                },
              ),
              DropdownButtonFormField(
                initialValue: settings.feedOnLongPress,
                items: _actionsFeed,
                decoration: InputDecoration(labelText: 'Long press on feed'),
                onChanged: (dynamic val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('feedOnLongPress', val);
                  setState(() => settings.feedOnLongPress = val);
                },
              ),
              ListTile(
                title: Text(
                  'Article Style',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.all(0.0),
              ),
              DropdownButtonFormField(
                initialValue: settings.fontSize,
                items: _fontSize,
                decoration: InputDecoration(labelText: 'Font size'),
                onChanged: (dynamic val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('fontSize', val);
                  final entryStyle = Provider.of<EntryStyle>(
                    context,
                    listen: false,
                  );
                  entryStyle.refresh();
                  setState(() => settings.fontSize = val);
                },
              ),
              ListTile(
                title: Text(
                  'Categories and feeds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.all(0.0),
                onTap: () {
                  final dataAll = Provider.of<DataAll>(context, listen: false);
                  dataAll.refresh();
                  Navigator.pushNamed(context, '/feeds');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
