import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A cached network image widget for displaying currency flag images.
///
/// Uses [CachedNetworkImage] to cache images locally for better performance
/// and offline support. Provides loading and error placeholders.
class CachedFlagImage extends StatelessWidget {
  /// Creates a cached flag image widget.
  const CachedFlagImage({
    super.key,
    required this.flagUrl,
    this.width = 32,
    this.height = 32,
    this.borderRadius = 4,
    this.fit = BoxFit.cover,
  });

  /// The URL of the flag image.
  final String flagUrl;

  /// Width of the image.
  final double width;

  /// Height of the image.
  final double height;

  /// Border radius of the image container.
  final double borderRadius;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: flagUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const Icon(
            Icons.flag_outlined,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// A circular cached flag image widget.
///
/// Displays the flag inside a circular container with an optional border.
class CircularCachedFlagImage extends StatelessWidget {
  /// Creates a circular cached flag image widget.
  const CircularCachedFlagImage({
    super.key,
    required this.flagUrl,
    this.radius = 16,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// The URL of the flag image.
  final String flagUrl;

  /// Radius of the circular image.
  final double radius;

  /// Color of the border around the image.
  final Color? borderColor;

  /// Width of the border.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: flagUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: radius * 2,
            height: radius * 2,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: radius * 2,
            height: radius * 2,
            color: Colors.grey[200],
            child: const Icon(
              Icons.flag_outlined,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
