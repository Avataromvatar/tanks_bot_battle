// import 'dart:async';

// import 'package:event_bus_arch/event_bus_arch.dart';
// import 'package:tanks_battel_server/world/models/cell.dart';
// import 'package:tanks_battel_server/world/models/tank.dart';

// class PlayerStatistic extends EventBusHandlersGroup {
//   EventBusHandler? _busHandler;
//   @override
//   void connect(EventBusHandler bus) {
//     _busHandler = bus;
//   }

//   @override
//   void disconnect(EventBusHandler bus) {
//     // TODO: implement disconnect
//   }

//   @override
//   // TODO: implement isConnected
//   bool get isConnected => _busHandler != null;

//   Future<void> playerShoot(EventDTO<Tank> event, EventEmitter<EventDTO<Tank>>? emit,
//       {EventBus? bus, Completer? needComplete}) async {}
//   Future<void> playerMove(EventDTO<Tank> event, EventEmitter<EventDTO<Tank>>? emit,
//       {EventBus? bus, Completer? needComplete}) async {}
//   Future<void> playerHitTarget(EventDTO<MapEntry<ICellObject, ICellObject>> event,
//       EventEmitter<EventDTO<MapEntry<ICellObject, ICellObject>>>? emit,
//       {EventBus? bus, Completer? needComplete}) async {}
//   Future<void> playerHitTarget(EventDTO<MapEntry<ICellObject, ICellObject>> event,
//       EventEmitter<EventDTO<MapEntry<ICellObject, ICellObject>>>? emit,
//       {EventBus? bus, Completer? needComplete}) async {}
// }
