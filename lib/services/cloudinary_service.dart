import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../utils/constant_file.dart';
import 'api_base_url.dart';

class CloudinaryService {
  final Dio _dio;

  CloudinaryService() : _dio = Dio();

  printLog(String title, String log) {
    // ignore: avoid_print
    print("--------$title-------------$log");
  }

  Future<String?> fetchCloudinaryImage({
    required String fileName,
    required Uint8List image,

  }) async {
    try {
      List<Map<String, dynamic>> filesToUpload = [
        {ConstantsFile.fileName: _cleanFileName(fileName), ConstantsFile.fileBytes: image},
      ];

      List<Map<String, String>> uploadedLinks = await _uploadToCloudinary(filesToUpload);

      if (uploadedLinks.isNotEmpty) {
        String imageUrl = uploadedLinks.first[ConstantsFile.url] ?? "";
        printLog("fetchCloudinaryImage", "Uploaded File URL: $imageUrl");
        return imageUrl;
      } else {
        printLog("fetchCloudinaryImage", "No uploaded links found.");
        return null;
      }
    } catch (e) {
      printLog("fetchCloudinaryImage", "An error occurred: $e");
      return null;
    }
  }

  Future<List<Map<String, String>>> _uploadToCloudinary(List<Map<String, dynamic>>? selectedFiles) async {
    List<Map<String, String>> uploadedFilesData = [];

    if (selectedFiles == null || selectedFiles.isEmpty) {
      printLog("uploadToCloudinary", "No file selected!");
      return uploadedFilesData;
    }

    var uri = Uri.parse(ApiBaseUrls.cloudinaryBaseUrl + ApiBaseUrls.cloudinaryUploadUrl);
    String directory = ConstantsFile.userPosts;

    for (var file in selectedFiles) {
      try {
        Uint8List? fileBytes = file[ConstantsFile.fileBytes] as Uint8List?;
        String? fileName = file[ConstantsFile.fileName] as String?;

        if (fileBytes == null || fileName == null) {
          printLog("uploadToCloudinary", "Invalid file data for $fileName, skipping...");
          continue;
        }

        FormData formData = FormData.fromMap({
          ConstantsFile.uploadPreset: ApiBaseUrls.uploadPresetKey,
          ConstantsFile.apiKey: ApiBaseUrls.apiKey,
          ConstantsFile.publicId: fileName,
          ConstantsFile.assetFolder: directory,
          ConstantsFile.file: MultipartFile.fromBytes(fileBytes, filename: fileName),
        });

        var response = await _dio.post(uri.toString(), data: formData);

        if (response.statusCode == 200) {
          var jsonResponse = response.data;
          Map<String, String> requiredData = {
            ConstantsFile.fileName: fileName,
            ConstantsFile.url: jsonResponse[ConstantsFile.secureUrl], // Get file URL
            ConstantsFile.publicId: jsonResponse[ConstantsFile.publicId], // File ID
          };

          uploadedFilesData.add(requiredData);
          printLog("uploadToCloudinary", "Upload successful for $fileName. URL: ${requiredData[ConstantsFile.url]}");
        } else {
          printLog(
            "uploadToCloudinary",
            "Upload failed for $fileName. Status: ${response.statusCode}, Response: ${response.data}",
          );
        }
      } catch (e) {
        printLog("uploadToCloudinary", "Upload error for : $e");
      }
    }

    return uploadedFilesData;
  }

  Future<bool> deleteFromCloudinary(String publicId) async {
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String toSign = '${ConstantsFile.publicId}=$publicId&${ConstantsFile.timestamp}=$timestamp';
      var signature = sha1.convert(utf8.encode(toSign + ApiBaseUrls.apiSecretKey)).toString();
      var url = ApiBaseUrls.cloudinaryBaseUrl + ApiBaseUrls.cloudinaryDeleteUrl;

      var response = await _dio.post(
        url,
        data: {
          ConstantsFile.publicId: publicId,
          ConstantsFile.timestamp: timestamp.toString(),
          ConstantsFile.apiKey: ApiBaseUrls.apiKey,
          ConstantsFile.signature: signature,
        },
      );

      if (response.statusCode == 200) {
        var responseBody = response.data;
        if (responseBody['result'] == 'ok') {
          printLog("deleteFromCloudinary", "File deleted successfully for public ID: $publicId.");
          return true;
        }
      }

      printLog("deleteFromCloudinary", "Failed to delete file: ${response.data}");
      return false;
    } catch (e) {
      printLog("deleteFromCloudinary", "Error deleting file: $e");
      return false;
    }
  }

  String _cleanFileName(String fileName) {
    String originalFileName = fileName.trim();
    String cleanName = originalFileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return cleanName;
  }

  String buildCloudinaryUrl({
    required String publicId,
    String folder = ConstantsFile.userPosts,
    String extension = 'jpg',
    String version = '', // Optional: e.g., 'v1748515973'
    String transformation = '', // Optional: e.g., 'w_300,h_300,c_fill'
  }) {



    return '${ApiBaseUrls.cloudinaryFetchUrl}/$version/$folder/$publicId.$extension';
  }
//https://res.cloudinary.com/dkw5tsbrx/image/upload/v1748515973/user_posts/image_1748515969649.jpg
}