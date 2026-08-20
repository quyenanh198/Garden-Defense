import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/level_data.dart';

Map<String, dynamic> valid() => {
      'id': 1,
      'name': 'T',
      'startingSun': 50,
      'availablePlants': ['peashooter'],
      'waves': [
        {'time': 20, 'zombie': 'walker', 'row': 2},
        {'time': 30, 'zombie': 'walker', 'row': 0, 'hugeWave': true},
      ],
    };

void main() {
  test('parses level_01.json from assets', () {
    final level = LevelData.parse(
      File('assets/levels/level_01.json').readAsStringSync(),
    );
    expect(level.id, 1);
    expect(level.startingSun, 150);
    expect(level.availablePlants, ['peashooter', 'sunflower']);
    expect(level.skySuns, isTrue);
    expect(level.waves.length, 6);
    expect(level.waves.last.time, 112);
    expect(level.waves[4].hugeWave, isTrue);
    expect(level.waves[0].hugeWave, isFalse);
  });
  test('defaults skySuns=true hugeWave=false', () {
    final level = LevelData.fromJson(valid());
    expect(level.skySuns, isTrue);
    expect(level.waves[0].hugeWave, isFalse);
    expect(level.waves[1].hugeWave, isTrue);
  });
  test('rejects unknown plant id', () {
    final j = valid()..['availablePlants'] = ['peashooter', 'cactus'];
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects unknown zombie id', () {
    final j = valid();
    (j['waves'] as List)[0]['zombie'] = 'dragon';
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects row out of range', () {
    final j = valid();
    (j['waves'] as List)[0]['row'] = 5;
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects empty waves', () {
    final j = valid()..['waves'] = [];
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects decreasing time, allows equal', () {
    final j = valid();
    (j['waves'] as List)[1]['time'] = 10;
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
    final k = valid();
    (k['waves'] as List)[1]['time'] = 20;
    expect(LevelData.fromJson(k).waves.length, 2);
  });
  test('validator lists all errors', () {
    final j = valid()
      ..['availablePlants'] = ['x']
      ..['waves'] = [
        {'time': 5, 'zombie': 'y', 'row': 9},
      ];
    final errors = LevelValidator.validate(LevelData.fromJsonUnchecked(j));
    expect(errors.length, 3);
  });
  test('parse handles JSON string', () {
    expect(LevelData.parse(jsonEncode(valid())).id, 1);
  });
  test('wrong-typed field throws LevelFormatException naming the field', () {
    final j = valid();
    (j['waves'] as List)[0]['row'] = '2';
    expect(
      () => LevelData.fromJson(j),
      throwsA(
        isA<LevelFormatException>().having(
          (e) => e.errors.join(), 'errors', contains('waves[0].row'),
        ),
      ),
    );
  });
  test('missing required field throws LevelFormatException', () {
    final j = valid()..remove('id');
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
    final k = valid();
    ((k['waves'] as List)[0] as Map).remove('time');
    expect(() => LevelData.fromJson(k), throwsA(isA<LevelFormatException>()));
  });
  test('non-string plant id throws LevelFormatException', () {
    final j = valid()..['availablePlants'] = ['peashooter', 7];
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('invalid JSON text throws LevelFormatException', () {
    expect(() => LevelData.parse('{oops'), throwsA(isA<LevelFormatException>()));
    expect(() => LevelData.parse('[1,2]'), throwsA(isA<LevelFormatException>()));
  });
}
