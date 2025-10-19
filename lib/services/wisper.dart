import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:jose/jose.dart';

Future<String> transcribeAudio(File audioFile) async {
  // road json key
  final keyData = await rootBundle.loadString('assets/speech-to-text-key.json');
  final credentials = json.decode(keyData);

  final clientEmail = credentials['client_email'];
  final privateKey = credentials['private_key'];

  // get access token
  final jwtHeader = base64UrlEncode(utf8.encode(json.encode({
    'alg': 'RS256',
    'typ': 'JWT',
  })));

  final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final exp = iat + 3600; // 1時間有効

  final jwtClaimSet = base64UrlEncode(utf8.encode(json.encode({
    'iss': clientEmail,
    'scope': 'https://www.googleapis.com/auth/cloud-platform',
    'aud': 'https://oauth2.googleapis.com/token',
    'exp': exp,
    'iat': iat,
  })));

  final jwt = '$jwtHeader.$jwtClaimSet';

  // flutter pub add jose

  final signer = JsonWebSignatureBuilder()
    ..jsonContent = json.decode(utf8.decode(base64Url.decode(jwtClaimSet)))
    ..addRecipient(JsonWebKey.fromPem(privateKey), algorithm: 'RS256');
  final signedJwt = signer.build().toCompactSerialization();

  //token request
  final tokenResponse = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': signedJwt,
    },
  );

  if (tokenResponse.statusCode != 200) {
    throw Exception('Token request failed: ${tokenResponse.body}');
  }

  final accessToken = json.decode(tokenResponse.body)['access_token'];

  final bytes = await audioFile.readAsBytes();
  final base64Audio = base64Encode(bytes);

  //call text to speech
  final response = await http.post(
    Uri.parse('https://speech.googleapis.com/v1/speech:recognize'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "config": {
        "encoding": "LINEAR16",
        "languageCode": "ja-JP"
      },
      "audio": {"content": base64Audio}
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["results"]?[0]?["alternatives"]?[0]?["transcript"] ?? "";
  } else {
    throw Exception(
        "Speech-to-Text API error: ${response.statusCode} ${response.body}");
  }
}