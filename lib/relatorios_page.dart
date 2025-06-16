import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Map<String, double> ganhosPorApp = {};
  Map<String, double> despesasPorMes = {};
  Map<String, double> saldoPorMes = {};
  List<double> mediasConsumo = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final uid = user.uid;

    final recebimentos = await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('recebimentos')
        .get();

    final manutencoes = await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('manutencoes')
        .get();

    final abastecimentos = await firestore
        .collection('usuarios')
        .doc(uid)
        .collection('abastecimentos')
        .get();

    mediasConsumo = abastecimentos.docs
        .map((e) => (e['media'] ?? 0.0) as double)
        .where((v) => v > 0)
        .toList();

    ganhosPorApp.clear();
    despesasPorMes.clear();
    saldoPorMes.clear();

    for (var doc in recebimentos.docs) {
      final data = (doc['data'] as Timestamp).toDate();
      final mesAno = "${data.month.toString().padLeft(2, '0')}/${data.year}";
      final app = doc['app'] ?? 'Outro';
      final valor = (doc['valor'] ?? 0).toDouble();

      ganhosPorApp[app] = (ganhosPorApp[app] ?? 0) + valor;
      saldoPorMes[mesAno] = (saldoPorMes[mesAno] ?? 0) + valor;
    }

    for (var doc in manutencoes.docs) {
      final data = (doc['data'] as Timestamp).toDate();
      final mesAno = "${data.month.toString().padLeft(2, '0')}/${data.year}";
      final valor = (doc['valor'] ?? 0).toDouble();

      despesasPorMes[mesAno] = (despesasPorMes[mesAno] ?? 0) + valor;
      saldoPorMes[mesAno] = (saldoPorMes[mesAno] ?? 0) - valor;
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return Scaffold(
        backgroundColor: Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.cyanAccent),
          title: Text("Relatórios", style: TextStyle(color: Colors.cyanAccent)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        title: Text("Relatórios", style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection("Ganhos por Aplicativo", ganhosPorApp),
            const SizedBox(height: 24),
            buildSection("Despesas Mensais", despesasPorMes),
            const SizedBox(height: 24),
            buildSection("Saldo Mensal", saldoPorMes),
            const SizedBox(height: 24),
            Text(
              "Média de Consumo",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              mediasConsumo.isEmpty
                  ? "Nenhuma média de consumo registrada."
                  : "${(mediasConsumo.reduce((a, b) => a + b) / mediasConsumo.length).toStringAsFixed(2)} Km/L",
              style: const TextStyle(fontSize: 22, color: Colors.cyanAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, Map<String, double> data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          ...data.entries.map((e) => Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(e.key, style: TextStyle(color: Colors.white)),
                  trailing: Text(
                    "R\$ ${e.value.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
