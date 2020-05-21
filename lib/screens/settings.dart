import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
// This class holds data related to the form.
class MySettingsFormState extends State<MySettingsForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MySettingsFormState>.
  final _formKey = GlobalKey<FormState>();
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

  Future<Map<String, dynamic>> _connectCheck(String url, String apiKey) async {
    final _statusCodes = {
      200: 'Everything is OK',
      201: 'Resource created/modified',
      204: 'Resource removed/modified',
      400: 'Bad request',
      401: 'Unauthorized (bad username/password)',
      403: 'Forbidden (access not allowed)',
      500: 'Internal server error',
    };

    try {
      final res =
          await http.get(url + '/v1/me', headers: {'X-Auth-Token': apiKey});
      return {
        'code': res.statusCode,
        'error': _statusCodes.containsKey(res.statusCode)
            ? _statusCodes[res.statusCode]
            : res.reasonPhrase
      };
    } catch (e) {
      return {'code': 500, 'error': e.toString()};
    }
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(
          'url', _urlController.text.replaceAll(RegExp(r"/+$"), ''));
      prefs.setString('apiKey', _apiKeyController.text);
      prefs.setString('limit', _limitController.text);
    });
  }

  // Clear preferences
  void _clearPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('url');
    prefs.remove('apiKey');
    setState(() {
      _urlController.text = 'http://';
      _apiKeyController.text = '';
    });
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
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'Server URL'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the URL';
                } else if (!value
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
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an API key';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _limitController,
              decoration: InputDecoration(
                  labelText: 'Max Number Of Entries (0: Unlimited)'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a number';
                }
                try {
                  int.parse(value);
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
                          final res = await _connectCheck(
                              _urlController.text, _apiKeyController.text);
                          if (res['code'] == 200) {
                            _savePref();
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Connection successful!')));
                          } else {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text(res['error'])));
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
          ],
        ),
      ),
    );
  }
}
