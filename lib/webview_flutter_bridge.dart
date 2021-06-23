import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
class webview_flutter_bridge extends ZLBridge {
  WebViewController _webViewController;
  WebViewCreatedCallback _createdCallback;
  PageFinishedCallback _finishedCallback;
  //本地注入bridgeJs

  final bool injectBridgeJS;
  final WebViewCreatedCallback onWebViewCreated;
  final String initialUrl;
  final JavascriptMode javascriptMode;
   Set<JavascriptChannel> javascriptChannels;
  final NavigationDelegate navigationDelegate;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final PageStartedCallback onPageStarted;
  final PageFinishedCallback onPageFinished;
  final WebResourceErrorCallback onWebResourceError;
  final bool debuggingEnabled;
  final bool gestureNavigationEnabled;
  final String userAgent;
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;
  final Key key;
   webview_flutter_bridge({
     this.key,
     this.injectBridgeJS = false,
    this.onWebViewCreated,
    this.initialUrl,
    this.javascriptMode = JavascriptMode.disabled,
    this.javascriptChannels,
    this.navigationDelegate,
    this.gestureRecognizers,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.debuggingEnabled = false,
    this.gestureNavigationEnabled = false,
    this.userAgent,
    this.initialMediaPlaybackPolicy =
        AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
  })  : assert(javascriptMode != null),
        assert(initialMediaPlaybackPolicy != null){
    JavascriptChannel javascriptChannel = JavascriptChannel(name: ZLBridge.channelName, onMessageReceived: (JavascriptMessage message) {
        handleJSMessage(message.message);
    });
    if(javascriptChannels == null){
      javascriptChannels =  {javascriptChannel};
    }else{
      javascriptChannels.add(javascriptChannel);
    }
     _createdCallback = (webViewController){
     this._webViewController = webViewController;
     onWebViewCreated(webViewController);
    };
     _finishedCallback = (url) {
      if(injectBridgeJS) injectLocalJS();
      onPageFinished(url);
    };
    evaluateJavascriptAction((js) => _webViewController.evaluateJavascript(js));
 }
 WebView buildWebView(){
     return WebView(
       key: key,
       initialUrl: initialUrl,
       javascriptMode: javascriptMode,
       navigationDelegate: navigationDelegate,
       gestureRecognizers: gestureRecognizers,
       onPageStarted: onPageStarted,
       onPageFinished: _finishedCallback,
       onWebResourceError: onWebResourceError,
       debuggingEnabled: debuggingEnabled,
       javascriptChannels: javascriptChannels,
       onWebViewCreated: _createdCallback,
       gestureNavigationEnabled: gestureNavigationEnabled,
       userAgent: userAgent,
       initialMediaPlaybackPolicy: initialMediaPlaybackPolicy,);
 }
}