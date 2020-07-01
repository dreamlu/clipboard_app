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
  TextEditingController _controller = new TextEditingController();
  static IOWebSocketChannel channel;
  String _text = "";
  String _clipContent = "";

  @override
  void initState() {
    //创建websocket连接
    channel =
        new IOWebSocketChannel.connect('ws://192.168.31.105:9001/api/clip');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clipboard Websocket"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                //网络不通会走到这
                if (snapshot.hasError) {
                  _text = "网络不通...";
                } else if (snapshot.hasData) {
//                  Map res = json.decode(snapshot.data);
//                  var list = getResultList(res);
                  print("接收的剪切板数据2.1:" + snapshot.data);
                  _text = snapshot.data;
                  print("接收的剪切板数据2:" + _text);
                  Clipboard.setData(ClipboardData(text: _text));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(_text),
                );
              },
            ),
            StreamBuilder(
              stream: Clip.monitor(),
              builder: (context, s) {
                //网络不通会走到这
                if (s.hasError) {
                  _clipContent = "未连接...";
                } else if (s.hasData) {
                  _clipContent = s.data;
                  // 发送本地剪切板数据
                  if (_clipContent != "") {
                    print("发送的剪切板数据:" + _clipContent);
//                    Clipboard.setData(ClipboardData(text: _clipContent));
                    sendMessage(_clipContent);
                    print("发送的剪切板数据S:" + _clipContent);
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
        tooltip: '发送',
        child: Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      sendMessage(_controller.text);
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
