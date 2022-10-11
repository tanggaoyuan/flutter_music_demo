import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_music/config/config.dart';

class HttpRequest<T> implements Future<Response<T>> {
  late final Future<Response<T>> _promise;

  dynamic _data = {};
  final Map<String, dynamic> _queryParameters = {};
  final Options _options = Options();

  late final CancelToken _cancelToken;

  HttpRequest(Dio dio, String path) {
    _cancelToken = CancelToken();
    _promise = Future(() {
      return dio.request<T>(path,
          data: _data,
          queryParameters: _queryParameters,
          options: _options,
          cancelToken: _cancelToken);
    });
  }

  Future<T?> getData() {
    return _promise.then((value) => value.data);
  }

  HttpRequest<T> cancle() {
    _cancelToken.cancel();
    return this;
  }

  bool get isCanceled {
    return _cancelToken.isCancelled;
  }

  HttpRequest<T> send(dynamic data) {
    var oldData = _data;
    if (oldData is Map && data is Map) {
      oldData.addAll(data);
    } else {
      _data = data ?? {};
    }
    return this;
  }

  HttpRequest<T> query(Map<String, dynamic>? data) {
    if (data != null) {
      _queryParameters.addAll(data);
    }
    return this;
  }

  HttpRequest<T> setOptions({
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

  HttpRequest<T> setHeaders(Map<String, dynamic> headers) {
    if (_options.headers is Map) {
      _options.headers?.addAll(headers);
    } else {
      _options.headers = headers;
    }
    return this;
  }

  @override
  Stream<Response<T>> asStream() {
    return _promise.asStream();
  }

  @override
  Future<Response<T>> catchError(Function onError,
      {bool Function(Object error)? test}) {
    return _promise
        .catchError((error) =>
            Future<Response<T>>.error(HttpUtilException.create(error)))
        .catchError(onError, test: test);
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(Response<T> value) onValue,
      {Function? onError}) {
    return _promise.then(onValue, onError: onError);
  }

  @override
  Future<Response<T>> timeout(Duration timeLimit,
      {FutureOr<Response<T>> Function()? onTimeout}) {
    return _promise.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<Response<T>> whenComplete(FutureOr<void> Function() action) {
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

  HttpRequest<T> request<T>(path) {
    return HttpRequest<T>(_dio, path);
  }

  HttpRequest<T> get<T>(String path, {Map<String, dynamic>? params}) {
    return HttpRequest<T>(_dio, path).setOptions(method: 'get').query(params);
  }

  HttpRequest<T> post<T>(String path, {Map<String, dynamic>? data}) {
    return HttpRequest<T>(_dio, path).setOptions(method: 'post').send(data);
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
HttpUtil _axios = HttpUtil(baseUrl: serverBaseUrl);

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
      // options.headers['Authorization'] = 'Bearer xxxxxx';

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

void main() async {
  var result = await axios
      .post<Map>('http://localhost:3000/artist/list?type=1&area=96&initial=b')
      .getData();
  print(['result', result]);
}
