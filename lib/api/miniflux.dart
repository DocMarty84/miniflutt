import 'dart:async';
import 'dart:convert';
//import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _get(
    String endpoint, Map<String, String> params) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    return null;
  }

  final query =
      new Uri.http('', endpoint, params).toString().replaceFirst('http:', '');
  final response =
      await http.get(url + query, headers: {'X-Auth-Token': apiKey});

  if (response.statusCode == 200) {
    return utf8.decode(response.bodyBytes);
  } else {
    throw Exception('Failed to load URL: ${url + query}');
  }
}

Future<bool> _put(String endpoint, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    return false;
  }

  String bodyStr = jsonEncode(body);
  final response = await http.put(url + endpoint,
      body: bodyStr,
      headers: {'X-Auth-Token': apiKey, 'Content-Type': 'application/json'});

  if (response.statusCode <= 204) {
    return true;
  } else {
    throw Exception(
        'Failed to update data:\nEndpoint: ${url + endpoint}\nBody: $body');
  }
}

Future<List<dynamic>> getFeeds() async {
  final String res = await _get('/v1/feeds', <String, String>{});
  return json.decode(res ?? '[]');
}

Future<bool> updateFeed(int feedId, Map<String, dynamic> params) async {
  return await _put('/v1/feeds/$feedId', params);
}

Future<bool> refreshAllFeeds() async {
  Map<String, dynamic> params = {};
  return await _put('/v1/feeds/refresh', params);
}

Future<Map<String, dynamic>> getEntries(Map<String, String> params) async {
  final String res = await _get('/v1/entries', params);
  return json.decode(res ?? '{}');
}

Future<bool> updateEntries(List<int> entryIds, String status) async {
  Map<String, dynamic> params = {
    "entry_ids": entryIds,
    "status": status,
  };
  return await _put('/v1/entries', params);
}

Future<bool> toggleEntryBookmark(int entryId) async {
  Map<String, dynamic> params = {};
  return await _put('/v1/entries/$entryId/bookmark', params);
}
