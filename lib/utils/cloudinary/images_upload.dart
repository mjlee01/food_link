import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUploadUtil {
  final cloudinary = Cloudinary.full(
    apiKey: dotenv.env['CLOUDINARY_API_KEY']!,
    apiSecret: dotenv.env['CLOUDINARY_API_SECRET']!,
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!,
  );

  Future<String?> uploadImage(String filePath) async {
    try {
      final uploadResource = CloudinaryUploadResource(
        filePath: filePath,
        folder: 'food-link-groceries/',
        resourceType: CloudinaryResourceType.image,
      );

      final response = await cloudinary.uploadResource(uploadResource);

      return response.secureUrl;
    } catch (e) {
      return 'Error uploading image: $e';
    }
  }
}
