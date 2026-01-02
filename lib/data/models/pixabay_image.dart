class PixabayImage {
  const PixabayImage({
    required this.id,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageType,
    required this.user,
    required this.tags,
  });

  final int id;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final int imageWidth;
  final int imageHeight;
  final String imageType;
  final String user;
  final String tags;

  bool get hasDimensions => imageWidth > 0 && imageHeight > 0;

  double get aspectRatio {
    if (!hasDimensions) {
      return 1;
    }
    return imageWidth / imageHeight;
  }

  String get title {
    final parts = tags.split(',');
    if (parts.isEmpty) {
      return 'Inspiration';
    }
    final trimmed = parts.map((part) => part.trim()).where((part) => part.isNotEmpty);
    final selected = trimmed.take(2).toList();
    if (selected.isEmpty) {
      return 'Inspiration';
    }
    return selected.join(' ');
  }

  String get primaryTag {
    final parts = tags.split(',');
    if (parts.isEmpty) {
      return '';
    }
    return parts.first.trim();
  }

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      previewUrl: json['previewURL'] as String? ?? '',
      webformatUrl: json['webformatURL'] as String? ?? '',
      largeImageUrl: json['largeImageURL'] as String? ?? '',
      imageWidth: (json['imageWidth'] as num?)?.toInt() ?? 0,
      imageHeight: (json['imageHeight'] as num?)?.toInt() ?? 0,
      imageType: json['type'] as String? ?? 'photo',
      user: json['user'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
    );
  }
}
