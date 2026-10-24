class Account {
  final String id;
  final String url;
  final String apiKey;
  final String limit;
  String? username;

  Account({
    String? id,
    required this.url,
    required this.apiKey,
    required this.limit,
    this.username,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      url: json['url'],
      apiKey: json['api_key'],
      limit: json['limit'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'api_key': apiKey,
      'limit': limit,
      'username': username,
    };
  }

  // Name shown in the drawer and the settings, e.g. 'john@example.org'
  String get label {
    final String server = Uri.parse(url).authority;
    return username == null ? server : '$username@$server';
  }
}
