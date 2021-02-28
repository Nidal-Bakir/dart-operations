import 'dart:isolate';

import 'package:dart_operations/two%20way%20process%20con.dart';

void main() async {
  var twoWayIsolate = await TwoWayIsolate().spawn(doSomeThingInIsolate);
  twoWayIsolate.isolateToMainStream.stream.listen((message) {
    print(message + ' listen from the main');
  });
  twoWayIsolate.sendPort.send('send from the main');
}

void doSomeThingInIsolate(sendPort, ReceivePort receivePort) {
  receivePort.listen((message) {
    print(message + ' listen from the isolate');
  });
  sendPort.send('send from the isolate');
}
