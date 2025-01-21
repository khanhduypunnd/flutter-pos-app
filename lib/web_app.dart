import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';

import './shared/core/router.dart';


void main() {
  runApp(ModularApp(module: AppClientModule(), child: const WebAppWidget()));
}

class WebAppWidget extends StatelessWidget {
  const WebAppWidget({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp.router(
      title: 'Retail Perfume',
      routerConfig: Modular.routerConfig,
    );
  }
}