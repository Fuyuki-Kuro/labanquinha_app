class BannerModel {
  final String id;
  final String imageUrl;

  BannerModel({required this.id, required this.imageUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'],
      imageUrl: json['image_url'] ?? 'https://placehold.co/1200x400/EEE/31343C?text=Banner',
    );
  }
}