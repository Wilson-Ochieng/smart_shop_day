import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'];
  static get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

  // For mobile (File)
  static Future<String?> uploadImage(File imageFile) async {
    try {
      debugPrint('Starting Cloudinary upload (mobile)...');

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      debugPrint('Cloudinary response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'] as String;
        debugPrint('Upload successful! URL: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('Upload failed: $responseString');
        if (jsonResponse['error'] != null) {
          debugPrint('Error message: ${jsonResponse['error']['message']}');
        }
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  // For web (XFile)
  static Future<String?> uploadImageWeb(XFile imageFile) async {
    try {
      debugPrint('Starting Cloudinary upload (web)...');
      debugPrint('Image file name: ${imageFile.name}');
      debugPrint('Image file path: ${imageFile.path}');

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();
      debugPrint('Image size: ${bytes.length} bytes');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;

      // Add the file as multipart
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name ?? 'image.jpg',
      );
      request.files.add(multipartFile);

      debugPrint('Sending request to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      debugPrint('Cloudinary response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'] as String;
        debugPrint('Upload successful! URL: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('Upload failed: $responseString');
        if (jsonResponse['error'] != null) {
          debugPrint('Error message: ${jsonResponse['error']['message']}');
        }
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary web upload error: $e');
      return null;
    }
  }
}
