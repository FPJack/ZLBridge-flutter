import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
typedef JSCompletionHandler = void Function(Object obj,String error) ;
typedef JSCallbackHandler = void Function(Object obj,{bool end}) ;
typedef JSRegistHandler = void Function(Object obj,JSCallbackHandler callback) ;
typedef JSRegistUndefinedHandler = void Function(String name,Object obj,JSCallbackHandler callback);
class ZLBridge {
  static final String channelName = "ZLBridge";
  Map<String,JSRegistHandler> _registHanders;
  Map<String,JSCompletionHandler> _callHanders;
  JSRegistUndefinedHandler _undefinedHandler;
  bool _initLocalJS = false;
  Future<String> Function(String js) evaluateJavascriptFunc;
  ZLBridge({@required Future<String> Function(String js) evaluateJavascriptFunc}){
    this.evaluateJavascriptFunc = evaluateJavascriptFunc;
    _registHanders = Map();
    _callHanders = Map();
  }
  void handleJSMessage(String message) {
    if (evaluateJavascriptFunc == null) return;
    _ZLMsgBody msgBody = _ZLMsgBody.initWithMap(message);
    String name = msgBody.name;
    String callID = msgBody.callID;
    String error = msgBody.error;
    bool end = msgBody.end;
    String jsMethodId = msgBody.jsMethodId;
    Object body = msgBody.body;
    if(callID != null && callID.length > 0) {
      JSCompletionHandler callHandler = _callHanders[callID];
      if(callHandler != null){
        callHandler(body,error);
        if(end) _callHanders.remove(callID);
      }
      return;
    }
    JSRegistHandler registHandler = _registHanders[name];
    JSCallbackHandler callback = (Object result,{bool end = true}){
      Map map = Map();
      map["end"] = end?1:0;
      map["result"] = result;
      String jsonResult = json.encode(map);
      String js = "window.zlbridge._nativeCallback('$jsMethodId','$jsonResult');";
      evaluateJavascriptFunc(js);
    };
    if (registHandler != null){
      registHandler(body,callback);
      return;
    }
    if (_undefinedHandler != null){
      _undefinedHandler(name,body,callback);
      return;
    }
  }

  void injectLocalJS({void Function(Object error) callback})  {
    if(_initLocalJS) return callback(null);
    rootBundle.loadString('packages/zlbridge_flutter/assets/zlbridge.js').then((value){
      evaluateJavascriptFunc(value).then((value){
        _initLocalJS = true;
        if(callback != null) callback(null);
      }).catchError((onError){
        _initLocalJS = false;
        if(callback != null) callback(onError);
      });
    }).catchError((onError){
      if(callback != null) callback(onError);
      _initLocalJS = false;
    });
  }

  void registHandler(String methodName,JSRegistHandler registHandler){
    if(methodName == null || methodName.length == 0) return;
    _registHanders[methodName] = registHandler;
  }
  void registUndefinedHandler(JSRegistUndefinedHandler registHandler){
    _undefinedHandler = registHandler;
  }
  void removeRegistedHandlerWithMethodName(String name){
    _registHanders.remove(name);
  }
  void removeAllRegistedHandler(){
    _registHanders.clear();
  }
  void hasNativeMethod(String name,void Function(bool exit) callback){
    if (evaluateJavascriptFunc == null) return;
    if (callback == null) return;
    if(name == null || name.length == 0) callback(false);
    String js = "window.zlbridge._hasNativeMethod('$name');";
    evaluateJavascriptFunc(js).then((value){
      String v = "$value";
      callback(v == "1");
    }).catchError((onError){
      callback(false);
    });
  }
  void callHandler(String methodName,{List args,JSCompletionHandler completionHandler}){
    if (evaluateJavascriptFunc == null){
      if(completionHandler != null) completionHandler(null,"方法名不能为空");
      return;
    }
    args = args == null ? [] : args;
    Map map = Map();
    map["result"] = args;
    String ID;
    if(completionHandler != null){
      int id =  new DateTime.now().millisecondsSinceEpoch;
      ID = "$id";
      map["callID"] = ID;
      _callHanders[ID] = completionHandler;
    }
    String jsonResult = json.encode(map);
    String js = "window.zlbridge._nativeCall('$methodName','$jsonResult')";
    evaluateJavascriptFunc(js).then((value){
    }).catchError((onError){
      if (completionHandler != null) {
        completionHandler(null,onError.toString());
        _callHanders.remove(ID);
      }
    });
  }
  void destroyBridge(){
    _registHanders.clear();
    _callHanders.clear();
    _undefinedHandler = null;
  }
}
class _ZLMsgBody {
  String name;
  String jsMethodId;
  Object body;
  String callID;
  bool end;
  String error;
  _ZLMsgBody.initWithMap(String js) {
    Map<String, dynamic> map = jsonDecode(js);
    name = map["name"];
    jsMethodId = map["jsMethodId"];
    body = map["body"];
    callID = map["callID"];
    end = map["end"];
    error = map["error"];
  }
}