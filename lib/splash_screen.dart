import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Troque pelo nome da sua tela de login

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textOffsetAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador da animação da logo
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // Controlador da animação do texto
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _textOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _logoController.forward();
    Future.delayed(
        Duration(milliseconds: 500), () => _textController.forward());

    // Redireciona após 4 segundos
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111111),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoAnimation,
              child: Image.asset(
                'assets/logodrivercash.jpg',
                height: 150,
              ),
            ),
            SizedBox(height: 30),
            SlideTransition(
              position: _textOffsetAnimation,
              child: Text(
                "Faz o corre,\na gente cuida do caixa.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
