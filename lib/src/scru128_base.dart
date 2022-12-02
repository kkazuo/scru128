/*
Copyright 2022 Koga Kazuo (koga.kazuo@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
import 'dart:collection';
import 'dart:math';

const _int24Max = 16777216;
const _int32Max = 4294967296;
const _int48Max = 281474976710656;
final _i24 = BigInt.from(_int24Max);
final _i32 = BigInt.from(_int32Max);

final _gen = Scru128Generator();

/// SCRU128: Sortable, Clock and Random number-based Unique identifier
class Scru128Id implements Comparable<Scru128Id> {
  final int _timestamp;
  final int _counterHi;
  final int _counterLo;
  final int _entropy;
  late final String _asString = _toString();

  /// Generates a new SCRU128 ID object.
  factory Scru128Id() {
    _gen.moveNext();
    return _gen.current;
  }
  Scru128Id._(
      this._timestamp, this._counterHi, this._counterLo, this._entropy) {
    if (_timestamp < 0 || _int48Max <= _timestamp) {
      throw RangeError(
          "timestamp must be from 0 to ${_int48Max - 1}, inclusive");
    }
  }

  int get timestamp => _timestamp;
  int get counterHi => _counterHi;
  int get counterLo => _counterLo;
  int get entropy => _entropy;

  /// true if this is the [Special-purpose IDs](https://github.com/scru128/spec#special-purpose-ids).
  bool get isSpecial => timestamp == 0 || timestamp == (_int48Max - 1);

  @override
  String toString() => _asString;

  String _toString() {
    final t = BigInt.from(_timestamp) * _i24 * _i24 * _i32;
    final h = BigInt.from(_counterHi) * _i24 * _i32;
    final l = BigInt.from(_counterLo) * _i32;
    final e = BigInt.from(_entropy);
    return (t + h + l + e).toRadixString(36).toUpperCase().padLeft(25, '0');
  }

  @override
  int get hashCode =>
      _timestamp.hashCode ^
      _counterHi.hashCode ^
      _counterLo.hashCode ^
      _entropy.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Scru128Id &&
      _timestamp == other._timestamp &&
      _counterHi == other._counterHi &&
      _counterLo == other._counterLo &&
      _entropy == other._entropy;

  bool operator <(Scru128Id other) =>
      _timestamp < other._timestamp ||
      (_timestamp == other._timestamp &&
          (_counterHi < other.counterHi ||
              (_counterHi == other._counterHi &&
                  (_counterLo < other.counterLo ||
                      (_counterLo == other._counterLo &&
                          _entropy < other._entropy)))));

  bool operator <=(Scru128Id other) =>
      _timestamp < other._timestamp ||
      (_timestamp == other._timestamp &&
          (_counterHi < other.counterHi ||
              (_counterHi == other._counterHi &&
                  (_counterLo < other.counterLo ||
                      (_counterLo == other._counterLo &&
                          _entropy <= other._entropy)))));

  @override
  int compareTo(Scru128Id other) {
    if (this < other) return -1;
    if (this == other) return 0;
    return 1;
  }
}

/// SCRU128 ID generator
class Scru128Generator
    with IterableMixin<Scru128Id>
    implements Iterator<Scru128Id> {
  Random _random;
  int _timestamp;
  int _timestampHi;
  int _counterHi;
  int _counterLo;
  int _entropy;

  Scru128Generator() : this.withRandom(Random());
  Scru128Generator.withSecureRandom() : this.withRandom(Random.secure());
  Scru128Generator.withRandom(Random random)
      : this.withRandomAndTimestamp(
            random, DateTime.now().millisecondsSinceEpoch);
  Scru128Generator.withTimestamp(int timestamp)
      : this.withRandomAndTimestamp(Random(), timestamp);
  Scru128Generator.withRandomAndTimestamp(this._random, this._timestamp)
      : _timestampHi = _timestamp,
        _counterHi = _random.nextInt(_int24Max),
        _counterLo = _random.nextInt(_int24Max),
        _entropy = _random.nextInt(_int32Max) {
    if (_timestamp < 0 || _int48Max <= _timestamp) {
      throw RangeError(
          "timestamp must be from 0 to ${_int48Max - 1}, inclusive");
    }
  }
  Scru128Generator._clone(Scru128Generator other)
      : _random = other._random,
        _timestamp = other._timestamp,
        _timestampHi = other._timestampHi,
        _counterHi = other._counterHi,
        _counterLo = other._counterLo,
        _entropy = other._entropy;

  void _next() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_timestamp == now) {
      _counterLo += 1;
      if (_counterLo == _int24Max) {
        _counterHi += 1;
        if (_counterHi == _int24Max) {
          _timestamp += 1;
          _counterHi = 0;
          _counterLo = _random.nextInt(_int24Max);
        } else {
          _counterLo = 0;
        }
        _timestampHi = _timestamp;
      }
    } else {
      if ((now - _timestampHi).abs() >= 990) {
        _timestampHi = now;
        _counterHi = _random.nextInt(_int24Max);
      }
      _counterLo = _random.nextInt(_int24Max);
      _timestamp = now;
    }
    _entropy = _random.nextInt(_int32Max);
  }

  @override
  get current => Scru128Id._(_timestamp, _counterHi, _counterLo, _entropy);

  @override
  bool moveNext() {
    _next();
    return true;
  }

  @override
  get iterator => Scru128Generator._clone(this);

  @override
  bool get isEmpty => false;

  @override
  int get length => 9007199254740991;
}
