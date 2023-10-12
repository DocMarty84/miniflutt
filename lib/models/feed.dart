import 'category.dart';

class Feed {
  final Category? category;
  final String? checkedAt;
  final bool? crawler;
  final bool? disabled;
  final String? etagHeader;
  final String? feedUrl;
  final int? id;
  final String? lastModifiedHeader;
  final int? parsingErrorCount;
  final String? parsingErrorMessage;
  final String? password;
  final String? rewriteRules;
  final String? scraperRules;
  final String? siteUrl;
  final String? title;
  final String? userAgent;
  final int? userId;
  final String? userName;
  final bool? hideGlobally;

  Feed({
    this.category,
    this.checkedAt,
    this.crawler,
    this.disabled,
    this.etagHeader,
    this.feedUrl,
    this.id,
    this.lastModifiedHeader,
    this.parsingErrorCount,
    this.parsingErrorMessage,
    this.password,
    this.rewriteRules,
    this.scraperRules,
    this.siteUrl,
    this.title,
    this.userAgent,
    this.userId,
    this.userName,
    this.hideGlobally,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      category: Category.fromJson(json['category']),
      checkedAt: json['checked_at'],
      crawler: json['crawler'],
      disabled: json['disabled'],
      etagHeader: json['etag_header'],
      feedUrl: json['feed_url'],
      id: json['id'],
      lastModifiedHeader: json['last_modified_header'],
      parsingErrorCount: json['parsing_error_count'],
      parsingErrorMessage: json['parsing_error_message'],
      password: json['password'],
      rewriteRules: json['rewrite_rules'],
      scraperRules: json['scraper_rules'],
      siteUrl: json['site_url'],
      title: json['title'],
      userAgent: json['user_agent'],
      userId: json['user_id'],
      userName: json['user_name'],
      hideGlobally: (json.containsKey('hide_globally') ? json['hide_globally'] : false),
    );
  }
}
