[包管理网站](https://pub.flutter-io.cn/);

## future 异步处理

[消息循环机制](https://www.jianshu.com/p/7549b63a72d7)
[future基础](https://mp.weixin.qq.com/s/Tb0yyT2xPXizDUu1KjsiOA)
```dart
    Future(() {
        var _com = Completer();
        Timer(const Duration(seconds: 1), () {
            _com.complete("成功的回调");
        });
        return _com.future;
    }).then((value) {
        print(value);
    });

    Future(() {
        var _com = Completer();
        Timer(const Duration(seconds: 1), () {
            _com.completeError("失败的回调");
        });
        return _com.future;
    }).catchError((value) => print(value));

    var _com = Completer();
    Timer(const Duration(seconds: 1), () {
        _com.complete("complete回调");
    });
    _com.future.then((value) => print(value));

    // 1、complete回调
    // 2、成功的回调
    // 3、失败的回调
```
```dart
 factory Future(FutureOr<T> computation()) {
    _Future<T> result = new _Future<T>();
    Timer.run(() {
      try {
        result._complete(computation());
      } catch (e, s) {
        _completeWithErrorCallback(result, e, s);
      }
    });
    return result;
  }
```

##### 基础用法
```dart
    // 创建Future
    Future(() {
        print('创建Futter');
    })
        .then((value) => print('成功'))
        .catchError((error) => print('错误'))
        .whenComplete(() => print('最终都会执行'));

    // 构造方法会在一个microtask中完成。 优先级比较普通创建的Future高
    Future.value('1').then((value) => print(value)); // 1
    
    // 延时执行 可用来代替定时器
    Future.delayed(Duration(seconds: 3), () {
        return '延时2秒执行';
    }).then((value) => print(value));

    var task1 = Future(() => '任务1');
    var task2 = Future.delayed(const Duration(seconds: 3), () {
        return '任务2';
    });
    var task3 = Future.delayed(const Duration(seconds: 1), () {
        return '任务3';
    });
    // 等待所有任务执行完成,有一个异常就结束 [任务1, 任务2, 任务3]
    Future.wait([task1, task2, task3]).then(print).catchError(print);
    //第一个执行完成 任务1
    Future.any([task1, task2, task3]).then(print).catchError(print);


    // 在规定时间能为执行完，这抛异常
    Future.delayed(Duration(seconds: 5), () {
        return '网络请求5秒';
    }).timeout(Duration(seconds: 3)).then(print).catchError(print);


    // 同步执行，等到执行完后才走下一步  1,2,3
    print('1');
    Future.sync(() {
        print('2');
    });
    print('3');

    // 创建一个微任务执行的future与Future.value类似
     Future.microtask(() {
        print('microtask');
    });
```

## dio 网络请求工具
[基础使用](https://pub.flutter-io.cn/packages/dio);

#### dio封装
```dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_music/config/server.config.dart';

class HttpRequest implements Future {
  late final Future _promise;

  dynamic _data = {};
  final Map<String, dynamic> _queryParameters = {};
  final Options _options = Options();

  late final CancelToken _cancelToken;

  HttpRequest(Dio dio, String path) {
    _cancelToken = CancelToken();
    _promise = Future(() {
      return dio.request(path,
          data: _data,
          queryParameters: _queryParameters,
          options: _options,
          cancelToken: _cancelToken);
    });
  }

  HttpRequest cancle() {
    _cancelToken.cancel();
    return this;
  }

  bool get isCanceled {
    return _cancelToken.isCancelled;
  }

  HttpRequest send(dynamic data) {
    var oldData = _data;
    if (oldData is Map && data is Map) {
      oldData.addAll(data);
    } else {
      _data = data ?? {};
    }
    return this;
  }

  HttpRequest query(Map<String, dynamic>? data) {
    if (data != null) {
      _queryParameters.addAll(data);
    }
    return this;
  }

  HttpRequest setOptions({
    String? method,
    int? sendTimeout,
    int? receiveTimeout,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
  }) {
    if (contentType != null) {
      _options.contentType = contentType;
    }
    if (extra != null) {
      _options.extra = extra;
    }
    if (headers != null) {
      setHeaders(headers);
    }
    if (listFormat != null) {
      _options.listFormat = listFormat;
    }
    if (maxRedirects != null) {
      _options.maxRedirects = maxRedirects;
    }
    if (method != null) {
      _options.method = method;
    }
    if (receiveTimeout != null) {
      _options.receiveTimeout = receiveTimeout;
    }
    if (requestEncoder != null) {
      _options.requestEncoder = requestEncoder;
    }
    if (responseType != null) {
      _options.responseType = responseType;
    }
    if (sendTimeout != null) {
      _options.sendTimeout = sendTimeout;
    }
    if (validateStatus != null) {
      _options.validateStatus = validateStatus;
    }
    return this;
  }

  HttpRequest setHeaders(Map<String, dynamic> headers) {
    if (_options.headers is Map) {
      _options.headers?.addAll(headers);
    } else {
      _options.headers = headers;
    }
    return this;
  }

  @override
  Stream asStream() {
    return _promise.asStream();
  }

  @override
  Future catchError(Function onError, {bool Function(Object error)? test}) {
    return _promise
        .catchError((error) => Future.error(HttpUtilException.create(error)))
        .catchError(onError, test: test);
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(dynamic value) onValue,
      {Function? onError}) {
    return _promise.then(onValue, onError: onError);
  }

  @override
  Future timeout(Duration timeLimit, {FutureOr Function()? onTimeout}) {
    return _promise.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future whenComplete(FutureOr<void> Function() action) {
    return _promise.whenComplete(action);
  }
}

class HttpUtil {
  late Dio _dio;

  HttpUtil({
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    String? contentType,
    bool Function(int?)? validateStatus,
  }) {
    _dio = Dio(BaseOptions(receiveTimeout: 5000).copyWith(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        contentType: contentType,
        validateStatus: validateStatus));
  }

  HttpUtil addInterceptor({
    InterceptorSendCallback? onRequest,
    InterceptorSuccessCallback? onResponse,
    InterceptorErrorCallback? onError,
  }) {
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: onRequest, onResponse: onResponse, onError: onError));
    return this;
  }

  HttpRequest request(path) {
    return HttpRequest(_dio, path);
  }

  HttpRequest get(String path, {Map<String, dynamic>? params}) {
    return HttpRequest(_dio, path).setOptions(method: 'get').query(params);
  }

  HttpRequest post(String path, {Map<String, dynamic>? data}) {
    return HttpRequest(_dio, path).setOptions(method: 'post').send(data);
  }
}

enum HttpErrorLevel { system, network, general }

class HttpUtilException implements Exception {
  int code;
  String message;
  String path;
  dynamic body;
  HttpErrorLevel level;

  HttpUtilException(this.code, this.level, this.message, this.path, this.body);

  @override
  String toString() {
    return '''
      \n____________________________________________________\n
        [$path]: $code-$message\n
        [body]:${jsonEncode(body)}
      \n____________________________________________________\n
    ''';
  }

  toJson() {
    Map data = {};
    data["code"] = code;
    data["message"] = message;
    data["path"] = path;
    data["body"] = body;
    return data;
  }

  factory HttpUtilException.create(DioError error) {
    try {
      String path = error.requestOptions.path;
      dynamic body = error.response?.data ?? {};
      switch (error.type) {
        case DioErrorType.cancel:
          return HttpUtilException(
              -1, HttpErrorLevel.system, "请求取消", path, body);
        case DioErrorType.connectTimeout:
          return HttpUtilException(
              -1, HttpErrorLevel.system, "连接超时", path, body);
        case DioErrorType.sendTimeout:
          return HttpUtilException(
              -1, HttpErrorLevel.system, "请求超时", path, body);
        case DioErrorType.receiveTimeout:
          return HttpUtilException(
              -1, HttpErrorLevel.system, "响应超时", path, body);
        case DioErrorType.response:
          return HttpUtilException.createHttpStatusError(error);
        default:
          return HttpUtilException(
              -1, HttpErrorLevel.system, "服务器连接超时", path, body);
      }
    } catch (e) {
      return HttpUtilException(-1, HttpErrorLevel.system, e.toString(), "", {});
    }
  }

  factory HttpUtilException.createHttpStatusError(DioError error) {
    try {
      int errCode = error.response?.statusCode ?? 400;
      String path = error.requestOptions.path;
      dynamic body = error.response?.data ?? {};
      switch (errCode) {
        case 400:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "请求语法错误", path, body);
          }
        case 401:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "没有权限", path, body);
          }
        case 403:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "服务器拒绝执行", path, body);
          }
        case 404:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "无法连接服务器", path, body);
          }
        case 405:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "请求方法被禁止", path, body);
          }
        case 500:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "服务器内部错误", path, body);
          }
        case 502:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "无效的请求", path, body);
          }
        case 503:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "服务器挂了", path, body);
          }
        case 505:
          {
            return HttpUtilException(
                errCode, HttpErrorLevel.network, "不支持HTTP协议请求", path, body);
          }
        default:
          {
            return HttpUtilException(errCode, HttpErrorLevel.network,
                error.response?.statusMessage ?? '未知错误', path, body);
          }
      }
    } on Exception catch (_) {
      return HttpUtilException(-1, HttpErrorLevel.system, "未知错误", "", {});
    }
  }
}

// 请求类封装
// HttpUtil _axios = HttpUtil(baseUrl: ServerConfig.serverBaseUrl);
HttpUtil _axios = HttpUtil();

HttpUtil get axios {
  _axios.addInterceptor(
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      print('''
          -------------------------------------------------------------
          /n 请求地址: ${options.path}
          /n 请求参数-data:${options.data}
          /n 请求参数-params:${options.queryParameters}
           -------------------------------------------------------------
        ''');

      // 存储token
      options.headers['Authorization'] = 'Bearer xxxxxx';

      return handler.next(options);
    },
    onResponse: (e, handler) {
      print('''
        -------------------------------------------------------------
        /n 响应结果：${e.requestOptions.path}
        /n ${e.data.toString()}
        -------------------------------------------------------------
      ''');
      return handler.next(e);
    },
    onError: (e, handler) {
      if (CancelToken.isCancel(e)) {
        print('''
        -------------------------------------------------------------
          /n 响应结果：${e.requestOptions.path}
          /n 请求被取消
        -------------------------------------------------------------
        ''');
      } else {
        print('''
        -------------------------------------------------------------
        /n 响应结果：${e.requestOptions.path}
        /n statusCode:${e.response?.statusCode}
        /n message:${e.message}
        /n error:${e.error.toString()}
        -------------------------------------------------------------
      ''');
      }
      return handler.next(e);
    },
  );

  return _axios;
}

void main() {
  var a = axios.post('https://www.baidu.com/');
  a.catchError((error) {
    print(['error', error]);
  });
}

```

## 路由
```dart
import 'package:flutter/material.dart';
import 'package:flutter_music/pages/splash_page/splash_page.dart';
import 'package:flutter_music/pages/not_page/not_page.dart';

class RouterUtil {
  static String initialRoute = '/';

  static BuildContext? context;

  static final Map<String, Widget Function({Object? arguments})> routerViewMap =
      {
    "/": ({arguments}) => const Splash(),
    "/not": ({arguments}) => const Not(),
  };

  static Route<Widget> buildRouterView(RouteSettings setting) {
    return MaterialPageRoute(builder: (context) {
      RouterUtil.context = context;
      var build = routerViewMap[setting.name];
      if (build == null) {
        return const Not();
      }
      return build(arguments: setting.arguments);
    });
  }

  static void push(String path, Object arguments) {
    var content = RouterUtil.context;
    if (content == null) {
      return;
    }
    Navigator.of(content).pushNamed(path, arguments: arguments);
  }

  static void pop(String path) {
    var content = RouterUtil.context;
    if (content == null) {
      return;
    }
    Navigator.of(content).pop();
  }

  static void replace(Route oldRoute, Route newRoute) {
    var content = RouterUtil.context;
    if (content == null) {
      return;
    }
    Navigator.of(content).replace(oldRoute: oldRoute, newRoute: newRoute);
  }
}

```
