import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbastecimentoPage extends StatefulWidget {
  @override
  _AbastecimentoPageState createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  final _valorController = TextEditingController();
  final _kmController = TextEditingController();
  final _litrosController = TextEditingController();

  double? mediaConsumo;

  void calcularMedia() {
    final km = double.tryParse(_kmController.text);
    final litros = double.tryParse(_litrosController.text);

    if (km != null && litros != null && litros > 0) {
      setState(() {
        mediaConsumo = km / litros;
      });
    } else {
      setState(() {
        mediaConsumo = null;
      });
    }
  }

  Future<void> salvarAbastecimento() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final valor = double.tryParse(_valorController.text.trim()) ?? 0;
    final km = double.tryParse(_kmController.text.trim()) ?? 0;
    final litros = double.tryParse(_litrosController.text.trim());

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('abastecimentos')
        .add({
      'valor': valor,
      'km': km,
      'litros': litros,
      'media': (litros != null && litros > 0) ? km / litros : null,
      'data': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abastecimento salvo com sucesso!')),
    );

    // Limpa campos
    _valorController.clear();
    _kmController.clear();
    _litrosController.clear();
    setState(() {
      mediaConsumo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    InputDecoration campoDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyanAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        title:
            Text("Abastecimento", style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                controller: _valorController,
                decoration: campoDecoration("Valor do combustível (R\$)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.cyanAccent,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _kmController,
                decoration: campoDecoration("Quilometragem atual (Km)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.cyanAccent,
                onChanged: (_) => calcularMedia(),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _litrosController,
                decoration: campoDecoration("Litros abastecidos (opcional)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.cyanAccent,
                onChanged: (_) => calcularMedia(),
              ),
              SizedBox(height: 20),
              if (mediaConsumo != null)
                Text(
                  "Média de Consumo: ${mediaConsumo!.toStringAsFixed(2)} Km/L",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent),
                ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: salvarAbastecimento,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Salvar Abastecimento",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (user != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .collection('abastecimentos')
                      .orderBy('data', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Nenhum abastecimento salvo ainda.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = (doc['data'] as Timestamp).toDate();
                        final valor = doc['valor'] ?? 0;
                        final km = doc['km'] ?? 0;
                        final litros = doc['litros'] ?? 0;
                        final media = doc['media'] ?? 0;

                        return Card(
                          color: Colors.white12,
                          margin:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(Icons.local_gas_station,
                                color: Colors.cyanAccent),
                            title: Text(
                              "Valor: R\$${valor.toStringAsFixed(2)} - Km: $km - Litros: $litros",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Média: ${media.toStringAsFixed(2)} Km/L\nData: ${DateFormat('dd/MM/yyyy').format(data)}",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
