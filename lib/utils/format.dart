/// 15000 -> "Rp 15.000"
String formatRupiah(int price) {
  final formatted = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $formatted';
}
