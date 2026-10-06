import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Android 17 (and GrapheneOS) requires the 'Nearby devices' permission
// (ACCESS_LOCAL_NETWORK) to connect to servers on the local network.
const _channel = MethodChannel('miniflutt/local_network');

// Whether the address belongs to a local network (private, link-local or
// unique local). Loopback is not restricted, so it is not considered local.
bool isLocalAddress(InternetAddress address) {
  final b = address.rawAddress;
  if (address.type == InternetAddressType.IPv4) {
    return b[0] == 10 ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 && b[1] == 168) ||
        (b[0] == 169 && b[1] == 254);
  }
  if (address.type == InternetAddressType.IPv6) {
    // IPv4-mapped (::ffff:a.b.c.d)
    if (b.sublist(0, 10).every((x) => x == 0) && b[10] == 0xff && b[11] == 0xff) {
      return isLocalAddress(InternetAddress.fromRawAddress(b.sublist(12)));
    }
    return (b[0] & 0xfe) == 0xfc || // fc00::/7
        (b[0] == 0xfe && (b[1] & 0xc0) == 0x80); // fe80::/10
  }
  return false;
}

// Host names that can only be resolved on the local network.
bool isLocalHostname(String host) {
  final h = host.toLowerCase();
  return h.endsWith('.local') || h.endsWith('.lan') || !h.contains('.');
}

// Whether the server URL points to the local network. The host is resolved
// to catch names that point to private addresses (e.g. split-horizon DNS).
Future<bool> isLocalServer(String url) async {
  final String host = Uri.tryParse(url)?.host ?? '';
  if (host.isEmpty) {
    return false;
  }
  final InternetAddress? literal = InternetAddress.tryParse(host);
  if (literal != null) {
    return isLocalAddress(literal);
  }
  if (host.toLowerCase() == 'localhost') {
    return false;
  }
  if (isLocalHostname(host)) {
    return true;
  }
  try {
    final addresses = await InternetAddress.lookup(host);
    return addresses.any(isLocalAddress);
  } catch (e) {
    return false;
  }
}

// Whether the server answers at all. Any HTTP response means the network
// path works (e.g. through a VPN, which Android does not consider local).
Future<bool> canReachServer(String url) async {
  try {
    await http.get(Uri.parse(url)).timeout(Duration(seconds: 3));
    return true;
  } catch (e) {
    return false;
  }
}

// Whether the app may connect to the local network.
Future<bool> hasLocalNetworkPermission() async {
  if (!Platform.isAndroid) {
    return true;
  }
  return await _channel.invokeMethod<String>('status') == 'granted';
}

// Whether the server is on the local network and the permission is missing.
Future<bool> needsLocalNetworkPermission(String url) async {
  return await isLocalServer(url) && !await hasLocalNetworkPermission();
}

Future<void> openAppSettings() async {
  await _channel.invokeMethod('openSettings');
}

enum _Choice { allow, notNow, never }

// Ask for the permission if the server is on the local network. Return true
// if the app may connect to the server. At startup, the user may also choose
// to never be asked again for this server.
Future<bool> ensureLocalNetworkAccess(BuildContext context, String url,
    {bool startup = false}) async {
  if (!await needsLocalNetworkPermission(url)) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  final _Choice? choice = await showDialog<_Choice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Local network access'),
      content: Text('Miniflutt could not connect to your server, which is on '
          'your local network. Allow the \'Nearby devices\' permission to '
          'reach it.'),
      actions: <Widget>[
        if (startup)
          TextButton(
            child: Text('Don\'t ask again'),
            onPressed: () => Navigator.pop(context, _Choice.never),
          ),
        TextButton(
          child: Text('Not now'),
          onPressed: () => Navigator.pop(context, _Choice.notNow),
        ),
        TextButton(
          child: Text('Allow'),
          onPressed: () => Navigator.pop(context, _Choice.allow),
        ),
      ],
    ),
  );
  if (choice == _Choice.never) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_neverAskPref, url);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You won\'t be asked again at startup. Save your '
              'server in Settings to undo this.')));
    }
  }
  if (choice != _Choice.allow) {
    return false;
  }

  final String? res = await _channel.invokeMethod<String>('request');
  if (res == 'granted') {
    return true;
  }
  if (res == 'permanentlyDenied' && context.mounted) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Local network access'),
        content: Text('The \'Nearby devices\' permission was denied. You can '
            'allow it in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Open settings'),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }
  return false;
}

const _neverAskPref = 'localNetworkNeverAsk';

// Ask again at startup, after the user chose to never be asked.
Future<void> resetLocalNetworkNeverAsk() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(_neverAskPref);
}

// Ask at startup if the server is unreachable because of the missing
// permission, unless the user chose to never be asked for this server. Return
// true if the permission was just granted.
Future<bool> askLocalNetworkOnStartup(BuildContext context, String url) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString(_neverAskPref) == url ||
      !await needsLocalNetworkPermission(url) ||
      await canReachServer(url) ||
      !context.mounted) {
    return false;
  }
  return await ensureLocalNetworkAccess(context, url, startup: true);
}
