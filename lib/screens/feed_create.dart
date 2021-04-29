import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/miniflux.dart';
import '../models/data_all.dart';

// Create a Form widget for update and delete
class MyFeedFormCreate extends StatefulWidget {
  @override
  MyFeedFormCreateState createState() {
    return MyFeedFormCreateState();
  }
}

class MyFeedFormCreateState extends State<MyFeedFormCreate> {
  final _formKey = GlobalKey<FormState>();
  String _feedUrl;
  int _categoryId;
  String _username;
  String _password;
  bool _crawler;
  String _userAgent;
  String _scraperRules;
  String _rewriteRules;

  @override
  Widget build(BuildContext context) {
    final dataAll = Provider.of<DataAll>(context, listen: false);
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Feed URL *'),
                keyboardType: TextInputType.url,
                onSaved: (val) {
                  setState(() => _feedUrl = val);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'The feed URL is mandatory';
                  } else if (!val
                      .toLowerCase()
                      .startsWith(new RegExp(r'^https?://'))) {
                    return 'The URL must start with \'http(s)://\'';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                value: _categoryId,
                items: dataAll.categories
                    .map((category) => DropdownMenuItem(
                          child: Text(category.title),
                          value: category.id,
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Category *'),
                validator: (val) {
                  if (val == null) {
                    return 'The category is mandatory';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => _categoryId = value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Feed Username'),
                onSaved: (val) {
                  setState(() => _username = val);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Feed Password'),
                obscureText: true,
                onSaved: (val) {
                  setState(() => _password = val);
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Override Default User Agent'),
                onSaved: (val) {
                  setState(() => _userAgent = val);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Scraper Rules'),
                onSaved: (val) {
                  setState(() => _scraperRules = val);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Rewrite Rules'),
                onSaved: (val) {
                  setState(() => _rewriteRules = val);
                },
              ),
              DropdownButtonFormField(
                value: (_crawler ?? false),
                items: [
                  DropdownMenuItem(child: Text('Yes'), value: true),
                  DropdownMenuItem(child: Text('No'), value: false),
                ],
                decoration:
                    InputDecoration(labelText: 'Fetch original content'),
                onChanged: (value) {
                  setState(() => _crawler = value);
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
                            Map<String, dynamic> params = {
                              'feed_url': _feedUrl,
                              'category_id': _categoryId,
                              'scraper_rules': _scraperRules,
                              'rewrite_rules': _rewriteRules,
                              'crawler': _crawler,
                              'username': _username,
                              'password': _password,
                              'user_agent': _userAgent,
                            };
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saving...')));
                              await createFeed(params);
                              dataAll.refresh();
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('An error occured!\n$e')));
                            }
                          }
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

class MyFeedCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New feed')),
      body: MyFeedFormCreate(),
    );
  }
}
