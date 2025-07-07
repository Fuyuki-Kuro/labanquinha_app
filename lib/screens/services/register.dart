import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de data
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Pacote para máscaras
import 'package:labanquinha_app/widgets/diagonal_clipper.dart'; // Seu clipper personalizado
import 'package:labanquinha_app/services/api_service.dart'; // Importar o ApiService

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para obter o texto de cada campo
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Formatadores de máscara para os campos
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _birthDateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    // Limpar os controladores quando o widget for descartado
    _nameController.dispose();
    _lastNameController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função para exibir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Formata a data para o padrão brasileiro e atualiza o campo
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Função para registrar o usuário
  Future<void> _register() async {
    // TODO: Adicionar validações mais robustas aqui (campos vazios, senhas iguais, etc.)

    try {
      // Parse and format the birth date to 'yyyy-MM-dd'
      final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      final DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      final String formattedBirthDate = outputFormat.format(
        inputFormat.parse(_birthDateController.text),
      );

      await ApiService.registerUser(
        name: _nameController.text,
        lastName: _lastNameController.text,
        cpf: _cpfMask.getUnmaskedText(), // Pega o valor sem a máscara
        birthDate: formattedBirthDate,
        phone: _phoneMask.getUnmaskedText(),
        password: _passwordController.text,
      );
      // TODO: Redirecionar para a tela de login ou mostrar uma mensagem de sucesso
      Navigator.of(context).pushNamed('/login');
      print('Usuário registrado com sucesso!'); // Apenas para teste
    } catch (e) {
      print('Erro durante o registro: $e'); // Adicionado para depuração
      // Exibir dialog de erro
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Erro no Registro'),
              content: Text(
                'Ocorreu um erro ao registrar o usuário: ${e.toString()}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: DiagonalClipper(diagonalHeightFactor: 0.7),
              child: Container(
                height: screenHeight * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF010101), Color(0xFF171616)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/pattern_mask.png'),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, bottom: 1),
                      child: Text(
                        'Registro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Artigos de Tabacaria',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),

                    // Campo Nome
                    TextField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Nome'),
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 20),

                    // Campo Sobrenome
                    TextField(
                      controller: _lastNameController,
                      decoration: _buildInputDecoration('Sobrenome'),
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 20),

                    // Campo CPF
                    TextField(
                      controller: _cpfController,
                      decoration: _buildInputDecoration('CPF'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cpfMask], // Aplica a máscara
                    ),

                    const SizedBox(height: 20),

                    // Campo Data de Nascimento
                    TextField(
                      controller: _birthDateController,
                      decoration: _buildInputDecoration('Data de Nascimento'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [_birthDateMask], // Aplica a máscara
                      onTap: () {
                        // Impede o teclado de abrir e chama o seletor de data
                        FocusScope.of(context).requestFocus(FocusNode());
                        _selectDate(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Campo Celular
                    TextField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration('Celular'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneMask], // Aplica a máscara
                    ),

                    const SizedBox(height: 20),

                    // Campo Senha
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Senha'),
                    ),

                    const SizedBox(height: 20),

                    // Campo Confirmar Senha
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Confirmar Senha'),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _register(); // Chama a função de registro
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171616),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem conta? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função auxiliar para evitar repetição de código na decoração dos inputs
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
    );
  }
}
