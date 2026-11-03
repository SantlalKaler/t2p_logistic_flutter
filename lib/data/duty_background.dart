import 'package:flutter/services.dart';

/// Android owns GPS and uploads outside the Flutter UI's lifetime.
class DutyBackground {
  static const channel = MethodChannel('t2p/duty_tracking');

  Future<void> start({
    required String owner,
    required String session,
    required String token,
    required String baseUrl,
    required String databasePath,
  }) => channel.invokeMethod('start', {
    'owner': owner,
    'session': session,
    'token': token,
    'baseUrl': baseUrl,
    'databasePath': databasePath,
  });

  Future<void> stop() => channel.invokeMethod('stop');
  Future<void> pause() => channel.invokeMethod('pause');
  Future<void> sync() => channel.invokeMethod('sync');
  Future<String> warning() async =>
      await channel.invokeMethod<String>('warning') ?? '';
}
