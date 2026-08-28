// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foundation_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoundationStatus _$FoundationStatusFromJson(Map<String, dynamic> json) =>
    _FoundationStatus(
      isReady: json['isReady'] as bool,
      environment: json['environment'] as String,
    );

Map<String, dynamic> _$FoundationStatusToJson(_FoundationStatus instance) =>
    <String, dynamic>{
      'isReady': instance.isReady,
      'environment': instance.environment,
    };
