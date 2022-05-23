import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/miniflux.dart';
import '../models/data_all.dart';
import '../models/entry_style.dart';
import '../models/settings.dart';
import '../models/theme_mode_item.dart';
import '../models/theme_settings.dart';

class MySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
        ),
      ),
      body: Consumer2<Settings, ThemeSettings>(
        builder: (context, settings, themeSettings, child) {
          if (settings.isLoad) {
            return CircularProgressIndicator();
          } else {
            return MySettingsForm(settings: settings, themeSettings: themeSettings);
          }
        },
      ),
    );
  }
}

// Create a Form widget.
class MySettingsForm extends StatefulWidget {
  MySettingsForm({Key key, @required this.settings, @required this.themeSettings}) : super(key: key);
  final Settings settings;
  final ThemeSettings themeSettings;

  @override
  MySettingsFormState createState() {
    return MySettingsFormState(settings: settings, themeSettings: themeSettings);
  }
}

// Create a corresponding State class.
class MySettingsFormState extends State<MySettingsForm> {
  MySettingsFormState({Key key, @required this.settings, @required this.themeSettings});

  final Settings settings;
  final ThemeSettings themeSettings;

  final _formKey = GlobalKey<FormState>();
  final _actionsEntry = <DropdownMenuItem>[
    DropdownMenuItem(
      child: Text('Do nothing'),
      value: 'no',
    ),
    DropdownMenuItem(
      child: Text('Mark as read/unread'),
      value: 'read',
    ),
    DropdownMenuItem(
      child: Text('Mark as favorite'),
      value: 'favorite',
    ),
  ];
  final _actionsFeed = <DropdownMenuItem>[
    DropdownMenuItem(
      child: Text('Do nothing'),
      value: 'no',
    ),
    DropdownMenuItem(
      child: Text('Mark as read/unread'),
      value: 'read',
    ),
  ];
  final _fontSize = <DropdownMenuItem>[
    DropdownMenuItem(
      child: Text('Small'),
      value: 'small',
    ),
    DropdownMenuItem(
      child: Text('Medium'),
      value: 'medium',
    ),
    DropdownMenuItem(
      child: Text('Large'),
      value: 'large',
    ),
    DropdownMenuItem(
      child: Text('XLarge'),
      value: 'xlarge',
    ),
  ];

  Future<http.Response> _connectCheck(String url, String apiKey) async {
    return await http
        .get(Uri.parse(url + '/v1/me'), headers: {'X-Auth-Token': apiKey});
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Server',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.all(0.0),
              ),
              TextFormField(
                initialValue: settings.url,
                decoration: InputDecoration(labelText: 'Server URL'),
                keyboardType: TextInputType.url,
                onSaved: (val) {
                  setState(() => settings.url = val);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please enter the URL';
                  } else if (!val
                      .toLowerCase()
                      .startsWith(new RegExp(r'^https?://'))) {
                    return 'The URL must start with \'http(s)://\'';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: settings.apiKey,
                decoration: InputDecoration(labelText: 'API Key'),
                obscureText: true,
                onSaved: (val) {
                  setState(() => settings.apiKey = val);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please enter an API key';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: settings.limit,
                decoration: InputDecoration(
                    labelText: 'Max Number Of Entries (0: Unlimited)'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  setState(() => settings.limit = val);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please enter a number';
                  }
                  try {
                    int.parse(val);
                  } catch (e) {
                    return 'Please enter a number';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () async {
                          final FormState form = _formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            try {
                              final res = await _connectCheck(
                                  settings.url, settings.apiKey);
                              if (res.statusCode == 200) {
                                settings.save(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Connection successful!')));
                              } else {
                                throw Exception(makeError('Failed to connect!',
                                    res, '/v1/me', <String, dynamic>{}));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Failed to connect!')));
                            }
                          }
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      new ElevatedButton(
                        child: Text("Log Out"),
                        onPressed: () => settings.clear(context),
                      ),
                    ],
                  ),
                ),
              ),
              _createSectionHeader('User Actions in Lists'),
              Row(children: <Widget>[
                Expanded(
                    child: Text('Mark entries read on scroll',
                        textAlign: TextAlign.left)),
                Switch(
                  value: settings.markReadOnScroll,
                  onChanged: (val) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("markReadOnScroll", val);
                    setState(() => settings.markReadOnScroll = val);
                  },
                ),
              ]),
              DropdownButtonFormField(
                value: settings.entryOnLongPress,
                items: _actionsEntry,
                decoration: InputDecoration(labelText: 'Long press on article'),
                onChanged: (val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entryOnLongPress', val);
                  setState(() => settings.entryOnLongPress = val);
                },
              ),
              DropdownButtonFormField(
                value: settings.entrySwipeLeft,
                items: _actionsEntry,
                decoration: InputDecoration(labelText: 'Swipe left on article'),
                onChanged: (val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entrySwipeLeft', val);
                  setState(() => settings.entrySwipeRight = val);
                },
              ),
              DropdownButtonFormField(
                value: settings.entrySwipeRight,
                items: _actionsEntry,
                decoration:
                    InputDecoration(labelText: 'Swipe right on article'),
                onChanged: (val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('entrySwipeRight', val);
                  setState(() => settings.entrySwipeRight = val);
                },
              ),
              DropdownButtonFormField(
                value: settings.feedOnLongPress,
                items: _actionsFeed,
                decoration: InputDecoration(labelText: 'Long press on feed'),
                onChanged: (val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('feedOnLongPress', val);
                  setState(() => settings.feedOnLongPress = val);
                },
              ),
              _createSectionHeader('App Style'),
              _createThemeModeSelectorWidget(),
              _createSectionHeader('Article Style'),
              DropdownButtonFormField(
                value: settings.fontSize,
                items: _fontSize,
                decoration: InputDecoration(labelText: 'Font size'),
                onChanged: (val) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('fontSize', val);
                  final entryStyle =
                      Provider.of<EntryStyle>(context, listen: false);
                  entryStyle.refresh();
                  setState(() => settings.fontSize = val);
                },
              ),
              _createSectionHeader('Categories and feeds', onTap: () {
                final dataAll = Provider.of<DataAll>(context, listen: false);
                dataAll.refresh();
                Navigator.pushNamed(context, '/feeds');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSectionHeader(final String title,
          {final GestureTapCallback onTap}) =>
      ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        contentPadding: EdgeInsets.all(0.0),
        onTap: onTap,
      );

  Widget _createThemeModeSelectorWidget() {
    DropdownMenuItem<ThemeMode> _asDropdownMenuItem(final ThemeModeItem item) =>
        DropdownMenuItem(child: Text(item.displayName), value: item.themeMode);

    final options = availableThemeModeItems()
        .map((item) => _asDropdownMenuItem(item))
        .toList(growable: false);

    final selection = themeSettings.themeMode;

    return DropdownButtonFormField(
      items: options,
      value: selection,
      decoration: InputDecoration(labelText: 'Theme Mode'),
      onChanged: (themeMode) async {
        setState(() => themeSettings.registerThemeModePreference(themeMode));
      },
    );
  }
}
