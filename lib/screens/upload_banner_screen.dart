import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:labanquinha_app/services/api_service.dart'; // Certifique-se de que o caminho está correto

class UploadBannerScreen extends StatefulWidget {
  const UploadBannerScreen({super.key});

  @override
  State<UploadBannerScreen> createState() => _UploadBannerScreenState();
}

class _UploadBannerScreenState extends State<UploadBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctaController = TextEditingController();
  final _rvController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Função para abrir a galeria e selecionar uma imagem
  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _imageFile = selectedImage;
        });
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      // Pode adicionar um SnackBar aqui para notificar o utilizador sobre o erro
    }
  }

  // Função para validar o formulário e enviar o banner
  Future<void> _submitBanner() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() => _isLoading = true);
      try {
        await ApiService.createBannerWithUpload(
          cta: _ctaController.text,
          rv: _rvController.text,
          image: _imageFile!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner enviado com sucesso!'), backgroundColor: Colors.green),
        );
        // Limpa o formulário após o sucesso
        _ctaController.clear();
        _rvController.clear();
        setState(() {
          _imageFile = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _ctaController.dispose();
    _rvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Banner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área de seleção de imagem
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: InkWell(
                  onTap: _pickImage,
                  child: _imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey.shade600),
                              const SizedBox(height: 8),
                              const Text('Toque para selecionar uma imagem', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_imageFile!.path), fit: BoxFit.cover, width: double.infinity),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Campos de texto
              TextFormField(
                controller: _ctaController,
                decoration: const InputDecoration(
                  labelText: 'Texto do Call-to-Action (CTA)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rvController,
                decoration: const InputDecoration(
                  labelText: 'Resultado / Valor (ex: 25% OFF)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),
              // Botão de Envio
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBanner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('Enviar Banner', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}