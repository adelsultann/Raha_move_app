import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/catalog_bootstrap_gate.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CatalogBootstrapGate(child: RahaMoveApp()),
    ),
  );
}
