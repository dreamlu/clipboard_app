import 'dart:async';

import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

// clipboard
class Clip {
  static String clipContent = "";
  static String clipContentT = ""; // tmp

  static IOWebSocketChannel channel; // websocket
  static String api = "ws://192.168.31.105:9001";
  static String url = '/api/clip';

  // 后台定时器
  static Timer _timer;

  // 剪切板流定时监听
  static Stream<String> clipboard() {
//    return Stream.fromFuture(getClipBoardData());
    return Stream.periodic(Duration(seconds: 1), (content) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value == null) {
//          print("后台剪切板数据监听失败");
        } else {
          clipContent = value.text;
        }
      });

      return clipContent;
    });
  }

  // android 10以后限制无法访问,拜拜了您嘞~
  // 后台剪切板监听任务
  static monitor() {
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value == null) {
          print("[monitor]后台剪切板数据监听失败");
        } else {
          clipContentT = value.text;
          print("[monitor]剪切板数据" + clipContent);
          if (clipContentT != clipContent) {
            clipContent = clipContentT;
            sendMessage(clipContent);
          }
        }
      });
    });
  }

  static monitorClose() {
    if (_timer != null) {
      // 页面销毁时触发定时器销毁
      if (_timer.isActive) {
        // 判断定时器是否是激活状态
        _timer.cancel();
      }
    }
  }

  // ==== websocket 相关操作=====
  // ===========================
  static init() {
    channel = new IOWebSocketChannel.connect(api + url);
  }

  static newClip() {
    channel.sink.close();
    channel = new IOWebSocketChannel.connect(api + url);
  }

  static sendMessage(dynamic msg) {
    channel.sink.add(msg);
  }

//  static Future<String> getClipBoardData() async {
//    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
//    print(data.text);
//    return data.text;
//  }
}
