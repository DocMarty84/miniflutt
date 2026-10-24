import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account.dart';
import 'data.dart';
import 'nav.dart';

class Accounts extends ChangeNotifier {
  final List<Account> accounts = [];
  String? activeId;

  // The constructor allows loading at startup
  Accounts() {
    load();
  }

  Account? get active {
    for (Account account in accounts) {
      if (account.id == activeId) {
        return account;
      }
    }
    return null;
  }

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    accounts.clear();
    accounts.addAll(_read(prefs));
    activeId = prefs.getString('activeAccount');
    notifyListeners();
  }

  // Add a new account or update an existing one. A new account becomes the
  // active one.
  Future<void> save(Account account, BuildContext context) async {
    final int index = accounts.indexWhere((a) => a.id == account.id);
    if (index == -1) {
      accounts.add(account);
    } else {
      accounts[index] = account;
    }
    if (index == -1 || account.id == activeId) {
      await activate(account.id, context);
    } else {
      await _write();
      notifyListeners();
    }
  }

  // The UI preferences are kept, they are shared by all accounts
  Future<void> remove(String id, BuildContext context) async {
    accounts.removeWhere((a) => a.id == id);
    if (id == activeId) {
      await activate(accounts.isEmpty ? null : accounts.first.id, context);
    } else {
      await _write();
      notifyListeners();
    }
  }

  Future<void> activate(String? id, BuildContext context) async {
    // Get the providers before the context can be unmounted, e.g. when the
    // drawer closes
    final data = Provider.of<Data>(context, listen: false);
    final nav = Provider.of<Nav>(context, listen: false);

    activeId = id;
    await _write();
    notifyListeners();

    // Refresh to populate the interface
    data.clear();
    data.refresh();
    nav.set(null, null, 'All');
  }

  Future<void> _write() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accounts',
        json.encode(accounts.map((account) => account.toJson()).toList()));
    if (activeId == null) {
      await prefs.remove('activeAccount');
    } else {
      await prefs.setString('activeAccount', activeId!);
    }
  }

  static List<Account> _read(SharedPreferences prefs) {
    final List<dynamic> jsonAccounts =
        json.decode(prefs.getString('accounts') ?? '[]');
    return jsonAccounts.map((elem) => Account.fromJson(elem)).toList();
  }

  // Read from the preferences, so it is available before the provider loads
  static Future<Account?> readActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? activeId = prefs.getString('activeAccount');
    for (Account account in _read(prefs)) {
      if (account.id == activeId) {
        return account;
      }
    }
    return null;
  }

  // Older versions had a single server: make it the active account
  static Future<void> migrate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('url');
    if (url == null) {
      return;
    }
    final Account account = Account(
      url: url,
      apiKey: (prefs.getString('apiKey') ?? ''),
      limit: (prefs.getString('limit') ?? '500'),
    );
    final List<Account> accounts = _read(prefs)..add(account);
    await prefs.setString('accounts',
        json.encode(accounts.map((account) => account.toJson()).toList()));
    await prefs.setString('activeAccount', account.id);
    await prefs.remove('url');
    await prefs.remove('apiKey');
    await prefs.remove('limit');
  }
}
