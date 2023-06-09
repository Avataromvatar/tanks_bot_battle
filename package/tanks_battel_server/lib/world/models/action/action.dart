import 'package:json_annotation/json_annotation.dart';

part 'action.g.dart';

//@JsonEnum()
enum eTankActions {
  platform_rotate_clockwise,
  platform_rotate_counterclockwise,
  tower_rotate_clockwise,
  tower_rotate_counterclockwise,
  move_forward,
  move_back,
  shoot;

  // String toJson() => index.toString();
  // static eTankActions fromJson(String json) => values.byName(json);
  int toJson() => index;
  static eTankActions fromJson(dynamic json) => json is String ? values[int.parse(json)] : values[json];
  static List<eTankActions>? fromListJson(List<dynamic>? json) {
    return json?.map((e) => fromJson(e)).toList();
  }

  static List<int>? toListJson(List<eTankActions>? data) {
    return data?.map((e) => e.index).toList();
  }
}

enum eCommonActions {
  none;

  String toJson() => name;
  static eCommonActions fromJson(String json) => values.byName(json);
}

@JsonSerializable()
class TankActionsData {
  String key;

  ///maximum 3 action
  @JsonKey(fromJson: eTankActions.fromListJson, toJson: eTankActions.toListJson)
  List<eTankActions>? actions;
  // List<eCommonActions>? commonActions;
  TankActionsData({
    required this.key,
    this.actions,
  });
  factory TankActionsData.fromJson(Map<String, dynamic> json) => _$TankActionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$TankActionsDataToJson(this);

  // Map<String, dynamic> toJson() {
  //   return {'key': key, if (actions != null) 'actions': actions!.map((e) => e.index).toList()};
  // }

  // static TankActionsData fromJson(Map<String, dynamic> json) {
  //   return TankActionsData(key: json['key'], actions: json['actions'].map((e) => eTankActions.values[e]).toList());
  // }
}
