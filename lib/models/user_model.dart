class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String phone;
  final String cpf;
  final String birthDate;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.cpf,
    required this.birthDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Nome não encontrado',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      cpf: json['cpf'] ?? '',
      birthDate: json['birthDate'] ?? '',
    );
  }
}