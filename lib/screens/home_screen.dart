import 'package:flutter/material.dart';
import 'package:labanquinha_app/models/banner_model.dart';
import 'package:labanquinha_app/models/product_model.dart';
import 'package:labanquinha_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Os Futures são declarados aqui para serem inicializados apenas uma vez.
  late Future<List<BannerModel>> _bannersFuture;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // A chamada à API é feita aqui, no initState, para evitar ser chamada
    // a cada reconstrução da tela.
    _bannersFuture = ApiService.getActiveBanners();
    _productsFuture = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      // Usamos um RefreshIndicator para permitir que o utilizador "puxe para atualizar"
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Garante que o scroll funcione sempre
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannersCarousel(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recentes'),
              const SizedBox(height: 12),
              _buildRecentProductsList(),
              const SizedBox(height: 24),
              _buildSectionTitle('Novidades'),
              const SizedBox(height: 12),
              _buildNewProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  // Função para recarregar os dados da API
  Future<void> _refreshData() async {
    setState(() {
      _bannersFuture = ApiService.getActiveBanners();
      _productsFuture = ApiService.getProducts();
    });
  }

  // --- Widgets de Construção da UI ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rua Exemplo 123', style: TextStyle(fontSize: 14)),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Widgets com FutureBuilder ---

  Widget _buildBannersCarousel() {
    return FutureBuilder<List<BannerModel>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        // 1. Estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        // 2. Estado de Erro
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.red))),
          );
        }
        // 3. Estado de Sucesso (mas sem dados)
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Nenhum banner encontrado.', style: TextStyle(color: Colors.white))),
          );
        }
        
        // 4. Estado de Sucesso (com dados)
        final banners = snapshot.data!;
        // Usando o primeiro banner como imagem principal
        return Image.network(
          banners[0].imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          // Mostra um indicador de carregamento para a própria imagem
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          },
          // Mostra um ícone de erro se o URL da imagem falhar
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 200,
              child: Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentProductsList() {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto recente.', style: TextStyle(color: Colors.white)));
          }
          
          final products = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length > 3 ? 3 : products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade800,
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) { /* Fica em branco para não mostrar erro na consola */ },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.name, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNewProductsList() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma novidade encontrada.', style: TextStyle(color: Colors.white)));
        }
        
        final products = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              color: const Color(0xFF1A1A1A),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(product.description, style: const TextStyle(color: Colors.grey), maxLines: 2),
                trailing: Text(
                  'R\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}