import 'package:flutter/material.dart';

import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class RestaurantFormDialog extends StatefulWidget {
  /// null = mode tambah, terisi = mode edit.
  final Restaurant? initial;

  const RestaurantFormDialog({super.key, this.initial});

  @override
  State<RestaurantFormDialog> createState() => _RestaurantFormDialogState();
}

class _RestaurantFormDialogState extends State<RestaurantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _mapsUrlController;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _nameController = TextEditingController(text: r?.name);
    _categoryController = TextEditingController(text: r?.category);
    _addressController = TextEditingController(text: r?.address);
    _ratingController = TextEditingController(
      text: r == null ? '' : r.rating.toStringAsFixed(1),
    );
    _imageUrlController = TextEditingController(text: r?.imageUrl);
    _mapsUrlController = TextEditingController(text: r?.mapsUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    _mapsUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawRating = _ratingController.text.trim().replaceAll(',', '.');
    final double? rating = rawRating.isEmpty ? null : double.parse(rawRating);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final Restaurant result;
      if (_isEdit) {
        result = await _apiService.updateRestaurant(
          id: widget.initial!.id,
          name: _nameController.text,
          category: _categoryController.text,
          address: _addressController.text,
          rating: rating,
          imageUrl: _imageUrlController.text,
          mapsUrl: _mapsUrlController.text,
        );
      } else {
        result = await _apiService.createRestaurant(
          name: _nameController.text,
          category: _categoryController.text,
          address: _addressController.text,
          rating: rating,
          imageUrl: _imageUrlController.text,
          mapsUrl: _mapsUrlController.text,
        );
      }
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = friendlyError(e);
      });
    }
  }

  String? _required(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Restoran' : 'Tambah Restoran'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Restoran *'),
                validator: (v) => _required(v, 'Nama wajib diisi'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  hintText: 'Contoh: Ayam, Kopi, Warkop',
                ),
                validator: (v) => _required(v, 'Kategori wajib diisi'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat *'),
                validator: (v) => _required(v, 'Alamat wajib diisi'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ratingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rating (opsional)',
                  hintText: 'Contoh: 4.5',
                ),
                validator: (v) {
                  final raw = (v ?? '').trim().replaceAll(',', '.');
                  if (raw.isEmpty) return null;
                  final n = double.tryParse(raw);
                  if (n == null || n < 0 || n > 5) {
                    return 'Rating harus berupa angka 0.0 - 5.0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (opsional)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mapsUrlController,
                decoration: const InputDecoration(
                  labelText: 'Maps URL (opsional)',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
