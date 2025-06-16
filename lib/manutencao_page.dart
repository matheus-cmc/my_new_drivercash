import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManutencaoPage extends StatefulWidget {
  @override
  _ManutencaoPageState createState() => _ManutencaoPageState();
}

class _ManutencaoPageState extends State<ManutencaoPage> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  String tipoSelecionado = "Troca de óleo";

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final List<String> tipos = [
    "Troca de óleo",
    "Pneus",
    "Lavagem",
    "Mecânica",
    "Outros",
  ];

  // 🔸 Adicionar ou Atualizar
  Future<void> salvarManutencao({String? docId}) async {
    final valor = double.tryParse(_valorController.text.trim()) ?? 0;

    if (valor <= 0 || _descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente')),
      );
      return;
    }

    final dados = {
      'tipo': tipoSelecionado,
      'descricao': _descricaoController.text.trim(),
      'valor': valor,
      'data': Timestamp.now(),
    };

    final ref = firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('manutencoes');

    if (docId == null) {
      await ref.add(dados);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Manutenção adicionada!')));
    } else {
      await ref.doc(docId).update(dados);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Manutenção atualizada!')));
    }

    _descricaoController.clear();
    _valorController.clear();
    setState(() {
      tipoSelecionado = "Troca de óleo";
    });

    Navigator.pop(context); // Voltar para a Dashboard
  }

  // 🔸 Deletar
  Future<void> deletarManutencao(String docId) async {
    await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('manutencoes')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Manutenção excluída!')),
    );
  }

  // 🔸 Stream dos dados
  Stream<QuerySnapshot> getManutencoes() {
    return firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('manutencoes')
        .orderBy('data', descending: true)
        .snapshots();
  }

  // 🔸 Preencher dados para edição
  void preencherCampos(DocumentSnapshot doc) {
    setState(() {
      tipoSelecionado = doc['tipo'];
      _descricaoController.text = doc['descricao'];
      _valorController.text = doc['valor'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.cyanAccent),
        title: Text("Manutenção", style: TextStyle(color: Colors.cyanAccent)),
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
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    items: tipos.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tipoSelecionado = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Tipo de Manutenção",
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
                  SizedBox(height: 12),
                  TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: "Descrição",
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
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: "Valor (R\$)",
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
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => salvarManutencao(),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Adicionar Manutenção",
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
              stream: getManutencoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty)
                  return Center(
                      child: Text("Nenhuma manutenção registrada.",
                          style: TextStyle(color: Colors.white70)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final tipo = doc['tipo'];
                    final descricao = doc['descricao'];
                    final valor = doc['valor'];
                    final data = (doc['data'] as Timestamp).toDate();

                    return Card(
                      color: Colors.white12,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.build, color: Colors.amber),
                        title: Text("$tipo - R\$ ${valor.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            "${descricao}\n${DateFormat('dd/MM/yyyy').format(data)}",
                            style: TextStyle(color: Colors.white70)),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              preencherCampos(doc);
                            } else if (value == 'excluir') {
                              deletarManutencao(doc.id);
                            }
                          },
                          icon: Icon(Icons.more_vert, color: Colors.white70),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
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
