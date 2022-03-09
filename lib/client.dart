import 'dart:convert';

import 'package:astroer/config.dart';
import 'package:http/http.dart' as http;

import 'astroer.dart';
import 'log.dart';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'dart:convert';

class AstroerClient extends http.BaseClient {
  static String nullValuePayload = "";
  final http.Client _inner;

  static final Map<String, String> _fixedHeader = {
    "User-Agent": "AstroerPushLib " + Astroer.astroerVersion,
    "Content-Type": "application/json; charset=utf-8"
  };

  AstroerClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _fixedHeader.forEach((key, value) {
      request.headers[key] = value;
    });
    return _inner.send(request);
  }

  static Future<Map> postJson(String url, Map<String, dynamic> params) async {
    var client = AstroerClient(http.Client());
    var uri = Uri.parse(url);
    var response = await client.post(uri,
        headers: sign(uri.path, params), body: jsonEncode(params), encoding: Encoding.getByName("utf-8"));

    var decodedResponse = jsonDecode(response.body) as Map;
    // Log.logger().i(decodedResponse);
    return decodedResponse;
  }

  static Map<String, String> sign(String path, Map<String, dynamic> params) {
    Map<String, String> r = {};
    var fluiden = "${AstroerConfig.appId}-${AstroerConfig.appUid}";
    var flutime = ((DateTime.now().millisecondsSinceEpoch / 1000).round()).toString();
    var flunoce = randString(32);

    r["X-FLU-IDEN"] = fluiden;
    r["X-FLU-TIME"] = flutime;
    r["X-FLU-NOCE"] = flunoce;

    var hpayload = fluiden + "," + AstroerConfig.secret + "," + flutime + "," + flunoce;
    var ppayload = paramPayload(params);
    var payload = hpayload + "." + path + "." + ppayload;

    // Log.logger().i(payload);
    r["X-FLU-SIGN"] = sha1hex(payload);

    return r;
  }

  static String paramPayload(Map<String, dynamic> params) {
    return _payloadValue(params);
  }

  static String _payloadMap(Map param) {
    if (param.isEmpty) {
      return "{}";
    }

    var keys = [];
    for (var key in param.keys) {
      keys.add(key);
    }
    keys.sort();
    var p = "{";
    for (var key in keys) {
      var val = _payloadValue(param[key]);
      p += "$key=$val&";
    }
    p = p.substring(0, p.length - 1);
    return p + "}";
  }

  static String _payloadList(List listv) {
    if (listv.isEmpty) {
      return "[]";
    }

    var p = "[";
    for (var i in listv) {
      p += _payloadValue(i) + ",";
    }
    p = p.substring(0, p.length - 1);
    return p + "]";
  }

  static String _payloadValue(dynamic val) {
    if (val == null) {
      return nullValuePayload;
    }

    if (val is String) {
      return val;
    }

    if (val is Map) {
      return _payloadMap(val);
    } else if (val is List) {
      return _payloadList(val);
    }

    return "$val";
  }

  static String randString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static String sha1hex(String s) {
    var d = sha1.convert(utf8.encode(s));
    return "$d";
  }
}
