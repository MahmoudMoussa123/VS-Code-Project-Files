import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureFlags {
  FeatureFlags(this.raw);
  final Map<String, dynamic> raw;
  bool get premium => raw['premium'] == true;
  bool get aiExplanations => raw['ai_explanations'] == true;
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final jsonStr = const String.fromEnvironment('FEATURE_FLAGS', defaultValue: '{"premium":false,"ai_explanations":true}');
  return FeatureFlags(json.decode(jsonStr) as Map<String, dynamic>);
});