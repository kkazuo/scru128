import 'package:scru128/scru128.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final scru128 = Scru128Generator();
    final scru128s = Scru128Generator.withSecureRandom();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(Scru128Id().toString().length, 25);

      expect(scru128.first.toString().length, 25);
      expect(scru128s.first.toString().length, 25);

      expect(scru128.take(10).toList().length, 10);
      expect(scru128.take(10).toSet().toList().length, 10);
      expect(scru128s.take(10).toSet().toList().length, 10);
    });

    test('Comparable Test', () {
      final ids1 = scru128.take(10).toList();
      var ids2 = ids1.map((x) => x).toList().reversed.toList();
      ids2.sort();
      expect(ids1, ids2);
    });

    test('Special ID Test', () {
      expect(Scru128Generator.withTimestamp(0).current.isSpecial, true);
      expect(Scru128Generator.withTimestamp(281474976710655).current.isSpecial,
          true);
    });
  });
}
