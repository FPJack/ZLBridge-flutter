import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPlugin extends StatefulWidget {
  @override
  _WebViewPluginState createState() => _WebViewPluginState();
}
class _WebViewPluginState extends State<WebViewPlugin> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  ZLBridge bridge;
  Timer timer;
  String url = "";
  JavascriptChannel jsChannel(){
    return
      JavascriptChannel(
          name: ZLBridge.channelName,
          onMessageReceived: (JavascriptMessage message) {
            bridge.handleJSMessage(message.message);
          });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/files/index.html').then((value){
      this.setState(() {
        url = Uri.dataFromString(value,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString();
      });
    });
    flutterWebViewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        this.bridge.injectLocalJS();
      }
    });
    ZLBridge bridge = ZLBridge(evaluateJavascriptFunc:(String js){
      return flutterWebViewPlugin.evalJavascript(js);
    });
    //定义test事件
    bridge.registHandler("test", (obj, callback) {
      callback(obj,end:true);
    });
    //未定义的事件名都会走这
    bridge.registUndefinedHandler((name, obj, callback) {
      print("$name" + "$obj");
    });
    //连续回调js
    bridge.registHandler("upload", (obj, callback) {
      if(timer != null) timer.cancel();
      int time = 0;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        time += 10;
        if(time == 100){
          timer.cancel();
          callback("$time%");
        }else{
          callback("$time%",end:false);
        }
      });
    });
    this.bridge = bridge;
  }
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        javascriptChannels: [jsChannel()].toSet(),
        url: url,
        appBar:  AppBar(title: Text("flutter_webview_plugin"),)
    );
  }
}
