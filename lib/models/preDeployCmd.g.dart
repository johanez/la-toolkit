// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PreDeployCmdCopyWith on PreDeployCmd {
  PreDeployCmd copyWith({
    bool? addAdditionalDeps,
    bool? addAnsibleUser,
    bool? addSshKeys,
    bool? advanced,
    bool? continueEvenIfFails,
    bool? debug,
    bool? dryRun,
    bool? etcHosts,
    bool? giveSudo,
    List<String>? limitToServers,
    bool? rootBecome,
    List<String>? skipTags,
    bool? solrLimits,
    List<String>? tags,
  }) {
    return PreDeployCmd(
      addAdditionalDeps: addAdditionalDeps ?? this.addAdditionalDeps,
      addAnsibleUser: addAnsibleUser ?? this.addAnsibleUser,
      addSshKeys: addSshKeys ?? this.addSshKeys,
      advanced: advanced ?? this.advanced,
      continueEvenIfFails: continueEvenIfFails ?? this.continueEvenIfFails,
      debug: debug ?? this.debug,
      dryRun: dryRun ?? this.dryRun,
      etcHosts: etcHosts ?? this.etcHosts,
      giveSudo: giveSudo ?? this.giveSudo,
      limitToServers: limitToServers ?? this.limitToServers,
      rootBecome: rootBecome ?? this.rootBecome,
      skipTags: skipTags ?? this.skipTags,
      solrLimits: solrLimits ?? this.solrLimits,
      tags: tags ?? this.tags,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreDeployCmd _$PreDeployCmdFromJson(Map<String, dynamic> json) {
  return PreDeployCmd(
    addAnsibleUser: json['addAnsibleUser'] as bool,
    addSshKeys: json['addSshKeys'] as bool,
    giveSudo: json['giveSudo'] as bool,
    etcHosts: json['etcHosts'] as bool,
    solrLimits: json['solrLimits'] as bool,
    addAdditionalDeps: json['addAdditionalDeps'] as bool,
    rootBecome: json['rootBecome'] as bool?,
    limitToServers: (json['limitToServers'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    skipTags:
        (json['skipTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    advanced: json['advanced'] as bool,
    continueEvenIfFails: json['continueEvenIfFails'] as bool,
    debug: json['debug'] as bool,
    dryRun: json['dryRun'] as bool,
  )
    ..deployServices = (json['deployServices'] as List<dynamic>)
        .map((e) => e as String)
        .toList()
    ..onlyProperties = json['onlyProperties'] as bool;
}

Map<String, dynamic> _$PreDeployCmdToJson(PreDeployCmd instance) =>
    <String, dynamic>{
      'deployServices': instance.deployServices,
      'limitToServers': instance.limitToServers,
      'skipTags': instance.skipTags,
      'advanced': instance.advanced,
      'onlyProperties': instance.onlyProperties,
      'continueEvenIfFails': instance.continueEvenIfFails,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
      'addAnsibleUser': instance.addAnsibleUser,
      'addSshKeys': instance.addSshKeys,
      'giveSudo': instance.giveSudo,
      'etcHosts': instance.etcHosts,
      'solrLimits': instance.solrLimits,
      'addAdditionalDeps': instance.addAdditionalDeps,
      'rootBecome': instance.rootBecome,
      'tags': instance.tags,
    };
