import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:retroshare/model/account.dart';

import 'package:retroshare/model/auth.dart';

import 'account.dart';

Future<bool> isAuthTokenValid() async {
  final String path =
      '$RETROSHARE_SERVICE_PREFIX/rsJsonApi/getAuthorizedTokens';
  print(path);
  final response = await http.get(path, headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200) {
    return true;
  } else
    return false;
}

Future<bool> checkExistingAuthTokens(String locationId, String password) async {
  final response = await http.get(
      '$RETROSHARE_SERVICE_PREFIX/rsJsonApi/getAuthorizedTokens',
      headers: {
        HttpHeaders.authorizationHeader:
            makeAuthHeader(locationId, authToken.password)
      });

  if (response.statusCode == 200) {
    for (LinkedHashMap<String, dynamic> token
        in json.decode(response.body)['retval']) {
      if (token['key'] + ":" + token['value'] == authToken.toString())
        return true;
    }
    await authorizeNewToken(locationId, password);
    return true;
  } else if (response.statusCode == 401) {
    return false;
  } else
    throw Exception('Failed to load response');
}

void authorizeNewToken(String locationId, String password) async {
  final response = await http.post(
      '$RETROSHARE_SERVICE_PREFIX/rsJsonApi/authorizeUser',
      body: json.encode({'token': '$authToken'}),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$locationId:$password'))
      });

  print("hello ${response.body}");

  if (response.statusCode == 200) {
    return;
  } else
    throw Exception('Failed to load response');
}
