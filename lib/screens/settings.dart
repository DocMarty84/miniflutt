import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/miniflux.dart';
import '../models/data.dart';
import '../models/data_all.dart';
import '../models/nav.dart';

class MySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
        ),
      ),
      body: MySettingsForm(),
    );
  }
}

// Create a Form widget.
class MySettingsForm extends StatefulWidget {
  @override
  MySettingsFormState createState() {
    return MySettingsFormState();
  }
}

// Create a corresponding State class.
class MySettingsFormState extends State<MySettingsForm> {
  final _formKey = GlobalKey<FormState>();

  // Since the initial values are loaded asynchronously, setting the value in a
  // String won't work. Indeed, the initState cannot be delayed with an async.
  // The solution is to use a controller.
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _urlController.dispose();
    _apiKeyController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<http.Response> _connectCheck(String url, String apiKey) async {
    return await http.get(url + '/v1/me', headers: {'X-Auth-Token': apiKey});
  }

  // Load preferences
  void _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = (prefs.getString('url') ?? 'http://');
      _apiKeyController.text = (prefs.getString('apiKey') ?? '');
      _limitController.text = (prefs.getString('limit') ?? '500');
    });
  }

  // Save preferences
  void _savePref() async {
    // First save preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(
          'url', _urlController.text.replaceAll(RegExp(r"/+$"), ''));
      prefs.setString('apiKey', _apiKeyController.text);
      prefs.setString('limit', _limitController.text);
    });

    // Then refresh to populate the interface
    final data = Provider.of<Data>(context, listen: false);
    final nav = Provider.of<Nav>(context, listen: false);
    data.refresh();
    nav.set(null, null, 'All');
  }

  // Clear preferences
  void _clearPref() async {
    // First remove preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    setState(() {
      _urlController.text = 'http://';
      _apiKeyController.text = '';
      _limitController.text = '500';
    });

    // Then refresh to clean-up the interface
    final data = Provider.of<Data>(context, listen: false);
    final nav = Provider.of<Nav>(context, listen: false);
    data.refresh();
    nav.set(null, null, 'All');
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
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
              controller: _urlController,
              decoration: InputDecoration(labelText: 'Server URL'),
              keyboardType: TextInputType.url,
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
              controller: _apiKeyController,
              decoration: InputDecoration(labelText: 'API Key'),
              obscureText: true,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Please enter an API key';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _limitController,
              decoration: InputDecoration(
                  labelText: 'Max Number Of Entries (0: Unlimited)'),
              keyboardType: TextInputType.number,
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
                    RaisedButton(
                      child: Text('Save'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            final res = await _connectCheck(
                                _urlController.text, _apiKeyController.text);
                            if (res.statusCode == 200) {
                              _savePref();
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Connection successful!')));
                            } else {
                              throw Exception(makeError('Failed to connect!',
                                  res, '/v1/me', <String, dynamic>{}));
                            }
                          } catch (e) {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to connect!')));
                          }
                        }
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    new RaisedButton(
                      child: Text("Log Out"),
                      onPressed: () {
                        _clearPref();
                      },
                    ),
                  ],
                ),
              ),
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
    );
  }
}
