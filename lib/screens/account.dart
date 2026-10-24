import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/miniflux.dart';
import '../models/account.dart';
import '../models/accounts.dart';

// Create a Form widget for creation, update and removal
class MyAccountForm extends StatefulWidget {
  MyAccountForm({Key? key, required this.account}) : super(key: key);
  final Account? account;

  @override
  MyAccountFormState createState() {
    return MyAccountFormState(account: account);
  }
}

class MyAccountFormState extends State<MyAccountForm> {
  MyAccountFormState({Key? key, required this.account});
  final Account? account;

  final _formKey = GlobalKey<FormState>();
  String? _url;
  String? _apiKey;
  String? _limit;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  // Load values
  void _loadValues() {
    setState(() {
      _url = account == null ? 'http://' : account!.url;
      _apiKey = account == null ? '' : account!.apiKey;
      _limit = account == null ? '500' : account!.limit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = Provider.of<Accounts>(context, listen: false);
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
              TextFormField(
                initialValue: _url,
                decoration: InputDecoration(labelText: 'Server URL'),
                keyboardType: TextInputType.url,
                onSaved: (val) {
                  setState(() => _url = val);
                },
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter the URL';
                  } else if (!val.toLowerCase().startsWith(
                    new RegExp(r'^https?://'),
                  )) {
                    return 'The URL must start with \'http(s)://\'';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _apiKey,
                decoration: InputDecoration(labelText: 'API Key'),
                obscureText: true,
                onSaved: (val) {
                  setState(() => _apiKey = val);
                },
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter an API key';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _limit,
                decoration: InputDecoration(
                  labelText: 'Max Number Of Entries (0: Unlimited)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  setState(() => _limit = val);
                },
                validator: (val) {
                  if (val!.isEmpty) {
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
                          final FormState form = _formKey.currentState!;
                          if (form.validate()) {
                            form.save();
                            final Account newAccount = Account(
                              id: account?.id,
                              url: _url!.replaceAll(RegExp(r"/+$"), ''),
                              apiKey: _apiKey!,
                              limit: _limit!,
                            );
                            try {
                              // Check the connection before saving, and get
                              // the username to tell the accounts apart
                              final Map<String, dynamic> user = json.decode(
                                await getCurrentUser(account: newAccount),
                              );
                              newAccount.username = user['username'];
                              await accounts.save(newAccount, context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Connection successful!'),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to connect!\n'
                                    'Local server? Allow \'Nearby '
                                    'devices\' in Android settings.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      account == null ? SizedBox.shrink() : SizedBox(width: 10),
                      account == null
                          ? SizedBox.shrink()
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.error,
                                ),
                              ),
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).primaryTextTheme.titleLarge!.color,
                                ),
                              ),
                              onPressed: () async {
                                await accounts.remove(account!.id, context);
                                Navigator.pop(context);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Account? account =
        ModalRoute.of(context)!.settings.arguments as Account?;
    return Scaffold(
      appBar: AppBar(
        title: Text(account == null ? 'New account' : account.label),
      ),
      body: MyAccountForm(account: account),
    );
  }
}
