
class ImageGenerateModel {
    ImageGenerateModel({
        required this.model,
        required this.prompt,
        required this.stepsQuality,
        required this.imageCount,
    });

    final String? model;
    final String? prompt;
    final int? stepsQuality;
    final int? imageCount;

    factory ImageGenerateModel.fromJson(Map<String, dynamic> json){
        return ImageGenerateModel(
            model: json["model"],
            prompt: json["prompt"],
            stepsQuality: json["steps"],
            imageCount: json["n"],
        );
    }

    Map<String, dynamic> toJson() => {
        "model": model,
        "prompt": prompt,
        "steps": stepsQuality,
        "n": imageCount,
    };

}