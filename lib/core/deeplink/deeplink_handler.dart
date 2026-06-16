import 'package:go_router/go_router.dart';
import '../error/failures.dart';

/// Route path constants.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String sports = '/sports/:sportId';
  static const String chapter = '/sports/:sportId/chapters/:chapterId';
  static const String rule = '/sports/:sportId/chapters/:chapterId/rules/:ruleId';
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
  static const String chapter = 'chapter';
  static const String rule = 'rule';
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

class DeepLinkRule extends DeepLinkRoute {
  final String ruleId;
  final String? sportId;
  final String? chapterId;
  const DeepLinkRule(super.path, {required this.ruleId, this.sportId, this.chapterId});
}

class DeepLinkChapter extends DeepLinkRoute {
  final String chapterId;
  final String sportId;
  const DeepLinkChapter(super.path, {required this.chapterId, required this.sportId});
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
      case 'rule':
        if (segments.length >= 2) {
          return DeepLinkRule(
            '/rule/${segments[1]}',
            ruleId: segments[1],
          );
        }
        break;
      case 'chapter':
        if (segments.length >= 2) {
          final chapterId = segments[1];
          final sportId = uri.queryParameters['sport'] ?? 'default';
          return DeepLinkChapter(
            '/chapter/$chapterId',
            chapterId: chapterId,
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

  /// Builds a deep link URL for a rule.
  static String buildRuleUrl(String ruleId, {String? sportId, String? chapterId}) {
    if (sportId != null && chapterId != null) {
      return 'https://$_domain/rule/$ruleId?sport=$sportId&chapter=$chapterId';
    }
    return 'https://$_domain/rule/$ruleId';
  }

  /// Builds a deep link URL for a chapter.
  static String buildChapterUrl(String chapterId, {String? sportId}) {
    if (sportId != null) {
      return 'https://$_domain/chapter/$chapterId?sport=$sportId';
    }
    return 'https://$_domain/chapter/$chapterId';
  }

  /// Builds a deep link URL for a sport.
  static String buildSportUrl(String sportId) {
    return 'https://$_domain/sport/$sportId';
  }

  /// Navigates to the appropriate page based on the deep link result.
  void handleDeepLinkResult(DeepLinkResult result, BuildContext context) {
    if (result is DeepLinkSuccess) {
      final route = result.route;

      if (route is DeepLinkRule && route.ruleId != null) {
        // Rule deep links need sportId and chapterId from query params
        final sportId = result.uri.queryParameters['sport'];
        final chapterId = result.uri.queryParameters['chapter'];
        if (sportId != null && chapterId != null) {
          context.push('/sports/$sportId/chapters/$chapterId/rules/${route.ruleId}');
        } else {
          context.go('/home');
        }
      } else if (route is DeepLinkSport) {
        context.push('/sports/${route.sportId}');
      } else if (route is DeepLinkChapter) {
        context.push('/sports/${route.sportId}/chapters/${route.chapterId}');
      } else {
        context.go('/home');
      }
    } else if (result is DeepLinkParseFailure) {
      // Fallback to home on parse failure
      context.go('/home');
    }
  }
}
