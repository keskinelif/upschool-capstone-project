import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../theme/gri_theme.dart';

class VenueFilterSheet extends StatefulWidget {
  const VenueFilterSheet({
    required this.initialLocation,
    required this.initialPrice,
    required this.onApply,
    super.key,
  });

  final String? initialLocation;
  final String? initialPrice;
  final void Function({String? location, String? price}) onApply;

  static Future<void> show(
    BuildContext context, {
    required String? initialLocation,
    required String? initialPrice,
    required void Function({String? location, String? price}) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GriColors.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GriRadii.xl)),
      ),
      builder: (_) => VenueFilterSheet(
        initialLocation: initialLocation,
        initialPrice: initialPrice,
        onApply: onApply,
      ),
    );
  }

  @override
  State<VenueFilterSheet> createState() => _VenueFilterSheetState();
}

class _VenueFilterSheetState extends State<VenueFilterSheet> {
  String? _location;
  String? _price;

  @override
  void initState() {
    super.initState();
    _location = widget.initialLocation;
    _price = widget.initialPrice;
  }

  void _clear() {
    setState(() {
      _location = null;
      _price = null;
    });
  }

  void _apply() {
    widget.onApply(location: _location, price: _price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          GriSpacing.sp6,
          GriSpacing.sp4,
          GriSpacing.sp6,
          GriSpacing.sp6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GriColors.border,
                  borderRadius: BorderRadius.circular(GriRadii.full),
                ),
              ),
            ),
            const SizedBox(height: GriSpacing.sp6),
            Text('Filtrele', style: GriTheme.h1()),
            const SizedBox(height: GriSpacing.sp6),
            Text(
              'KONUM',
              style: Theme.of(context).inputDecorationTheme.labelStyle,
            ),
            const SizedBox(height: GriSpacing.sp2),
            Wrap(
              spacing: GriSpacing.sp2,
              runSpacing: GriSpacing.sp2,
              children: [
                _FilterChip(
                  label: 'Tümü',
                  active: _location == null,
                  onTap: () => setState(() => _location = null),
                ),
                ...VenueFilters.locations.map(
                  (location) => _FilterChip(
                    label: location,
                    active: _location == location,
                    onTap: () => setState(() => _location = location),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GriSpacing.sp6),
            Text(
              'PAHALILIK',
              style: Theme.of(context).inputDecorationTheme.labelStyle,
            ),
            const SizedBox(height: GriSpacing.sp2),
            Wrap(
              spacing: GriSpacing.sp2,
              runSpacing: GriSpacing.sp2,
              children: [
                _FilterChip(
                  label: 'Tümü',
                  active: _price == null,
                  onTap: () => setState(() => _price = null),
                ),
                ...VenueFilters.priceLevels.map(
                  (price) => _FilterChip(
                    label: price,
                    active: _price == price,
                    onTap: () => setState(() => _price = price),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GriSpacing.sp6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GriColors.secondary,
                      side: const BorderSide(color: GriColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GriRadii.full),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: GriSpacing.sp3),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: GriColors.primary,
                      foregroundColor: GriColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GriRadii.full),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? GriColors.primary : GriColors.onPrimary,
      borderRadius: BorderRadius.circular(GriRadii.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GriRadii.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GriRadii.full),
            border: Border.all(
              color: active ? GriColors.primary : GriColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GriTheme.caption().copyWith(
              fontWeight: FontWeight.w500,
              color: active ? GriColors.onPrimary : GriColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
