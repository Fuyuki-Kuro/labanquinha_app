class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // Assumindo que a API retorna uma imagem principal

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Verifica se 'images' existe e não está vazio
    final images = json['images'] as List?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0]
        : 'https://placehold.co/600x400/EEE/31343C?text=Sem+Imagem';

    return Product(
      id: json['_id'],
      name: json['name'] ?? 'Nome Indisponível',
      description: json['description'] ?? 'Sem descrição',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: imageUrl,
    );
  }
}