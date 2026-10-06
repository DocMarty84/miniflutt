import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miniflutt/common/local_network.dart';

bool local(String ip) => isLocalAddress(InternetAddress(ip));

void main() {
  test('private and link-local IPv4 addresses are local', () {
    for (final ip in [
      '10.0.0.1',
      '172.16.0.1',
      '172.31.255.255',
      '192.168.1.10',
      '169.254.0.1',
    ]) {
      expect(local(ip), isTrue, reason: ip);
    }
  });

  test('public and loopback IPv4 addresses are not local', () {
    for (final ip in [
      '8.8.8.8',
      '172.15.0.1',
      '172.32.0.1',
      '192.169.0.1',
      '127.0.0.1',
    ]) {
      expect(local(ip), isFalse, reason: ip);
    }
  });

  test('IPv6 addresses', () {
    expect(local('fd00::1'), isTrue);
    expect(local('fc00::1'), isTrue);
    expect(local('fe80::1'), isTrue);
    expect(local('::ffff:192.168.1.10'), isTrue);
    expect(local('2001:4860:4860::8888'), isFalse);
    expect(local('::1'), isFalse);
  });

  test('host names', () {
    expect(isLocalHostname('nas.local'), isTrue);
    expect(isLocalHostname('miniflux.lan'), isTrue);
    expect(isLocalHostname('miniflux'), isTrue);
    expect(isLocalHostname('miniflux.example.com'), isFalse);
  });

  test('server URLs with IP literals', () async {
    expect(await isLocalServer('http://192.168.1.10:8080'), isTrue);
    expect(await isLocalServer('http://[fd00::1]:8080'), isTrue);
    expect(await isLocalServer('http://localhost:8080'), isFalse);
    expect(await isLocalServer('https://1.1.1.1'), isFalse);
    expect(await isLocalServer('http://'), isFalse);
  });
}
