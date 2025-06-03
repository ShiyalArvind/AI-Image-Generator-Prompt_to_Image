class ImageGenerateResponse {
  ImageGenerateResponse({
    required this.id,
    required this.model,
    required this.object,
    required this.data,
  });

  final String? id;
  final String? model;
  final String? object;
  final List<Datum> data;

  factory ImageGenerateResponse.fromJson(Map<String, dynamic> json){
    return ImageGenerateResponse(
      id: json["id"],
      model: json["model"],
      object: json["object"],
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "model": model,
    "object": object,
    "data": data.map((x) => x.toJson()).toList(),
  };

}

class Datum {
  Datum({
    required this.index,
    required this.url,
    required this.timings,
  });

  final int? index;
  final String? url;
  final Timings? timings;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      index: json["index"],
      url: json["url"],
      timings: json["timings"] == null ? null : Timings.fromJson(json["timings"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "index": index,
    "url": url,
    "timings": timings?.toJson(),
  };

}

class Timings {
  Timings({
    required this.inference,
  });

  final double? inference;

  factory Timings.fromJson(Map<String, dynamic> json){
    return Timings(
      inference: json["inference"],
    );
  }

  Map<String, dynamic> toJson() => {
    "inference": inference,
  };

}