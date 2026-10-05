import 'package:flutter/material.dart';

import '../home_providers.dart';

class ExerciseArtwork extends StatelessWidget {
  const ExerciseArtwork({
    super.key,
    required this.area,
    this.image,
    this.size = 96,
  });
  final String area;
  final String? image;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        image ?? areaAsset(area),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => Image.asset(
          areaAsset(area),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    ),
  );
}
