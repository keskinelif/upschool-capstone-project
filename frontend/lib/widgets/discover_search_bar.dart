import 'package:flutter/material.dart';

import '../theme/gri_theme.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: "Tunalı'da romantik bir akşam yemeği...",
              prefixIcon: const Icon(Icons.search, color: GriColors.muted),
              filled: true,
              fillColor: GriColors.onPrimary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GriRadii.md),
                borderSide: const BorderSide(color: GriColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GriRadii.md),
                borderSide: const BorderSide(color: GriColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GriRadii.md),
                borderSide: const BorderSide(color: GriColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: GriSpacing.sp2),
        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: GriColors.primary,
            foregroundColor: GriColors.onPrimary,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GriRadii.md),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GriColors.onPrimary,
                  ),
                )
              : const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
