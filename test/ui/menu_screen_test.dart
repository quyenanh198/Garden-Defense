import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/ui/game_screen.dart';
import 'package:garden_defense/ui/menu_screen.dart';

void main() {
  testWidgets('double tap on play pushes only one GameScreen', (tester) async {
    // Giữ load level treo để cả hai tap rơi vào khoảng await trong _play.
    final assetLoad = Completer<ByteData>();
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) => assetLoad.future,
    );
    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
    await tester.tap(find.text('Chơi level 1'));
    await tester.tap(find.text('Chơi level 1'));
    final jsonText = File('assets/levels/level_01.json').readAsStringSync();
    assetLoad.complete(ByteData.sublistView(utf8.encode(jsonText)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen, skipOffstage: false), findsOneWidget);
  });
}
