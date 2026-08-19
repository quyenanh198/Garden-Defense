import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/ui/game_screen.dart';

void main() {
  testWidgets('losing an endless run reports waves survived via onEndlessEnd',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => ByteData.sublistView(utf8.encode('{"sprites":{}}')),
    );
    int? survived;
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          level: GameState.endlessConfig(),
          endless: true,
          onEndlessEnd: (w) => survived = w,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    // Không trồng gì: đợt 1 (t=20) đi hết sân → thua. dt lớn vẫn an toàn
    // nhờ va chạm quét; zombie đi 0.21 ô/s nên vài pump lớn là chạm mép.
    await tester.pump(const Duration(seconds: 25));
    await tester.pump(const Duration(seconds: 25));
    await tester.pump(const Duration(seconds: 25));
    await tester.pump();
    expect(survived, isNotNull);
    expect(survived, greaterThanOrEqualTo(1));
  });
}
