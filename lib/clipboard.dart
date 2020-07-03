import 'dart:async';

import 'package:flutter/services.dart';

// clipboard
class Clip {
//  static String clipContent;
  static String clipContent = "";

  static Stream<String> clipboard() {
//    return Stream.fromFuture(getClipBoardData());
    return Stream.periodic(Duration(seconds: 1), (content) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value == null) {
          print("后台剪切板数据监听失败");
          value = ClipboardData();
        } else {
          clipContent = value.text;
        }
      });

      return clipContent;
    });
  }

//  static Future<String> getClipBoardData() async {
//    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
//    print(data.text);
//    return data.text;
//  }
}
