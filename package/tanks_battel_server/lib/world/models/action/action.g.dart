// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TankActionsData _$TankActionsDataFromJson(Map<String, dynamic> json) =>
    TankActionsData(
      key: json['key'] as String,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$eTankActionsEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$TankActionsDataToJson(TankActionsData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'actions': instance.actions,
    };

const _$eTankActionsEnumMap = {
  eTankActions.platform_rotate_clockwise: 'platform_rotate_clockwise',
  eTankActions.platform_rotate_counterclockwise:
      'platform_rotate_counterclockwise',
  eTankActions.tower_rotate_clockwise: 'tower_rotate_clockwise',
  eTankActions.tower_rotate_counterclockwise: 'tower_rotate_counterclockwise',
  eTankActions.move_forward: 'move_forward',
  eTankActions.move_back: 'move_back',
  eTankActions.shoot: 'shoot',
};
