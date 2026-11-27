import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class MenuFormDialog extends StatefulWidget {
  /// null = mode tambah, terisi = mode edit.
  final Menu? initial;

  const MenuFormDialog({super.key, this.initial});

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  List<Restaurant> _restaurants = [];
  Restaurant? _selected;
  bool _isLoading = true;
  String? _loadError;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    _nameController = TextEditingController(text: m?.name);
    _priceController = TextEditingController(
      text: m == null ? '' : m.price.toString(),
    );
    _descriptionController = TextEditingController(text: m?.description);
    _imageUrlController = TextEditingController(text: m?.imageUrl);
    _loadRestaurants();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      final list = await _apiService.getRestaurants();
      if (!mounted) return;

      Restaurant? selected;
      final initial = widget.initial;
      if (initial != null) {
        for (final r in list) {
          if (r.id == initial.restaurantId) {
            selected = r;
            break;
          }
        }
      }

      setState(() {
        _restaurants = list;
        _selected = selected ?? (list.isNotEmpty ? list.first : null);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;

    final price = int.parse(_priceController.text.trim());

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final Menu result;
      if (_isEdit) {
        result = await _apiService.updateMenu(
          id: widget.initial!.id,
          restaurantId: _selected!.id,
          restaurantName: _selected!.name,
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
        );
      } else {
        result = await _apiService.createMenu(
          restaurantId: _selected!.id,
          restaurantName: _selected!.name,
          name: _nameController.text,
          price: price,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
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

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_loadError!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _loadError = null;
              });
              _loadRestaurants();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    if (_restaurants.isEmpty) {
      return const Text(
        'Tambahkan restoran terlebih dahulu sebelum menambah menu.',
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Restaurant>(
              initialValue: _selected,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Restoran *'),
              items: _restaurants
                  .map(
                    (r) => DropdownMenuItem<Restaurant>(
                      value: r,
                      child: Text(r.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Menu *'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama menu wajib diisi'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga (Rp) *',
                hintText: 'Contoh: 15000',
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null) return 'Harga wajib berupa angka';
                if (n <= 0) return 'Harga harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (opsional)',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_isLoading &&
        _loadError == null &&
        _selected != null &&
        !_isSubmitting;

    return AlertDialog(
      title: Text(_isEdit ? 'Edit Menu' : 'Tambah Menu'),
      content: _buildContent(),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: canSubmit ? _submit : null,
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
