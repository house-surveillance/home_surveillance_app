class FaceModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? imageId;
  final String labeledDescriptors;

  FaceModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageId,
    required this.labeledDescriptors,
  });

  factory FaceModel.fromJson(Map<String, dynamic> json) {
    return FaceModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unnamed',
      imageUrl: json['imageUrl'],
      imageId: json['imageId'],
      labeledDescriptors: json['labeledDescriptors'] ?? "",
    );
  }
}
