import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Ganti URL ini dengan URL Vercel hasil deployment Anda nanti
  static const String productionUrl = 'https://ecosim-desa-backend.vercel.app/api';
  static const String developmentUrl = 'http://127.0.0.1:5000/api';

  static const String baseUrl = kReleaseMode ? productionUrl : developmentUrl;
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  
  // Village endpoints
  static const String villages = '/villages';
  static const String activeVillage = '/villages/active';
  
  // Assessment endpoints
  static const String assessments = '/assessments';
  static const String latestAssessment = '/assessments/latest';
  
  // Scenario endpoints
  static const String scenarios = '/scenarios';
  
  static String runAnalyst(String scenarioId) => '/scenarios/$scenarioId/analyst';
  static String runBlueprint(String scenarioId) => '/scenarios/$scenarioId/blueprint';
}
