import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
