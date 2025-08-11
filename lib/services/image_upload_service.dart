import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ImageUploadService {
  /// Uploads an image file to Freeimage.host and returns the image URL
  static Future<String> uploadImage(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare the request body
      final body = {
        'key': ApiConfig.freeimageHostApiKey,
        'action': 'upload',
        'source': base64Image,
        'format': 'json',
      };

      print('Uploading image via base64 method...');
      print('API Key: ${ApiConfig.freeimageHostApiKey}');
      print('Image size: ${bytes.length} bytes');

      // Make the API request
      final response = await http.post(
        Uri.parse(ApiConfig.freeimageHostApiUrl),
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if upload was successful
        if (jsonResponse['status_code'] == 200 && jsonResponse['success'] != null) {
          // Return the image URL
          return jsonResponse['image']['url'];
        } else {
          final errorMessage = jsonResponse['error']?['message'] ?? jsonResponse['error'] ?? 'Unknown error';
          throw Exception('Upload failed: $errorMessage');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Base64 upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Alternative method using multipart form data (recommended for file uploads)
  static Future<String> uploadImageFile(File imageFile) async {
    try {
      print('Uploading image via multipart method...');
      print('API Key: ${ApiConfig.freeimageHostApiKey}');
      print('File path: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.freeimageHostApiUrl));
      
      // Add API parameters
      request.fields['key'] = ApiConfig.freeimageHostApiKey;
      request.fields['action'] = 'upload';
      request.fields['format'] = 'json';

      // Add the image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'source',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Multipart response status: ${response.statusCode}');
      print('Multipart response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if upload was successful
        if (jsonResponse['status_code'] == 200 && jsonResponse['success'] != null) {
          // Return the image URL
          return jsonResponse['image']['url'];
        } else {
          final errorMessage = jsonResponse['error']?['message'] ?? jsonResponse['error'] ?? 'Unknown error';
          throw Exception('Upload failed: $errorMessage');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Multipart upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Alternative upload method using ImgBB API
  static Future<String> uploadToImgBB(File imageFile) async {
    try {
      print('Uploading image to ImgBB...');
      
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare the request body
      final body = {
        'key': ApiConfig.imgbbApiKey,
        'image': base64Image,
      };

      // Make the API request
      final response = await http.post(
        Uri.parse(ApiConfig.imgbbApiUrl),
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print('ImgBB response status: ${response.statusCode}');
      print('ImgBB response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if upload was successful
        if (jsonResponse['success'] == true) {
          // Return the image URL
          return jsonResponse['data']['url'];
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('ImgBB HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ImgBB upload error: $e');
      throw Exception('Failed to upload image to ImgBB: $e');
    }
  }

  /// Main upload method that tries multiple services
  static Future<String> uploadImageWithFallback(File imageFile) async {
    // Try Freeimage.host first
    try {
      print('Trying Freeimage.host...');
      return await uploadImageFile(imageFile);
    } catch (e) {
      print('Freeimage.host failed: $e');
      
      // Try base64 method
      try {
        print('Trying Freeimage.host base64...');
        return await uploadImage(imageFile);
      } catch (e2) {
        print('Freeimage.host base64 failed: $e2');
        
        // Try ImgBB as fallback
        try {
          print('Trying ImgBB...');
          return await uploadToImgBB(imageFile);
        } catch (e3) {
          print('All upload methods failed');
          throw Exception('All image upload services failed. Please try again later.');
        }
      }
    }
  }

  /// Test method to verify API key and connection
  static Future<bool> testApiConnection() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.freeimageHostApiUrl),
        body: {
          'key': ApiConfig.freeimageHostApiKey,
          'action': 'upload',
          'source': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
          'format': 'json',
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print('API test response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API test error: $e');
      return false;
    }
  }
}
