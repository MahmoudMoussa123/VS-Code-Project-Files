import 'package:freezed_annotation/freezed_annotation.dart';
part 'edit_submission.freezed.dart';
part 'edit_submission.g.dart';

enum EditStatus { pending, submitted, failed }

@freezed
class EditSubmission with _$EditSubmission {
  const factory EditSubmission({
    required String id,
    required String productGtIn,
    required Map<String, dynamic> proposedChanges,
    required EditStatus status,
    DateTime? createdAt,
  }) = _EditSubmission;

  factory EditSubmission.fromJson(Map<String, dynamic> json) => _$EditSubmissionFromJson(json);
}