// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryDetails.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdHistoryDetailsCopyWith on CmdHistoryDetails {
  CmdHistoryDetails copyWith({
    CmdHistoryEntry? cmd,
    int? code,
    bool? fstRetrieved,
    String? logs,
    String? logsColorized,
    List<dynamic>? results,
  }) {
    return CmdHistoryDetails(
      cmd: cmd ?? this.cmd,
      code: code ?? this.code,
      fstRetrieved: fstRetrieved ?? this.fstRetrieved,
      logs: logs ?? this.logs,
      logsColorized: logsColorized ?? this.logsColorized,
      results: results ?? this.results,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryDetails _$CmdHistoryDetailsFromJson(Map<String, dynamic> json) {
  return CmdHistoryDetails(
    code: json['code'] as int,
    results: json['results'] as List<dynamic>,
    logs: json['logs'] as String,
    logsColorized: json['logsColorized'] as String,
    fstRetrieved: json['fstRetrieved'] as bool?,
  );
}

Map<String, dynamic> _$CmdHistoryDetailsToJson(CmdHistoryDetails instance) =>
    <String, dynamic>{
      'code': instance.code,
      'results': instance.results,
      'logs': instance.logs,
      'logsColorized': instance.logsColorized,
      'fstRetrieved': instance.fstRetrieved,
    };
