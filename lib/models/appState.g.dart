// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appState.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension AppStateCopyWith on AppState {
  AppState copyWith({
    LAProject currentProject,
    int currentStep,
    bool firstUsage,
    List<LAProject> projects,
    LAProjectStatus status,
  }) {
    return AppState(
      currentProject: currentProject ?? this.currentProject,
      currentStep: currentStep ?? this.currentStep,
      firstUsage: firstUsage ?? this.firstUsage,
      projects: projects ?? this.projects,
      status: status ?? this.status,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) {
  return AppState(
    projects: (json['projects'] as List)
        .map((e) => LAProject.fromJson(e as Map<String, dynamic>))
        .toList(),
    firstUsage: json['firstUsage'] as bool,
    currentProject: json['currentProject'] == null
        ? null
        : LAProject.fromJson(json['currentProject'] as Map<String, dynamic>),
    currentStep: json['currentStep'] as int,
    status: _$enumDecodeNullable(_$LAProjectStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'firstUsage': instance.firstUsage,
      'currentProject': instance.currentProject,
      'status': _$LAProjectStatusEnumMap[instance.status],
      'currentStep': instance.currentStep,
      'projects': instance.projects,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$LAProjectStatusEnumMap = {
  LAProjectStatus.view: 'view',
  LAProjectStatus.edit: 'edit',
  LAProjectStatus.create: 'create',
};
