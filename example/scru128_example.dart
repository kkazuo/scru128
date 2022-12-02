import 'package:scru128/scru128.dart';

void main() {
  var scru128id = Scru128Generator();
  for (final id in scru128id) {
    print(id);
  }
}
