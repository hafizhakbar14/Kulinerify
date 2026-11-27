import 'package:flutter_test/flutter_test.dart';
import 'package:kulinerify/utils/format.dart';

void main() {
  test('formatRupiah memakai pemisah ribuan titik', () {
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(500), 'Rp 500');
    expect(formatRupiah(15000), 'Rp 15.000');
    expect(formatRupiah(1250000), 'Rp 1.250.000');
  });
}
