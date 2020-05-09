import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/entry.dart';

class MyEntry extends StatelessWidget {
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildHeader(Entry entry, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            entry.title,
            textScaleFactor: 1.25,
            style: TextStyle(
              color: Theme.of(context).textTheme.title.color,
              fontWeight: Theme.of(context).textTheme.title.fontWeight,
            ),
          ),
          Divider(
            thickness: 1.0,
            color: Theme.of(context).textTheme.title.color,
          ),
          RichText(
            textScaleFactor: 0.75,
            text: TextSpan(
              style:
                  TextStyle(color: Theme.of(context).textTheme.subtitle.color),
              children: <TextSpan>[
                TextSpan(text: 'by '),
                TextSpan(
                    text: entry.author,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ', ' + Uri.parse(entry.url).host)
              ],
            ),
          ),
          Text(
            DateFormat.yMEd()
                .add_jm()
                .format(DateTime.parse(entry.publishedAt)),
            textScaleFactor: 0.75,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Entry entry = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          entry.feed.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(entry, context),
            Html(
              data: entry.content,
              onLinkTap: (url) => _launchURL(url),
              onImageTap: (url) => _launchURL(url),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Spacer(),
            IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () => _launchURL(entry.url),
            ),
          ],
        ),
      ),
    );
  }
}
