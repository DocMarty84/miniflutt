import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/nav.dart';

class MySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Data>(context, listen: false);
    final nav = Provider.of<Nav>(context, listen: false);
    final color = Theme.of(context).primaryTextTheme.title.color;
    return Scaffold(
      appBar: AppBar(
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
          onSubmitted: (value) {
            data.refresh(search: value);
            nav.set(null, null, value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
