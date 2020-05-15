import 'dart:async';
import 'dart:convert';
//import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> _get(
    String endpoint, Map<String, String> params) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    return {};
  }

  final query =
      new Uri.http('', endpoint, params).toString().replaceFirst('http:', '');
  final response =
      await http.get(url + query, headers: {'X-Auth-Token': apiKey});

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
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

Future<bool> refreshAllFeeds() async {
  Map<String, dynamic> params = {};
  return await _put('/v1/feeds/refresh', params);
}

Future<Map<String, dynamic>> getEntries() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final limit = (prefs.getString('limit') ?? '500');
  Map<String, String> params = {
    'status': 'unread',
    'direction': 'desc',
    'limit': limit,
  };
  return await _get('/v1/entries', params);
}

Future<bool> updateEntries(List<int> entryIds, String status) async {
  Map<String, dynamic> params = {
    "entry_ids": entryIds,
    "status": status,
  };
  return await _put('/v1/entries', params);
}
