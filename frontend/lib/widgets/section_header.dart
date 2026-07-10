import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showAll;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.showAll = true,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        if (showAll && onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
      ],
    );
  }
}
