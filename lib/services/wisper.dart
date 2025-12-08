import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:jose/jose.dart';

Future<String> transcribeAudio(File audioFile) async {
  final keyData = await rootBundle.loadString('assets/speech-to-text-key.json');
  final credentials = json.decode(keyData);

  final clientEmail = credentials['client_email'];
  final privateKey = credentials['private_key'];

  final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final exp = iat + 3600;

  final jwtClaimSet = base64UrlEncode(utf8.encode(json.encode({
    'iss': clientEmail,
    'scope': 'https://www.googleapis.com/auth/cloud-platform',
    'aud': 'https://oauth2.googleapis.com/token',
    'exp': exp,
    'iat': iat,
  })));

  final signer = JsonWebSignatureBuilder()
    ..jsonContent = json.decode(utf8.decode(base64Url.decode(jwtClaimSet)))
    ..addRecipient(JsonWebKey.fromPem(privateKey), algorithm: 'RS256');
  final signedJwt = signer.build().toCompactSerialization();

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

  final response = await http.post(
    Uri.parse('https://speech.googleapis.com/v1/speech:longrunningrecognize'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "config": {
        "encoding": "LINEAR16",
        "sampleRateHertz": 16000,
        "languageCode": "en-US"
      },
      "audio": {"content": base64Audio}
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Speech-to-Text API error: ${response.statusCode} ${response.body}");
  }

  final operationName = json.decode(response.body)['name'];
  Map<String, dynamic> resultData;

  while (true) {
    final opResponse = await http.get(
      Uri.parse('https://speech.googleapis.com/v1/operations/$operationName'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    resultData = json.decode(opResponse.body);

    if (resultData['done'] == true) break;
    await Future.delayed(const Duration(seconds: 1));
  }

  final transcript = resultData['response']?['results']?[0]?['alternatives']?[0]?['transcript'] ?? '';
  return transcript;
}
