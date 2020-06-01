import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/miniflux.dart';
import '../models/category.dart';
import '../models/data_all.dart';

// Create a Form widget for update and delete
class MyCategoryForm extends StatefulWidget {
  MyCategoryForm({Key key, @required this.category}) : super(key: key);
  final Category category;

  @override
  MyCategoryFormState createState() {
    return MyCategoryFormState(category: category);
  }
}

class MyCategoryFormState extends State<MyCategoryForm> {
  MyCategoryFormState({Key key, @required this.category});
  final Category category;

  final _formKey = GlobalKey<FormState>();
  String _title;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  // Load preferences
  void _loadValues() {
    setState(() {
      _title = category == null ? '' : category.title;
    });
  }

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
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title *'),
                onSaved: (val) {
                  setState(() => _title = val);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please enter the title';
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
                          final FormState form = _formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            Map<String, dynamic> params = {
                              'title': _title,
                            };
                            try {
                              if (category != null) {
                                await updateCategory(category.id, params);
                                dataAll.refresh();
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text('Changes saved!')));
                              } else {
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text('Saving...')));
                                await createCategory(params);
                                dataAll.refresh();
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('An error occured!\n$e')));
                            }
                          }
                        },
                      ),
                      category == null
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 10,
                            ),
                      category == null
                          ? SizedBox.shrink()
                          : RaisedButton(
                              color: Theme.of(context).errorColor,
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6
                                        .color),
                              ),
                              onPressed: () async {
                                try {
                                  await deleteCategory(category.id);
                                  dataAll.refresh();
                                  Navigator.pop(context);
                                } catch (e) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text('An error occured!\n$e')));
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

class MyCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Category category = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
          title: Text(category == null ? 'New category' : category.title)),
      body: MyCategoryForm(category: category),
    );
  }
}
