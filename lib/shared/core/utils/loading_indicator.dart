import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../core.dart';

class LoadingIndicator {
  Widget loadingIndicator(){
     return LoadingAnimationWidget.discreteCircle(
         color: SetColor.white(),
         size: 100
     );
  }
}