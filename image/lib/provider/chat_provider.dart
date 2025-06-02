import 'package:image/services/shared_pref.dart';
import 'package:image/utils/constant_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/chat_message.dart';

import '../model/error_response_model.dart';
import '../model/image_generate_model.dart';
import '../model/image_genrate_response.dart';
import '../services/api_base_url.dart';
import '../services/api_service.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_services.dart';

import 'dart:async';

class ChatProvider extends ChangeNotifier  {
  final List<ChatMessage> _imageMessages = [];

  List<ChatMessage> getImages() => _imageMessages;

  bool _isMessageLoading = false;

  bool get isLoading => _isMessageLoading;

  bool _isImageLoading = false;

  bool get isImageLoading => _isImageLoading;

  final FirebaseRealtimeService _realtimeService = FirebaseRealtimeService();
  final FirestoreService _firestoreService = FirestoreService();
  final ApiServices _api = ApiServices(null);
  final CloudinaryService _cloudinaryService = CloudinaryService();

  StreamSubscription? _imageSubscription;

  String? _userId;

  String _imageGeneratePath = '';
  String currentUser = '';

  double _imageQuality = 40.0;

  double get imageQuality => _imageQuality;
  int imageQuantity = 1;

  void updateImageQuality(double value) {
    _imageQuality = value;
    notifyListeners();
  }

  void incrementImageQty() {
    imageQuantity++;
    notifyListeners();
  }

  void decrementImageQty() {
    if (imageQuantity > 1) {
      imageQuantity--;
      notifyListeners();
    }
  }

  Future<void> getAllImages() async {
    _isMessageLoading = true;
    notifyListeners();

    try {
      await _initUserAndPaths();
      print(_imageGeneratePath);
      print("getAllImages");
      _imageSubscription?.cancel();
      _imageSubscription = _realtimeService
          .streamData(_imageGeneratePath)
          .listen(
            (event) {
              print("getAllImages = ${event.snapshot.value}");
              _imageMessages
                ..clear()
                ..addAll(_parseMessages(event.snapshot.value));

              notifyListeners();
            },
            onError: (e) {
              print("Error while streaming images: $e");
              _isMessageLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      print("Error  streaming images: $e");
    } finally {
      _isMessageLoading = false; // Ensure loading is set to false after operations
      notifyListeners();
    }
  }

  Future<void> sendImagePrompt(String text, int quantity, int quality, {required bool isSender}) async {
    await _initUserAndPaths();
    print("sendImagePrompt");
    final message = ChatMessage(
      text: text,
      isSender: isSender,
      timestamp: DateTime.now(),
      username: FirebaseAuth.instance.currentUser?.displayName ?? '',
      userId: _userId ?? '',
    );

    _imageMessages.add(message);
    notifyListeners();
    await _realtimeService.addData(_imageGeneratePath, message.toJson());

    if (isSender) {
      _addLoadingMessage(_imageMessages);
      _isImageLoading = true;

      notifyListeners();

      try {
        final reqBody =
            ImageGenerateModel(model: ApiBaseUrls.imageModel, prompt: text, imageCount: quantity, stepsQuality: quality).toJson();
        print(reqBody);

        final response = await _api.postApiData(ApiBaseUrls.imageGeneration, reqBody);

        if (response.containsKey("error")) {
          final errorResponse = ApiErrorResponse.fromJson(response);


       final   errorMsg =   ChatMessage(
            text: errorResponse.error?.message ?? "",
            isSender: false,
            timestamp: DateTime.now(),
            username: ConstantsFile.firebaseAssistant,
            userId: '',
          );

          _imageMessages.add(errorMsg);
        } else {
          final imageUrls = ImageGenerateResponse.fromJson(response).data.map((e) => e.url!).toList();

          for (final url in imageUrls) {
            // Upload to Cloudinary
            final cloudinaryUrl = await _cloudinaryService.fetchCloudinaryImage(
              fileName: "image_${DateTime.now().millisecondsSinceEpoch}.png",
              image: await _api.fetchImageData(url),
            );

            if (cloudinaryUrl != null) {
              final imgMsg = ChatMessage(
                text: url,
                isSender: false,
                timestamp: DateTime.now(),
                username: ConstantsFile.firebaseAssistant,
                userId: '',
              );
              _imageMessages.add(imgMsg);
              await _realtimeService.addData(_imageGeneratePath, imgMsg.toJson());
            }
          }
        }
      } catch (e) {
        _imageMessages.add(
          ChatMessage(
            text: "Image generation error: $e",
            isSender: false,
            timestamp: DateTime.now(),
            username: ConstantsFile.firebaseAssistant,
            userId: '',
          ),
        );
      } finally {
        _isImageLoading = false;
        _removeLoadingMessage(_imageMessages);
        notifyListeners();
      }
    }
  }

  // ───────────────────── Common Utilities ───────────────────── //

  Future<void> _initUserAndPaths() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      final users = await _firestoreService.fetchData(ConstantsFile.firebaseUserCollection);
      final user = users.firstWhere(
        (u) => u[ConstantsFile.paramUserId] == _userId,
        orElse: () {
          print(users.first);
          return users.first;
        },
      );
      currentUser = user[ConstantsFile.paramName] ?? '';
      SharedPreference().setStringPref(ConstantsFile.sharedPrefName, currentUser);

      _imageGeneratePath = "${ConstantsFile.firebaseImageGenerateCollection}_$_userId";
    }
  }

  List<ChatMessage> _parseMessages(dynamic data) {
    if (data is Map) {
      return data.entries.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e.value))).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return [];
  }

  void _addLoadingMessage(List<ChatMessage> list) {
    list.add(
      ChatMessage(
        text: ConstantsFile.loadingMark,
        isSender: false,
        timestamp: DateTime.now(),
        username: ConstantsFile.firebaseAssistant,
        userId: '',
      ),
    );
  }
  void _removeLoadingMessage(List<ChatMessage> list) {
    // Remove the loading message from the list
    list.removeWhere((msg) => msg.text == ConstantsFile.loadingMark && !msg.isSender);
  }
  void clearAllMessages() {
    _imageMessages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _imageSubscription?.cancel();
    super.dispose();
  }
}
