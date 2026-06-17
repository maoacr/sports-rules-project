import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route path constants (v2: chapters/rules → laws/articles).
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String sports = '/sports/:sportId';
  static const String law = '/sports/:sportId/laws/:lawId';
  static const String article =
      '/sports/:sportId/laws/:lawId/articles/:articleId';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Route name constants.
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String home = 'home';
  static const String sports = 'sports';
  static const String law = 'law';
  static const String article = 'article';
  static const String profile = 'profile';
  static const String settings = 'settings';
}

/// Parsed deep link result.
sealed class DeepLinkResult {
  const DeepLinkResult();
}

/// Successful deep link parse result.
class DeepLinkSuccess extends DeepLinkResult {
  final Uri uri;
  final DeepLinkRoute route;

  const DeepLinkSuccess({required this.uri, required this.route});
}

/// Failed deep link parse result.
class DeepLinkParseFailure extends DeepLinkResult {
  final String message;

  const DeepLinkParseFailure(this.message);
}

/// Deep link route types.
sealed class DeepLinkRoute {
  final String path;
  const DeepLinkRoute(this.path);
}

class DeepLinkArticle extends DeepLinkRoute {
  final String articleId;
  final String? sportId;
  final String? lawId;
  const DeepLinkArticle(super.path,
      {required this.articleId, this.sportId, this.lawId});
}

class DeepLinkLaw extends DeepLinkRoute {
  final String lawId;
  final String sportId;
  const DeepLinkLaw(super.path, {required this.lawId, required this.sportId});
}

class DeepLinkSport extends DeepLinkRoute {
  final String sportId;
  const DeepLinkSport(super.path, {required this.sportId});
}

class DeepLinkHome extends DeepLinkRoute {
  const DeepLinkHome(super.path);
}

/// App Links listener and route parser.
///
/// Listens for incoming App Links (iOS Universal Links + Android App Links)
/// and resolves them to the appropriate screen.
class DeepLinkHandler {
  static const String _domain = 'sportsrules.app';

  /// Parses an incoming deep link URI and returns the resolved route.
  DeepLinkResult parseUri(Uri uri) {
    // Only handle our domain
    if (uri.host != _domain && !uri.host.endsWith('.$_domain')) {
      return DeepLinkParseFailure('Unknown domain: ${uri.host}');
    }

    final route = _fromUri(uri);
    if (route == null) {
      return const DeepLinkParseFailure('Could not parse deep link path');
    }

    return DeepLinkSuccess(uri: uri, route: route);
  }

  /// Converts a URI to a DeepLinkRoute.
  static DeepLinkRoute? _fromUri(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.isEmpty) {
      return const DeepLinkHome('/');
    }

    switch (segments[0]) {
      case 'article':
        if (segments.length >= 2) {
          return DeepLinkArticle(
            '/article/${segments[1]}',
            articleId: segments[1],
          );
        }
        break;
      case 'law':
        if (segments.length >= 2) {
          final lawId = segments[1];
          final sportId = uri.queryParameters['sport'] ?? 'default';
          return DeepLinkLaw(
            '/law/$lawId',
            lawId: lawId,
            sportId: sportId,
          );
        }
        break;
      case 'sport':
        if (segments.length >= 2) {
          return DeepLinkSport(
            '/sports/${segments[1]}',
            sportId: segments[1],
          );
        }
        break;
    }

    return const DeepLinkHome('/');
  }

  /// Builds a deep link URL for an article.
  static String buildArticleUrl(String articleId,
      {String? sportId, String? lawId}) {
    if (sportId != null && lawId != null) {
      return 'https://$_domain/article/$articleId?sport=$sportId&law=$lawId';
    }
    return 'https://$_domain/article/$articleId';
  }

  /// Builds a deep link URL for a law.
  static String buildLawUrl(String lawId, {String? sportId}) {
    if (sportId != null) {
      return 'https://$_domain/law/$lawId?sport=$sportId';
    }
    return 'https://$_domain/law/$lawId';
  }

  /// Builds a deep link URL for a sport.
  static String buildSportUrl(String sportId) {
    return 'https://$_domain/sport/$sportId';
  }

  /// Navigates to the appropriate page based on the deep link result.
  void handleDeepLinkResult(DeepLinkResult result, BuildContext context) {
    if (result is DeepLinkSuccess) {
      final route = result.route;

      if (route is DeepLinkArticle) {
        final sportId = result.uri.queryParameters['sport'];
        final lawId = result.uri.queryParameters['law'];
        if (sportId != null && lawId != null) {
          context.push(
            '/sports/$sportId/laws/$lawId/articles/${route.articleId}',
          );
        } else {
          context.go('/home');
        }
      } else if (route is DeepLinkSport) {
        context.push('/sports/${route.sportId}');
      } else if (route is DeepLinkLaw) {
        context.push('/sports/${route.sportId}/laws/${route.lawId}');
      } else {
        context.go('/home');
      }
    } else if (result is DeepLinkParseFailure) {
      context.go('/home');
    }
  }
}
