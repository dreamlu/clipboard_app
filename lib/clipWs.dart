import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:clipboard/util/result/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketRoute extends StatefulWidget {
  @override
  _WebSocketRouteState createState() => new _WebSocketRouteState();
}

class _WebSocketRouteState extends State<WebSocketRoute> {
  TextEditingController _controller = new TextEditingController.fromValue(
    // 默认值
    TextEditingValue(text: 'ws://'),
  );

  static IOWebSocketChannel channel;
  String _text = "";
  String _clipContent = "";

  String api = "ws://192.168.31.105:9001";
  String url = '/api/clip';

  @override
  void initState() {
    super.initState();
    //创建websocket连接
    channel = new IOWebSocketChannel.connect(api + url);
  }

  void changeState() {
    channel.sink.close();
    channel = new IOWebSocketChannel.connect(api + url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("剪切板共享"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: '输入局域网地址'),
              ),
            ),
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                //网络不通会走到这
                if (snapshot.hasError) {
                  _text = "网络不通...";
                } else if (snapshot.hasData) {
                  _text = "websocket连接成功...";
                  Clipboard.setData(ClipboardData(text: snapshot.data));
                } else {
                  _text = "websocket连接成功...";
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(_text),
                );
              },
            ),
            StreamBuilder(
              stream: Clip.clipboard(),
              builder: (context, s) {
                //网络不通会走到这
                if (s.hasError) {
                  _clipContent = "app剪切板监听err..." + s.error.toString();
                } else if (s.hasData) {
                  _clipContent = s.data;
                  // 发送本地剪切板数据到server
                  if (s.data != _clipContent) {
                    _clipContent = s.data;
                    sendMessage(_clipContent);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Text(_clipContent),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: '确定',
        child: Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      //sendMessage(_controller.text);
      api = _controller.text;
      changeState();
    }
  }

  void sendMessage(dynamic msg) {
    channel.sink.add(msg);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
