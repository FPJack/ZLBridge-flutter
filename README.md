
## demo
下载包到本地，可选择android或者ios模拟器运行查看效果图
## 说明
ZLBridge-flutter是为原生(android,ios)webview与JS提供数据交互更简单方便的一个小插件工具，其数据交互的原理iOS是基于[userContentController addScriptMessageHandler]以及android是基于webView.addJavascriptInterface接口执行js代码为window初始化一个zlbridge对象，后续数据交互都是通过window.zlbridge对象来共享。ZLBridge-flutter并不提供webview页面展示，只负责处理原生与js数据交互，可配合webview_flutter，flutter_webview_plugin等等三方库使用。具体各端实现原理可查看对应平台的源码
[ZLBridge-iOS](https://github.com/FPJack/ZLBridge-iOS),
[ZLBridge-Android](https://github.com/FPJack/ZLBridge-Android),
[ZLBridge-JS](https://github.com/FPJack/ZLBridge-JS).

## 安装
```ruby
dependencies:
  zlbridge_flutter:
    git:
      url: https://github.com/FPJack/ZLBridge-flutter
      path: zlbridge_flutter
```
## 初始化 

### bridge
```Dart
ZLBridge bridge = ZLBridge(evaluateJavascriptFunc:(String js){
	 //调用对应三方库执行原生js的API接口， 
	 //flutter_webview_plugin:flutterWebViewPlugin.evalJavascript(js);
	 //webview_flutter:webVC.evaluateJavascript(js);
     return webVC.evaluateJavascript(js);
});

```
### JavascriptChannel
```Dart
//用对应三方库的JavascriptChannel添加ZLBridge的channelName，以及回调成功时调用bridge.handleJSMessage(message),bridge的registHandler就能接受相对应注册的事件通知
JavascriptChannel(
        name: ZLBridge.channelName,
        onMessageReceived: (JavascriptMessage message) {
          bridge.handleJSMessage(message.message);
});
```

## h5端zlbridge初始化(可选本地原生注入初始化，也可以由H5远程导入初始化)
原生初始化ZLBridge
```Dart
  bridge.injectLocalJS();
```
或者H5初始化ZLBridge
```JavaScript
//初始化完成后也可通过window.zlbridge拿zlbridge对象
 var zlbridge = require('zlbridge-js')
```

## 原生与JS交互

### JS调用原生test事件

#### 无参数
```JavaScript
window.ZLBridge.call('test',(arg) => {

});
```
#### 有参数参数
```JavaScript
window.ZLBridge.call('test',{key:"value"},(arg) => {

});
```
#### 原生注册test事件
```Java
bridge.registHandler("test", (obj, callback){
	  //true：jS调用一次test事件只能接受原生一次传值，false：JS一次事件可接受多次传值
      callback(obj,true);
});
```

### 原生调用js

#### 原生调用JS的jsMethod事件
```Dart
bridge.callHandler("jsMethod",args: ["原生信息"],completionHandler:(obj,error){
                
});
```

#### js注册jsMethod事件
```JavaScript
window.ZLBridge.register("jsMethod",(arg) => {
     return arg;
});
 ```
 或者
 ```JavaScript
window.ZLBridge.registerWithCallback("jsMethod",(arg,callback) => {
  //ture代表原生只能监听一次回调结果，false可以连续监听，默认传为true
  callback(arg,true);
});
  ```

## 通过本地注入JS脚本的，H5可以监听zlbridge初始化完成事件
```JavaScript
document.addEventListener('ZLBridgeInitReady', function() {
    consloe.log('ZLBridge初始化完成');
},false);
  ```
## ！！！！ flutter传给JS的值必须是可以json.encode转换的Object

## Author

范鹏, 2551412939@qq.com



## License

ZLBridge-flutter is available under the MIT license. See the LICENSE file for more info.