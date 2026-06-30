import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String productionUrl =
      'https://nic-software-development.vercel.app/api';
  static const String developmentUrl =
      'http://10.0.2.2:5000/api';

  static const String baseUrl = kReleaseMode ? productionUrl : developmentUrl;

  static const String register = '/auth/register';
  static const String login = '/auth/login';

  static const String villages = '/villages';
  static const String activeVillage = '/villages/active';

  static const String assessments = '/assessments';
  static const String latestAssessment = '/assessments/latest';

  static const String scenarios = '/scenarios';

  static String runAnalyst(String scenarioId) =>
      '/scenarios/$scenarioId/analyst';
  static String runBlueprint(String scenarioId) =>
      '/scenarios/$scenarioId/blueprint';
}
