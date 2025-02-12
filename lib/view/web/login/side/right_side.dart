import 'package:flutter/material.dart';
import '../../../../shared/core/theme/colors.dart';
import '../../../icon_pictures.dart';

class RightSide extends StatelessWidget {
  const RightSide({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.tabbarColor,
            ),
            child: Center(
              child: Image.asset(logo_app.logo_size500)
            ),
          ),
        ),
      ),
    );
  }
}
