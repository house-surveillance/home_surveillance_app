class RegisteredFaceModel {
  final String id;
  final String name;
  final String? labeledDescriptors;

  RegisteredFaceModel({
    required this.id,
    required this.name,
    this.labeledDescriptors,
  });

  factory RegisteredFaceModel.fromJson(Map<String, dynamic> json) {
    return RegisteredFaceModel(
      id: json['id'].toString(),
      name: json['name'],
      labeledDescriptors: json['labeledDescriptors'] ?? "",
    );
  }
}
