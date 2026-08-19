import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/progress_store.dart';
import 'package:garden_defense/ui/game_screen.dart';
import 'package:garden_defense/ui/level_select_screen.dart';
import 'package:garden_defense/ui/menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('menu opens level select; only level 1 unlocked by default',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
    await tester.pump(); // ProgressStore.load
    await tester.tap(find.text('Chơi'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(9));
  });

  testWidgets('double tap on level 1 pushes only one GameScreen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await ProgressStore.load();
    // Giữ load level treo để cả hai tap rơi vào khoảng await trong _play.
    final assetLoad = Completer<ByteData>();
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) => assetLoad.future,
    );
    await tester.pumpWidget(
      MaterialApp(home: LevelSelectScreen(store: store)),
    );
    await tester.tap(find.text('1'));
    await tester.tap(find.text('1'));
    final jsonText = File('assets/levels/level_01.json').readAsStringSync();
    assetLoad.complete(ByteData.sublistView(utf8.encode(jsonText)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('Endless button opens an endless GameScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => ByteData.sublistView(utf8.encode('{"sprites":{}}')),
    );
    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
    await tester.pump(); // ProgressStore.load
    await tester.tap(find.text('Endless'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final screen = tester.widget<GameScreen>(
      find.byType(GameScreen, skipOffstage: false),
    );
    expect(screen.endless, isTrue);
    // Test chạy với TargetPlatform.android → lưới 5×9.
    expect(screen.rows, 5);
    expect(screen.cols, 9);
  });
}
