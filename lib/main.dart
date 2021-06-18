import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'WebViewPlugin.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  ZLBridge bridge;
  WebViewController webVC;
  String jsEvent1Title = "调用js事件1";
  String jsEvent2Title = "调用js事件2";
  Timer timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ZLBridge bridge = ZLBridge(evaluateJavascriptFunc:(String js){
     return webVC.evaluateJavascript(js);
    });
    //定义test事件
    bridge.registHandler("test", (obj, callback) {
      callback(obj,true);
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
        callback("$time%",time == 100 ? true : false);
        if(time == 100) timer.cancel();
      });
    });
    this.bridge = bridge;
  }
  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: ZLBridge.channelName,
        onMessageReceived: (JavascriptMessage message) {
          bridge.handleJSMessage(message.message);
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
  Widget webview(BuildContext context){
    return Container(
      height: 300,
      child: WebView(
          initialUrl: "",
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          onWebViewCreated:(webVC){
            this.webVC = webVC;
            _loadLocalHtmlAndInjectJS();
          },
        onPageFinished: (url){
          //注入框架js
          bridge.injectLocalJS();
        },
      ),
    );
  }
  _loadLocalHtmlAndInjectJS() async {
    //加载本地html
    String filePath = 'assets/files/index.html';
    String fileHtmlContents = await rootBundle.loadString(filePath);
    webVC.loadUrl(Uri.dataFromString(fileHtmlContents,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            webview(context),
            RaisedButton(child: Text(jsEvent1Title),onPressed: (){
              bridge.callHandler("jsMethod",completionHandler:(obj,error){
                this.setState(() {
                  jsEvent1Title = (error == null) ? "成功调用JS事件1" : error;
                });
              });
            },),
            RaisedButton(child: Text(jsEvent2Title),onPressed: (){
              bridge.callHandler("jsMethodWithCallback",args: ["原生信息"],completionHandler:(obj,error){
                this.setState(() {
                  jsEvent2Title = (error == null) ? "成功调用JS事件2" : error;
                });
              });
            },),
            RaisedButton(child: Text("查看ZLBridge配合flutter_webview_plugin使用"),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return WebViewPlugin();
              }));
            },),

          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
