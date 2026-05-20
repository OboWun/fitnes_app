// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatSessionImpl _$$ChatSessionImplFromJson(Map<String, dynamic> json) =>
    _$ChatSessionImpl(
      id: json['id'] as String,
      mode:
          $enumDecodeNullable(_$ChatModeEnumMap, json['mode']) ?? ChatMode.chat,
      dialogId: json['dialogId'] as String?,
      title: json['title'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatSessionImplToJson(_$ChatSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mode': _$ChatModeEnumMap[instance.mode]!,
      'dialogId': instance.dialogId,
      'title': instance.title,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$ChatModeEnumMap = {ChatMode.chat: 'chat', ChatMode.workout: 'workout'};
