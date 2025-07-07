import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labanquinha_app/models/product_model.dart';
import 'package:labanquinha_app/models/banner_model.dart';

class ApiService {
  // A URL base da sua API na AWS.
  // Lembre-se: quando tiver um domínio, use HTTPS!
  static const String _baseUrl = 'http://3.148.164.38'; 

  // Método para registar um novo utilizador
  static Future<void> registerUser({
    required String name,
    required String lastName,
    required String cpf,
    required String birthDate, // Formato esperado pela API: "YYYY-MM-DD"
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/v1/auth/register');

    // Montando o corpo da requisição em formato JSON
    final body = jsonEncode({
      'name': name,
      'lastName': lastName,
      'cpf': cpf,
      'birthDate': birthDate,
      'phone': phone,
      'role': 'user', // A API espera a role, definimos "user" como padrão
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      // --- LÓGICA DE RESPOSTAS PERSONALIZADAS ---
      if (response.statusCode == 201) {
        // Sucesso!
        print('Utilizador registado com sucesso!');
        return; // Termina a função com sucesso.
      } 
      else if (response.statusCode == 400) {
        // Erro de dados inválidos (ex: utilizador já existe)
        final errorData = jsonDecode(response.body);
        final detail = errorData['detail'] ?? 'Ocorreu um erro desconhecido.';
        
        // Verificamos a mensagem de detalhe da API
        if (detail.contains('telefone já existe')) {
          throw Exception('Este telemóvel já está registado. Tente fazer login.');
        }
        // Para outros erros 400
        throw Exception(detail);
      } 
      else {
        // Para outros erros (500, 404, etc.)
        throw Exception('Ocorreu um erro no servidor. Por favor, tente novamente mais tarde.');
      }

    } catch (e) {
      // Pega erros de rede ou as exceções que lançamos acima
      print('Erro na requisição: $e');
      // Re-lança a exceção para que a UI possa tratá-la.
      // Se for um erro de rede, a mensagem será a genérica.
      rethrow;
    }
  }

  static Future<String> loginUser({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/v1/auth/token');

    try {
      // O endpoint de token espera dados de formulário, não JSON
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // O http.post codifica o Map para o formato de formulário automaticamente
        body: {
          'username': phone, // A API espera o telefone no campo 'username'
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Sucesso! Extraímos o token da resposta.
        final data = jsonDecode(response.body);
        return data['access_token'];
      } 
      else if (response.statusCode == 401) {
        // Credenciais inválidas
        throw Exception('Telemóvel ou senha incorretos.');
      } 
      else {
        // Outros erros
        throw Exception('Ocorreu um erro no servidor. Tente novamente.');
      }
    } catch (e) {
      // Erros de rede ou exceções lançadas acima
      print('Erro no login: $e');
      rethrow;
    }
  }

  // NOVO: Buscar banners ativos
  static Future<List<BannerModel>> getActiveBanners() async {
    // CORREÇÃO: Apontar para a nova rota de banners públicos
    final url = Uri.parse('$_baseUrl/api/v1/banners/active');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar banners.');
      }
    } catch (e) {
      throw Exception('Erro de rede ao buscar banners.');
    }
  }

  // NOVO: Buscar produtos
  static Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/api/v1/products/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos.');
      }
    } catch (e) {
      throw Exception('Erro de rede ao buscar produtos.');
    }
  }

  // NOVO: Método para criar um banner com upload de imagem
  static Future<void> createBannerWithUpload({
    required String cta,
    required String rv,
    required XFile image,
  }) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Utilizador não autenticado.');

    // A nossa única chamada agora é para a rota de criação de banners
    final url = Uri.parse('$_baseUrl/api/v1/admin/banners/');
    var request = http.MultipartRequest('POST', url);

    // Adiciona o token de autorização
    request.headers['Authorization'] = 'Bearer $token';

    // Adiciona os campos de texto
    request.fields['cta'] = cta;
    request.fields['rv'] = rv;

    // Adiciona o ficheiro da imagem
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        print('Erro ao criar banner: ${response.body}');
        throw Exception('Falha ao criar o banner.');
      }
      
      print('Banner criado com sucesso!');

    } catch (e) {
      print('Erro na requisição: $e');
      rethrow;
    }
  }
}
