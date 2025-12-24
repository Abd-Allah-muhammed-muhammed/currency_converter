import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/utils/colors.dart';

/// A primary action button with gradient background.
class ConvertButton extends StatelessWidget {
  const ConvertButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  /// The text to display on the button.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.cyan.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.dp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}
