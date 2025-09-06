import 'package:freezed_annotation/freezed_annotation.dart';
part 'score.freezed.dart';
part 'score.g.dart';

@freezed
class Score with _$Score {
  const factory Score({
    required double total,
    required double nutrition,
    required double additivesPenalty,
    required double processingPenalty,
    required int algorithmVersion,
    DateTime? calculatedAt,
  }) = _Score;

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
}