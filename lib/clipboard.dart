import 'dart:async';

import 'package:flutter/services.dart';

// clipboard
class Clip {
//  static String clipContent;
  static String clipContentT = "";

  static Stream<String> clipboard() {
//    return Stream.fromFuture(getClipBoardData());
    return Stream.periodic(Duration(seconds: 1), (content) {
      Clipboard.getData('text/plain').then((value) {
        clipContentT = value.text;
      });

      return clipContentT;
    });
  }
}
