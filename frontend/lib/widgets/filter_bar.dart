import 'package:flutter/material.dart';

import '../constants/categories.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.location,
    required this.product,
    required this.vibe,
    required this.onLocationChanged,
    required this.onProductChanged,
    required this.onVibeChanged,
    super.key,
  });

  final String location;
  final String product;
  final String vibe;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onProductChanged;
  final ValueChanged<String> onVibeChanged;

  static const locations = ['Tunalı', 'Bahçelievler'];
  static const products = Categories.all;
  static const vibes = ['Ders Çalışma', 'Sohbet', 'Sessiz'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterSelect(
          label: 'Lokasyon',
          value: location,
          options: locations,
          onChanged: onLocationChanged,
        ),
        _FilterSelect(
          label: 'Ürün',
          value: product,
          options: products,
          onChanged: onProductChanged,
        ),
        _FilterSelect(
          label: 'Vibe',
          value: vibe,
          options: vibes,
          onChanged: onVibeChanged,
        ),
      ],
    );
  }
}

class _FilterSelect extends StatelessWidget {
  const _FilterSelect({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: Text(label),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }
}
