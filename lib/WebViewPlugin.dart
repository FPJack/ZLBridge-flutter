import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zlbridge/flutter_webview_plugin_bridge.dart';
class WebViewPlugin extends StatefulWidget {
  @override
  _WebViewPluginState createState() => _WebViewPluginState();
}
class _WebViewPluginState extends State<WebViewPlugin> {
  flutter_webview_plugin_bridge bridge;
  Timer timer;
  String url = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/files/index.html').then((value){
      this.setState(() {url = Uri.dataFromString(value, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();});
    });
  }
  flutter_webview_plugin_bridge initBridge(){
   var bridge = flutter_webview_plugin_bridge(
       injectBridgeJS: true,
       url: url,
       appBar:  AppBar(title: Text("flutter_webview_plugin"),));
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
   return bridge;
  }
  @override
  Widget build(BuildContext context) {
    this.bridge = initBridge();
    return this.bridge.buildWebviewScaffold();
  }
}
