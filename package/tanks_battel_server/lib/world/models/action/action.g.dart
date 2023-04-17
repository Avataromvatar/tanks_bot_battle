// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TankActionsData _$TankActionsDataFromJson(Map<String, dynamic> json) =>
    TankActionsData(
      key: json['key'] as String,
      actions: eTankActions.fromListJson(json['actions'] as List?),
    );

Map<String, dynamic> _$TankActionsDataToJson(TankActionsData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'actions': eTankActions.toListJson(instance.actions),
    };
