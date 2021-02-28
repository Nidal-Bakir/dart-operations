import 'dart:async';
import 'dart:isolate';

/// @param sendPort send event to main isolate
///
/// @param receivePort receive from the main isolate

typedef isolateFunc = void Function(SendPort sendPort, ReceivePort receivePort);

class TwoWayIsolate {
  Isolate isolate;

  SendPort sendPort;
  var isolateToMainStream = StreamController();

  TwoWayIsolate._(this.isolate, this.sendPort);

  TwoWayIsolate();

  Future<TwoWayIsolate> spawn(isolateFunc isolateFunc) async {
    Isolate isolateInstance;
    TwoWayIsolate twoWayIsolate;
    var completer = Completer<TwoWayIsolate>();
    var isolateToMainReceivePort = ReceivePort();

    isolateToMainReceivePort.listen((data) {
      if (data is SendPort) {
        twoWayIsolate = TwoWayIsolate._(isolateInstance, data);
        completer.complete(twoWayIsolate);
      } else {
        twoWayIsolate.isolateToMainStream.sink.add(data);
      }
    });

    isolateInstance = await Isolate.spawn(
        function, [isolateFunc, isolateToMainReceivePort.sendPort]);

    return completer.future;
  }
}

void function(List args) {
  var receivePort = ReceivePort();
  args[1].send(receivePort.sendPort);

  args[0](args[1], receivePort); // invoke the isolate function
}


