import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
class flutter_webview_plugin_bridge extends ZLBridge {
  WebviewScaffold _webviewScaffold;
  WebviewScaffold get webviewScaffold => _webviewScaffold;
  final _flutterWebViewPlugin = FlutterWebviewPlugin();
  get flutterWebViewPlugin => _flutterWebViewPlugin;
  flutter_webview_plugin_bridge({
    bool injectBridgeJS,
    Key key,
    PreferredSizeWidget appBar,
    @required String url,
    Map<String, String> headers,
    Set<JavascriptChannel> javascriptChannels,
    bool withJavascript,
    bool clearCache,
    bool clearCookies,
    bool mediaPlaybackRequiresUserGesture = true,
    bool enableAppScheme,
    String userAgent,
    bool primary = true,
    List<Widget> persistentFooterButtons,
    Widget bottomNavigationBar,
    bool withZoom,
    bool displayZoomControls,
    bool withLocalStorage,
    bool withLocalUrl,
    String localUrlScope,
    bool withOverviewMode,
    bool useWideViewPort,
    bool scrollBar,
    bool supportMultipleWindows,
    bool appCacheEnabled,
    bool hidden = false,
    Widget initialChild,
    bool allowFileURLs,
    bool resizeToAvoidBottomInset = false,
    String invalidUrlRegex,
    bool geolocationEnabled,
    bool debuggingEnabled = false,
    bool ignoreSSLErrors = false,
  }){
    JavascriptChannel javascriptChannel = JavascriptChannel(name: ZLBridge.channelName, onMessageReceived: (JavascriptMessage message) {
          handleJSMessage(message.message);
    });
    evaluateJavascriptAction((js) => flutterWebViewPlugin.evalJavascript(js));
    if(javascriptChannels == null){
      javascriptChannels = {javascriptChannel};
    }else{
      javascriptChannels.add(javascriptChannel);
    }
    flutterWebViewPlugin.onStateChanged.listen((viewState)  {
      if (viewState.type == WebViewState.finishLoad) injectBridgeJS ? injectLocalJS() :'';
    });
   _webviewScaffold = WebviewScaffold(key:key,appBar:appBar,url: url,headers: headers,javascriptChannels: javascriptChannels,
      withJavascript: withJavascript,clearCache: clearCache,clearCookies: clearCookies,mediaPlaybackRequiresUserGesture: mediaPlaybackRequiresUserGesture,
    enableAppScheme: enableAppScheme,userAgent: userAgent,primary: primary,persistentFooterButtons: persistentFooterButtons,bottomNavigationBar: bottomNavigationBar,
    withZoom: withZoom,displayZoomControls: displayZoomControls,withLocalStorage: withLocalStorage,withLocalUrl: withLocalUrl,localUrlScope: localUrlScope,
    withOverviewMode: withOverviewMode,useWideViewPort: useWideViewPort,scrollBar: scrollBar,supportMultipleWindows: supportMultipleWindows,appCacheEnabled: appCacheEnabled,
    hidden: hidden,initialChild: initialChild,allowFileURLs: allowFileURLs,resizeToAvoidBottomInset: resizeToAvoidBottomInset,invalidUrlRegex: invalidUrlRegex,
    geolocationEnabled: geolocationEnabled,debuggingEnabled: debuggingEnabled,ignoreSSLErrors: ignoreSSLErrors,);
  }
}