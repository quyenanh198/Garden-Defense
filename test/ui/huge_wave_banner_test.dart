import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/level_data.dart';
import 'package:garden_defense/ui/game_screen.dart';
import 'package:garden_defense/ui/overlays/huge_wave_banner.dart';

void main() {
  testWidgets('second huge wave during first banner still shows a banner',
      (tester) async {
    // Khung 1280x720 như thiết bị thật — mặc định 800x600 làm HUD overflow.
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Manifest rỗng: sprite thật chưa có, để load ảnh thiếu không bị
    // flutter_test tính là lỗi (app thật bỏ qua và vẽ placeholder).
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => ByteData.sublistView(utf8.encode('{"sprites":{}}')),
    );
    // Cảnh báo tại t=1 và t=2.5 (lead 3s): banner đầu hết hạn ở t=4.2,
    // banner cho wave 2 phải còn hiện tới t=5.6.
    final lvl = LevelData(
      id: 98,
      name: 'banner',
      // Đủ sun để thẻ không hiện dòng "thiếu sun" (dòng đó làm PlantCard
      // overflow 13px với font metric của test — bug nhỏ riêng, xem HANDOFF).
      startingSun: 100,
      availablePlants: const ['peashooter'],
      skySuns: false,
      waves: const [
        WaveEntry(time: 4, zombie: 'walker', row: 0, hugeWave: true),
        WaveEntry(time: 5.5, zombie: 'walker', row: 1, hugeWave: true),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: GameScreen(level: lvl)));
    await tester.pump();
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1200)); // t≈1.2: cảnh báo 1
    await tester.pump();
    expect(find.byType(HugeWaveBanner), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400)); // t≈2.6: cảnh báo 2
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000)); // t≈4.6
    await tester.pump();
    // Banner 1 đã quá hạn (1.2+3=4.2); banner cho wave 2 phải còn.
    expect(find.byType(HugeWaveBanner), findsOneWidget);

    // Để timer banner cuối (hết ~5.6) chạy xong, tránh pending timer.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
