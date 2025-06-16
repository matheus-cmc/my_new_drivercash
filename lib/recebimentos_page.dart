import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecebimentosPage extends StatefulWidget {
  @override
  _RecebimentosPageState createState() => _RecebimentosPageState();
}

class _RecebimentosPageState extends State<RecebimentosPage> {
  final _valorController = TextEditingController();
  String _appSelecionado = 'Uber';

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Future<void> adicionarRecebimento() async {
    final valor = double.tryParse(_valorController.text.trim()) ?? 0;
    if (valor <= 0) return;

    await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('recebimentos')
        .add({
      'valor': valor,
      'app': _appSelecionado,
      'data': Timestamp.now(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Recebimento adicionado!')));

    _valorController.clear();
    _appSelecionado = 'Uber';
    setState(() {});
  }

  Future<void> atualizarRecebimento(
      String docId, double valor, String app) async {
    await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('recebimentos')
        .doc(docId)
        .update({
      'valor': valor,
      'app': app,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Recebimento atualizado!')));
  }

  Future<void> excluirRecebimento(String docId) async {
    await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('recebimentos')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Recebimento removido!')));
  }

  Stream<QuerySnapshot> getRecebimentos() {
    return firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('recebimentos')
        .orderBy('data', descending: true)
        .snapshots();
  }

  void abrirDialogEdicao(String docId, double valorAtual, String appAtual) {
    final _editValorController =
        TextEditingController(text: valorAtual.toString());
    String appSelecionado = appAtual;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text('Editar Recebimento',
            style: TextStyle(color: Colors.cyanAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editValorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: appSelecionado,
              items: ['Uber', '99', 'Outros']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                appSelecionado = value!;
              },
              decoration: InputDecoration(
                labelText: 'App',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
              dropdownColor: Colors.black,
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.cyanAccent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              final novoValor =
                  double.tryParse(_editValorController.text.trim()) ?? 0;
              if (novoValor > 0) {
                atualizarRecebimento(docId, novoValor, appSelecionado);
              }
              Navigator.pop(context);
            },
            child: Text('Salvar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        title: Text("Recebimentos", style: TextStyle(color: Colors.cyanAccent)),
      ),
      body: Column(
        children: [
          Padding(
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
                    decoration: InputDecoration(
                      labelText: "Valor recebido (R\$)",
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
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _appSelecionado,
                    items: ['Uber', '99', 'Outros']
                        .map((app) => DropdownMenuItem(
                              value: app,
                              child: Text(app),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _appSelecionado = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Selecione o App",
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
                    ),
                    dropdownColor: Colors.black,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.cyanAccent,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: adicionarRecebimento,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Adicionar Recebimento",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.4),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRecebimentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty)
                  return Center(
                      child: Text("Nenhum recebimento cadastrado.",
                          style: TextStyle(color: Colors.white70)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final id = doc.id;
                    final valor = (doc['valor'] ?? 0).toDouble();
                    final app = doc['app'] ?? "Desconhecido";
                    final data = (doc['data'] as Timestamp).toDate();

                    return Card(
                      color: Colors.white12,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading:
                            Icon(Icons.monetization_on, color: Colors.green),
                        title: Text("R\$ ${valor.toStringAsFixed(2)} - $app",
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            DateFormat('dd/MM/yyyy – HH:mm').format(data),
                            style: TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.cyanAccent),
                              onPressed: () =>
                                  abrirDialogEdicao(id, valor, app),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => excluirRecebimento(id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
