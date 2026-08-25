import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/core/web_channel_buffers.dart';

void main() {
  test('early lifecycle messages are queued instead of overflowing', () async {
    acceptEarlyLifecycleMessages();

    var acked = 0;
    for (var i = 0; i < 8; i++) {
      ui.channelBuffers.push(kLifecycleChannel, null, (_) {
        acked++;
      });
    }

    expect(acked, 0);

    ui.channelBuffers.setListener(kLifecycleChannel, (data, callback) {
      callback(null);
    });
    await Future<void>.delayed(Duration.zero);

    expect(acked, 8);
    ui.channelBuffers.clearListener(kLifecycleChannel);
  });

  test('vm lifecycle hold and release do not throw', () {
    holdBrowserLifecycle();
    releaseHeldBrowserLifecycle();
  });
}
