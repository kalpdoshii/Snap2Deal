class Admin {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // 'admin', 'super_admin'
  final bool isActive;
  final DateTime createdAt;
  final String? profileImage;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.role = 'admin',
    this.isActive = true,
    required this.createdAt,
    this.profileImage,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json["id"] ?? json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      role: json["role"] ?? "admin",
      isActive: json["isActive"] ?? true,
      createdAt: json["createdAt"] is String
          ? DateTime.parse(json["createdAt"])
          : (json["createdAt"] as dynamic)?.toDate() ?? DateTime.now(),
      profileImage: json["profileImage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
      "isActive": isActive,
      "createdAt": createdAt,
      "profileImage": profileImage,
    };
  }
}
