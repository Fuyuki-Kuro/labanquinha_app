import 'package:flutter/material.dart';
import 'package:labanquinha_app/screens/home_screen.dart';
import 'package:labanquinha_app/screens/upload_banner_screen.dart'; // Importe a tela de upload

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // O índice do item de navegação selecionado

  // Lista das telas que a nossa barra de navegação irá controlar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Índice 0
    Text('Tela de Loja (Placeholder)'), // Índice 1
    Text('Tela de Notificações (Placeholder)'), // Índice 2
    UploadBannerScreen(), // Índice 3 - Nossa tela de admin
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo da tela muda com base no item selecionado
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // A nossa barra de navegação
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          // Novo item para a tela de admin
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800], // Cor do item selecionado
        unselectedItemColor: Colors.grey, // Cor dos itens não selecionados
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Garante que todos os itens apareçam
        backgroundColor: Colors.black, // Cor de fundo da barra
      ),
    );
  }
}