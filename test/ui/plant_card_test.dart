import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/level_data.dart';
import 'package:garden_defense/ui/game_screen.dart';

void main() {
  testWidgets('HUD card with "thiếu sun" line lays out without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => ByteData.sublistView(utf8.encode('{"sprites":{}}')),
    );
    // startingSun 0 < giá peashooter → thẻ hiện dòng "thiếu sun".
    final lvl = LevelData(
      id: 97,
      name: 'hud',
      startingSun: 0,
      availablePlants: const ['peashooter'],
      skySuns: false,
      waves: const [WaveEntry(time: 999, zombie: 'walker', row: 0)],
    );
    await tester.pumpWidget(MaterialApp(home: GameScreen(level: lvl)));
    await tester.pump();
    await tester.pump();
    expect(find.text('thiếu sun'), findsOneWidget);
    // Không có exception overflow nào — flutter_test tự fail nếu có.
  });
}
