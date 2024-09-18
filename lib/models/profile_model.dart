class ProfileModel {
  final String? id;
  final String fullName;
  final String? imageUrl;
  final String? imageId;
  final String status;

  ProfileModel({
    this.id,
    required this.fullName,
    this.imageUrl,
    this.imageId,
    required this.status,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      fullName: json['fullName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      imageId: json['imageId'],
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}
