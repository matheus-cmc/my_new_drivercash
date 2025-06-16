import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';
import 'login_page.dart'; // <--- IMPORTANTE: ajuste o nome do arquivo se necessário

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _isLoading = false;

  Future<void> cadastrar() async {
    if (_nomeCompletoController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _enderecoController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos")),
      );
      return;
    }

    if (_cpfController.text.trim().length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CPF inválido. Digite 11 dígitos.")),
      );
      return;
    }

    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("Erro ao obter UID.");

      await _firestore.collection('usuarios').doc(uid).set({
        'nome_completo': _nomeCompletoController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'criado_em': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } catch (e) {
      String errorMessage = "Erro ao cadastrar";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "Este e-mail já está em uso.";
            break;
          case 'invalid-email':
            errorMessage = "E-mail inválido.";
            break;
          case 'weak-password':
            errorMessage = "A senha é muito fraca.";
            break;
          default:
            errorMessage = e.message ?? "Erro inesperado.";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label,
      {bool isPassword = false,
      VoidCallback? toggleVisibility,
      bool obscureText = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.cyanAccent),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111111),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 40),
            Image.asset(
              'lib/assets/images/drivercash.png',
              filterQuality: FilterQuality.high,
              height: 150,
              width: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
              'CADASTRO',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _nomeCompletoController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("Nome Completo"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("E-mail"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("Telefone"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _enderecoController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("Endereço"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cpfController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration("CPF"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _senhaController,
              style: TextStyle(color: Colors.white),
              obscureText: _obscureSenha,
              decoration: _inputDecoration(
                "Senha",
                isPassword: true,
                toggleVisibility: () {
                  setState(() {
                    _obscureSenha = !_obscureSenha;
                  });
                },
                obscureText: _obscureSenha,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _confirmarSenhaController,
              style: TextStyle(color: Colors.white),
              obscureText: _obscureConfirmarSenha,
              decoration: _inputDecoration(
                "Confirmar Senha",
                isPassword: true,
                toggleVisibility: () {
                  setState(() {
                    _obscureConfirmarSenha = !_obscureConfirmarSenha;
                  });
                },
                obscureText: _obscureConfirmarSenha,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : cadastrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black87, strokeWidth: 2),
                    )
                  : Text(
                      "Cadastrar",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Já tem uma conta? Entrar",
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
