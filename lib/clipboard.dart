import 'dart:async';

import 'package:flutter/services.dart';

// clipboard
class Clip {
  static String clipContent;
  static String clipContentT;

  static Stream<String> monitor() {
//    return Stream.fromFuture(getClipBoardData());
    return Stream.periodic(Duration(seconds: 1), (content) {
      Clipboard.getData('text/plain').then((value) {
//        print("剪切板内容3："+value.text);
        clipContentT = value.text;
      });

//      print('剪切板内容 ${clipContentT}' + ",以前的内容：${clipContent}");
      if (clipContent != clipContentT) {
        clipContent = clipContentT;
        return clipContent;
      }
      return "";
    });
  }

//  static Future<String> getClipBoardData() async {
//    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
//    print(data.text);
//    return data.text;
//  }
}
