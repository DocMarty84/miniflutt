import 'dart:async';
import 'dart:convert';
//import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final Map<int, String> statusCodes = {
  200: 'Everything is OK',
  201: 'Resource created/modified',
  204: 'Resource removed/modified',
  400: 'Bad request',
  401: 'Unauthorized (bad username/password)',
  403: 'Forbidden (access not allowed)',
  500: 'Internal server error',
};

String makeError(String msg, http.Response res, String endpoint,
    Map<String, dynamic> params) {
  final String error = statusCodes.containsKey(res.statusCode)
      ? statusCodes[res.statusCode]
      : res.reasonPhrase;
  return '$msg\n'
      'Status code: ${res.statusCode}\n'
      'Error: $error\n'
      'Endpoint: $endpoint\n'
      'Body: $params';
}

Future<bool> _delete(String endpoint) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    throw Exception('The server URL is not set.');
  }

  final query = new Uri.http('', endpoint).toString().replaceFirst('http:', '');
  final response =
      await http.delete(url + query, headers: {'X-Auth-Token': apiKey});

  if (response.statusCode <= 204) {
    return true;
  } else {
    throw Exception(makeError('Failed to delete data.', response,
        url + endpoint, <String, dynamic>{}));
  }
}

Future<String> _get(String endpoint, Map<String, String> params) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    throw Exception('The server URL is not set.');
  }

  final query =
      new Uri.http('', endpoint, params).toString().replaceFirst('http:', '');
  final response =
      await http.get(url + query, headers: {'X-Auth-Token': apiKey});

  if (response.statusCode == 200) {
    return utf8.decode(response.bodyBytes);
  } else {
    throw Exception(makeError(
        'Failed to load URL.', response, url + endpoint, <String, dynamic>{}));
  }
}

Future<bool> _post(String endpoint, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    throw Exception('The server URL is not set.');
  }

  String bodyStr = jsonEncode(body);
  final response = await http.post(url + endpoint,
      body: bodyStr,
      headers: {'X-Auth-Token': apiKey, 'Content-Type': 'application/json'});

  if (response.statusCode <= 204) {
    return true;
  } else {
    throw Exception(
        makeError('Failed to update data.', response, url + endpoint, body));
  }
}

Future<bool> _put(String endpoint, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = (prefs.getString('url') ?? '');
  final apiKey = (prefs.getString('apiKey') ?? '');
  if (url == '') {
    throw Exception('The server URL is not set.');
  }

  String bodyStr = jsonEncode(body);
  final response = await http.put(url + endpoint,
      body: bodyStr,
      headers: {'X-Auth-Token': apiKey, 'Content-Type': 'application/json'});

  if (response.statusCode <= 204) {
    return true;
  } else {
    throw Exception(
        makeError('Failed to update data.', response, url + endpoint, body));
  }
}

Future<String> getFeeds() async {
  return await _get('/v1/feeds', <String, String>{});
}

Future<bool> createFeed(Map<String, dynamic> params) async {
  return await _post('/v1/feeds', params);
}

Future<bool> updateFeed(int feedId, Map<String, dynamic> params) async {
  return await _put('/v1/feeds/$feedId', params);
}

Future<bool> refreshAllFeeds() async {
  Map<String, dynamic> params = {};
  return await _put('/v1/feeds/refresh', params);
}

Future<bool> removeFeed(int feedId) async {
  return await _delete('/v1/feeds/$feedId');
}

Future<String> getEntries(Map<String, String> params) async {
  return await _get('/v1/entries', params);
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

Future<String> getCategories() async {
  return await _get('/v1/categories', <String, String>{});
}

Future<bool> createCategory(Map<String, dynamic> params) async {
  return await _post('/v1/categories', params);
}

Future<bool> updateCategory(int categoryId, Map<String, dynamic> params) async {
  return await _put('/v1/categories/$categoryId', params);
}

Future<bool> deleteCategory(int categoryId) async {
  return await _delete('/v1/categories/$categoryId');
}

Future<String> getCurrentUser() async {
  final Map<String, String> params = {};
  return await _get('/v1/me', params);
}

Future<bool> connectCheck() async {
  try {
    await getCurrentUser();
    return true;
  } catch (e) {
    return false;
  }
}
