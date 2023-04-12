import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:tanks_battel_server/world/logic/world_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// // Configure routes.
// final _router = Router()
//   ..get('/', _rootHandler)
//   ..get('/echo/<message>', _echoHandler);

// Response _rootHandler(Request req) {
//   return Response.ok('Hello, World!\n');
// }

// Response _echoHandler(Request request) {
//   final message = request.params['message'];
//   return Response.ok('$message\n');
// }

void main(List<String> args) async {
  var world = WorldEventBus('test_world');
  var handlerView = webSocketHandler((webSocket) {
    world.send<WebSocketChannel>(webSocket, eventName: eWorldEventName.connectView.name);

    // webSocket.stream.listen((message) {
    //   webSocket.sink.add("echo $message");
    // });
  });
  var handlerPlayer = webSocketHandler((webSocket) {
    world.send<WebSocketChannel>(webSocket, eventName: eWorldEventName.connect.name);

    // webSocket.stream.listen((message) {
    //   webSocket.sink.add("echo $message");
    // });
  });
  //server for view
  HttpServer serverView;
  bool isRun = true;
  await serve(handlerView, '127.0.0.1', 33100).then((server) {
    serverView = server;
    serverView.idleTimeout = null;
    print('Serving View at ws://${server.address.host}:${server.port}');
  });
  //server for player
  HttpServer serverPlayer;
  await serve(handlerPlayer, '127.0.0.1', 33101).then((server) {
    serverPlayer = server;
    serverPlayer.idleTimeout = null;
    print('Serving Game at ws://${server.address.host}:${server.port}');
  });

  await Future.doWhile(() async {
    await Future.delayed(Duration(seconds: 1));
    return isRun;
  });

  // // Use any available host or container IP (usually `0.0.0.0`).
  // final ip = InternetAddress.anyIPv4;

  // // Configure a pipeline that logs requests.
  // final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // // For running in containers, we respect the PORT environment variable.
  // final port = int.parse(Platform.environment['PORT'] ?? '8080');
  // final server = await serve(handler, ip, port);
  // print('Server listening on port ${server.port}');
}
