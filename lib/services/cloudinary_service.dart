import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = 'dew8dbsgv';
  final String apiKey = '945639635579818';
  final String apiSecret = '';
  final String uploadPreset = 'AutoHub';

  Future<String> uploadImage(Uint8List imageBytes) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'upload.jpg',
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Falha ao fazer upload da imagem');
    }
  }
}