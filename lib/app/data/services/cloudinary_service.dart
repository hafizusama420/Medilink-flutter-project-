// lib/app/data/services/cloudinary_service.dart
// Service class for uploading images to Cloudinary cloud storage
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// CloudinaryService handles image uploads to Cloudinary CDN
/// Supports all platforms including web by using XFile and bytes
class CloudinaryService {
  // Cloudinary account configuration
  static const String cloudName = 'dxejhmyxq';        // Cloudinary cloud name
  static const String uploadPreset = 'dxejhmyxq';     // Upload preset for unsigned uploads
  static const String folder = 'home/assets';          // Target folder in Cloudinary
  
  /// Uploads an image file to Cloudinary and returns the secure URL
  /// 
  /// This method is cross-platform compatible (works on mobile and web)
  /// by using XFile and reading bytes instead of file paths
  /// 
  /// Parameters:
  ///   - imageFile: XFile object from image_picker package
  /// 
  /// Returns:
  ///   - String: Secure HTTPS URL of the uploaded image
  /// 
  /// Throws:
  ///   - Exception if upload fails or times out
  Future<String> uploadImage(XFile imageFile) async {
    try {
      // Read image as bytes (works on all platforms including web)
      final bytes = await imageFile.readAsBytes();
      
      // Construct Cloudinary upload API endpoint
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );
      
      // Create HTTP multipart request for file upload
      var request = http.MultipartRequest('POST', url);
      
      // Add upload preset (required for unsigned uploads)
      request.fields['upload_preset'] = uploadPreset;
      
      // Specify target folder in Cloudinary
      request.fields['folder'] = folder;
      
      // Generate unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      request.fields['public_id'] = 'profile_$timestamp';
      
      // Attach image file to request using bytes
      // This approach works on web unlike File-based methods
      var multipartFile = http.MultipartFile.fromBytes(
        'file',                    // Field name expected by Cloudinary
        bytes,                     // Image data as bytes
        filename: imageFile.name,  // Original filename
      );
      request.files.add(multipartFile);
      
      // Send upload request with 30-second timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload request timed out. Please check your internet connection.');
        },
      );
      
      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);
      
      // Check if upload was successful
      if (response.statusCode == 200) {
        // Parse JSON response from Cloudinary
        final responseData = json.decode(response.body);
        
        // Extract and return the secure URL of uploaded image
        final secureUrl = responseData['secure_url'] as String;
        return secureUrl;
      } else {
        // Upload failed, throw exception with error details
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      // Re-throw any errors that occurred during upload
      rethrow;
    }
  }
}
