import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:zlbridge_flutter/ZLBridge.dart';
class flutter_webview_plugin_bridge extends ZLBridge {
  final _flutterWebViewPlugin = FlutterWebviewPlugin();
  get flutterWebViewPlugin => _flutterWebViewPlugin;
  //本地注入bridgeJs
  final injectBridgeJS;

  final Key key;
  final PreferredSizeWidget appBar;
  final String url;
  final Map<String, String> headers;
   Set<JavascriptChannel> javascriptChannels;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool mediaPlaybackRequiresUserGesture;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final List<Widget> persistentFooterButtons;
  final Widget bottomNavigationBar;
  final bool withZoom;
  final bool displayZoomControls;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final String localUrlScope;
  final bool scrollBar;
  final bool supportMultipleWindows;
  final bool appCacheEnabled;
  final bool hidden;
  final Widget initialChild;
  final bool allowFileURLs;
  final bool resizeToAvoidBottomInset;
  final String invalidUrlRegex;
  final bool geolocationEnabled;
  final bool withOverviewMode;
  final bool useWideViewPort;
  final bool debuggingEnabled;
  final bool ignoreSSLErrors;

  flutter_webview_plugin_bridge({
    this.injectBridgeJS = false,
    this.key,
    this.appBar,
    @required this.url,
    this.headers,
    this.javascriptChannels,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.mediaPlaybackRequiresUserGesture = true,
    this.enableAppScheme,
    this.userAgent,
    this.primary = true,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.withZoom,
    this.displayZoomControls,
    this.withLocalStorage,
    this.withLocalUrl,
    this.localUrlScope,
    this.withOverviewMode,
    this.useWideViewPort,
    this.scrollBar,
    this.supportMultipleWindows,
    this.appCacheEnabled,
    this.hidden = false,
    this.initialChild,
    this.allowFileURLs,
    this.resizeToAvoidBottomInset = false,
    this.invalidUrlRegex,
    this.geolocationEnabled,
    this.debuggingEnabled = false,
    this.ignoreSSLErrors = false,
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
  }
  WebviewScaffold buildWebviewScaffold(){
    return WebviewScaffold(key:key,appBar:appBar,url: url,headers: headers,javascriptChannels: javascriptChannels,
      withJavascript: withJavascript,clearCache: clearCache,clearCookies: clearCookies,mediaPlaybackRequiresUserGesture: mediaPlaybackRequiresUserGesture,
      enableAppScheme: enableAppScheme,userAgent: userAgent,primary: primary,persistentFooterButtons: persistentFooterButtons,bottomNavigationBar: bottomNavigationBar,
      withZoom: withZoom,displayZoomControls: displayZoomControls,withLocalStorage: withLocalStorage,withLocalUrl: withLocalUrl,localUrlScope: localUrlScope,
      withOverviewMode: withOverviewMode,useWideViewPort: useWideViewPort,scrollBar: scrollBar,supportMultipleWindows: supportMultipleWindows,appCacheEnabled: appCacheEnabled,
      hidden: hidden,initialChild: initialChild,allowFileURLs: allowFileURLs,resizeToAvoidBottomInset: resizeToAvoidBottomInset,invalidUrlRegex: invalidUrlRegex,
      geolocationEnabled: geolocationEnabled,debuggingEnabled: debuggingEnabled,ignoreSSLErrors: ignoreSSLErrors,);
  }
}