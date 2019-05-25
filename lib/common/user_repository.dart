import 'dart:io';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final _storage = new FlutterSecureStorage();

  Future<dynamic> authenticate({
    @required String username,
    @required String password,
  }) async {
    final url = "https://kurenivka.com.ua/wp-json/jwt-auth/v1/token";
    // Await the auth response, then decode the json-formatted responce to obtain token.
    final response = await http
        .post(url,
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: convert
                .jsonEncode({"username": username, "password": password}))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body);
    } else {
      throw (convert.jsonDecode(response.body));
    }
  }

  Future<String> requestAccess() async {
    final url = "https://kurenivka.com.ua/wp-json/residents/v1/token";

    if (!await hasToken()) return "";

    final token = await getToken();

    /// TODO: Implement Subscription validation via https://dk.uburners.com/wp-json/residents/v1/status
    /// before Token request

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: "Bearer " + token
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      final jsonResponse = convert.jsonDecode(response.body);
      throw (jsonResponse['token']);
    }
  }

  Future<void> deleteAuthToken() async {
    _storage.delete(key: "token");
    return;
  }

  Future<void> persistAuthToken(String token) async {
    if (token != null) {
      await _storage.write(key: "token", value: token);
    }
    return;
  }

  Future<void> persistDisplayName(String displayName) async {
    if (displayName != null) {
      await _storage.write(key: "userDisplayName", value: displayName);
    }
    return;
  }

  Future<void> deleteDisplayName() async {
    _storage.delete(key: "userDisplayName");
    return;
  }

  Future<void> persistPassCode(String code) async {
    if (code != null) {
      await _storage.write(key: "code", value: code);
    }
    return;
  }

  Future<String> getPassCode() async {
    return await _storage.read(
      key: "code",
    );
  }

  Future<String> getDisplayName() async {
    return await _storage.read(
      key: "userDisplayName",
    );
  }

  Future<bool> hasToken() async {
    return await _storage
        .read(
          key: "token",
        )
        .then((token) => token != null);
  }

  Future<String> getToken() async {
    return await _storage.read(
      key: "token",
    );
  }
}
