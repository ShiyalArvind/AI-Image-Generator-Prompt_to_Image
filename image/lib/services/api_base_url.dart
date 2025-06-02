class ApiBaseUrls {
  static String authorizationToken = "Bearer 819b8eff6250d17759541daf2ea4e0bbeca4c7ff3400d34c6367733b0dd15dfa";
  static String baseUrl = "https://api.together.xyz/v1";
  static String imageGeneration = "/images/generations";
  static String imageModel = "black-forest-labs/FLUX.1-dev";

  static String cloudinaryCloudName = "dkw5tsbrx";
  static String cloudNameKey = "@$cloudinaryCloudName";
  static String apiKey = "825514895433634";
  static String apiSecretKey = "9em2Doh8FcYH6SfUATaLbNuSck8";
  static String uploadPresetKey = "FirebaseFiles";

  static String cloudinaryBaseUrl = 'https://api.cloudinary.com/v1_1/$cloudNameKey/';
  static String cloudinaryUploadUrl = 'upload?resource_type=auto';
  static String cloudinaryDeleteUrl = 'image/destroy';

  static String cloudinaryFetchUrl = 'https://res.cloudinary.com/$cloudinaryCloudName/image/upload';
}
