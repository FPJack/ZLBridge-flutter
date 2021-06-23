import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
class webview_flutter_bridge extends ZLBridge {
  WebView _webView;
  WebView get webView => _webView;
  WebViewController _webViewController;
  webview_flutter_bridge({
  Key key, bool injectBridgeJS,
  WebViewCreatedCallback onWebViewCreated,
  String initialUrl,
  JavascriptMode javascriptMode = JavascriptMode.disabled,
  Set<JavascriptChannel> javascriptChannels,
  NavigationDelegate navigationDelegate,
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  PageStartedCallback onPageStarted,
  PageFinishedCallback onPageFinished,
  WebResourceErrorCallback onWebResourceError,
  bool debuggingEnabled = false,
  bool gestureNavigationEnabled = false,
  String userAgent,
  AutoMediaPlaybackPolicy initialMediaPlaybackPolicy =
      AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
 }){
    JavascriptChannel javascriptChannel = JavascriptChannel(name: ZLBridge.channelName, onMessageReceived: (JavascriptMessage message) {
        handleJSMessage(message.message);
    });
    if(javascriptChannels == null){
      javascriptChannels = {javascriptChannel};
    }else{
      javascriptChannels.add(javascriptChannel);
    }
    WebViewCreatedCallback createdCallback = (webViewController){
     this._webViewController = webViewController;
     onWebViewCreated(webViewController);
    };
    PageFinishedCallback finishedCallback = (url) {
      if(injectBridgeJS) injectLocalJS();
      onPageStarted(url);
    };
    evaluateJavascriptAction((js) => _webViewController.evaluateJavascript(js));
  _webView = WebView(
   key: key,
  initialUrl: initialUrl,
  javascriptMode: javascriptMode,
  navigationDelegate: navigationDelegate,
  gestureRecognizers: gestureRecognizers,
  onPageStarted: onPageStarted,
  onPageFinished: finishedCallback,
  onWebResourceError: onWebResourceError,
  debuggingEnabled: debuggingEnabled,
  javascriptChannels: javascriptChannels,
   onWebViewCreated: createdCallback,
  gestureNavigationEnabled: gestureNavigationEnabled,
  userAgent: userAgent,
  initialMediaPlaybackPolicy: initialMediaPlaybackPolicy,);
 }
}