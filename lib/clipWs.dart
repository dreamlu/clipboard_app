import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketRoute extends StatefulWidget {
  @override
  _WebSocketRouteState createState() => new _WebSocketRouteState();
}

class _WebSocketRouteState extends State<WebSocketRoute>
    with WidgetsBindingObserver {
  TextEditingController _controller = new TextEditingController.fromValue(
    // 默认值
    TextEditingValue(text: 'ws://'),
  );

  String _text = "";
  String _clipContent = "";

  @override
  void initState() {
    super.initState();
    //创建websocket连接
    Clip.init();
    WidgetsBinding.instance.addObserver(this);
  }

  void changeState() {
    Clip.newClip();
    setState(() {}); // 重新加载
    sendMessage(_clipContent);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
//        Clip.monitorClose();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
//        Clip.monitor();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
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
                    decoration: InputDecoration(
                        labelText: '输入局域网地址'), // \neg:ws://192.168.31.105:9001
                  ),
                ),
                StreamBuilder(
                  stream: Clip.channel.stream,
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
        ));
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      //sendMessage(_controller.text);
      Clip.api = _controller.text;
      changeState();
    }
  }

  void sendMessage(dynamic msg) {
    Clip.channel.sink.add(msg);
  }

  @override
  void dispose() {
    Clip.channel.sink.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
