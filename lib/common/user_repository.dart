import 'dart:io';
import 'dart:convert' as convert;
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final _storage = new FlutterSecureStorage();

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    final url = "https://uburners.com/wp-json/jwt-auth/v1/token";

    ///Override with correct creds.
    // username = 'tusmenkoe@gmail.com';
    // password = 'udaffcom2';
    // Await the auth response, then decode the json-formatted responce to obtain token.
    final response = await http.post(url,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: convert.jsonEncode({"username": username, "password": password}));
    if (response.statusCode == 200) {
      await persistUsername(username);
      final jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse['token'];
    } else {
      final jsonResponse = convert.jsonDecode(response.body);
      throw (jsonResponse);
    }
  }

  Future<String> requestAccess() async {
    final url = "https://app-blackbox.herokuapp.com/setGuId";
    final username = await getUsername();

    /// Await access GUID code
    final response = await http.post(url,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: convert.jsonEncode({"user_data": username}));
    if (response.statusCode == 200) {
      /// Mocked GUID generation to get random guid each refresh.
      /// var uuid = new Uuid();
      // return uuid.v4();
      return response.body;
    } else {
      final jsonResponse = convert.jsonDecode(response.body);
      throw (jsonResponse['message']);
    }
  }

  Future<void> deleteToken() async {
    /// remove token from secure keychain
    _storage.delete(key: "token");
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to secure keychain
    if (token != null) {
      await _storage.write(key: "token", value: token);
    }
    return;
  }

  Future<void> persistUsername(String username) async {
    /// write to secure keychain
    if (username != null) {
      await _storage.write(key: "username", value: username);
    }
    return;
  }

  Future<void> persistPassCode(String code) async {
    /// write to secure keychain
    if (code != null) {
      await _storage.write(key: "code", value: code);
    }
    return;
  }

  Future<String> getPassCode() async {
    /// write to secure keychain
    return await _storage.read(
      key: "code",
    );
  }

  Future<String> getUsername() async {
    /// write to secure keychain
    return await _storage.read(
      key: "username",
    );
  }

  Future<bool> hasToken() async {
    /// read from secure keychain
    return await _storage
        .read(
          key: "token",
        )
        .then((token) => token != null);
  }

  Future<String> getToken() async {
    /// read from secure keychain
    return await _storage.read(
      key: "token",
    );
  }
}
