import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivercash/relatorios_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'recebimentos_page.dart';
import 'package:drivercash/abastecimento_page.dart' as abastecimento_page;
import 'package:drivercash/manutencao_page.dart' as manutencao_page;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user;
  final firestore = FirebaseFirestore.instance;

  double ganhos = 0.0;
  double despesas = 0.0;
  bool carregando = true;

  List<Map<String, dynamic>> transacoes = [];

  StreamSubscription<QuerySnapshot>? _recebimentosSub;
  StreamSubscription<QuerySnapshot>? _abastecimentosSub;
  StreamSubscription<QuerySnapshot>? _manutencoesSub;

  double despesasAbastecimentos = 0.0;
  double despesasManutencoes = 0.0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _setupListeners();
      // Carregamento inicial das transações
      _atualizarTransacoes();
    } else {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  void _setupListeners() {
    final uid = user!.uid;

    // Stream para recebimentos
    _recebimentosSub = firestore
        .collection('usuarios')
        .doc(uid)
        .collection('recebimentos')
        .orderBy('data', descending: true) // Adiciona ordenação
        .snapshots()
        .listen((snapshot) {
      double totalGanhos = 0.0;
      for (var doc in snapshot.docs) {
        try {
          double valor = (doc.data()['valor'] ?? 0).toDouble();
          totalGanhos += valor;
        } catch (e) {
          print("Erro ao processar recebimento: $e");
        }
      }

      if (mounted) {
        setState(() {
          ganhos = totalGanhos;
          carregando = false;
        });
        // Chama atualização das transações sempre que recebimentos mudam
        _atualizarTransacoes();
      }
    }, onError: (error) {
      print("Erro no stream de recebimentos: $error");
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    });

    // Stream para abastecimentos
    _abastecimentosSub = firestore
        .collection('usuarios')
        .doc(uid)
        .collection('abastecimentos')
        .orderBy('data', descending: true) // Adiciona ordenação
        .snapshots()
        .listen((snapshot) {
      double totalDespesas = 0.0;
      for (var doc in snapshot.docs) {
        try {
          double valor = (doc.data()['valor'] ?? 0).toDouble();
          totalDespesas += valor;
        } catch (e) {
          print("Erro ao processar abastecimento: $e");
        }
      }

      if (mounted) {
        setState(() {
          despesasAbastecimentos = totalDespesas;
          despesas = despesasAbastecimentos + despesasManutencoes;
          carregando = false;
        });
        // Chama atualização das transações sempre que abastecimentos mudam
        _atualizarTransacoes();
      }
    }, onError: (error) {
      print("Erro no stream de abastecimentos: $error");
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    });

    // Stream para manutenções
    _manutencoesSub = firestore
        .collection('usuarios')
        .doc(uid)
        .collection('manutencoes')
        .orderBy('data', descending: true) // Adiciona ordenação
        .snapshots()
        .listen((snapshot) {
      double totalManutencoes = 0.0;
      for (var doc in snapshot.docs) {
        try {
          double valor = (doc.data()['valor'] ?? 0).toDouble();
          totalManutencoes += valor;
        } catch (e) {
          print("Erro ao processar manutenção: $e");
        }
      }

      if (mounted) {
        setState(() {
          despesasManutencoes = totalManutencoes;
          despesas = despesasAbastecimentos + despesasManutencoes;
          carregando = false;
        });
        // Chama atualização das transações sempre que manutenções mudam
        _atualizarTransacoes();
      }
    }, onError: (error) {
      print("Erro no stream de manutenções: $error");
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    });
  }

  Future<void> _atualizarTransacoes() async {
    if (!mounted) return;

    try {
      final uid = user!.uid;
      List<Map<String, dynamic>> tempTransacoes = [];

      // Buscar recebimentos com ordenação por data
      final recebimentosSnap = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('recebimentos')
          .orderBy('data', descending: true)
          .get();

      for (var doc in recebimentosSnap.docs) {
        try {
          final data = doc.data();
          double valor = (data['valor'] ?? 0).toDouble();

          // Verifica se tem o campo data e se é um Timestamp válido
          Timestamp? timestamp = data['data'] as Timestamp?;
          DateTime dataTransacao;

          if (timestamp != null) {
            dataTransacao = timestamp.toDate();
          } else {
            // Se não tem data, usa a data atual
            dataTransacao = DateTime.now();
          }

          tempTransacoes.add({
            'id': doc.id,
            'descricao': data['descricao'] ?? 'Receita',
            'valor': valor,
            'data': dataTransacao,
            'tipo': 'receita',
          });
        } catch (e) {
          print("Erro ao processar recebimento ${doc.id}: $e");
        }
      }

      // Buscar abastecimentos com ordenação por data
      final abastecimentosSnap = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('abastecimentos')
          .orderBy('data', descending: true)
          .get();

      for (var doc in abastecimentosSnap.docs) {
        try {
          final data = doc.data();
          double valor = (data['valor'] ?? 0).toDouble();

          // Verifica se tem o campo data e se é um Timestamp válido
          Timestamp? timestamp = data['data'] as Timestamp?;
          DateTime dataTransacao;

          if (timestamp != null) {
            dataTransacao = timestamp.toDate();
          } else {
            // Se não tem data, usa a data atual
            dataTransacao = DateTime.now();
          }

          tempTransacoes.add({
            'id': doc.id,
            'descricao': data['descricao'] ?? 'Abastecimento',
            'valor': -valor,
            'data': dataTransacao,
            'tipo': 'despesa',
          });
        } catch (e) {
          print("Erro ao processar abastecimento ${doc.id}: $e");
        }
      }

      // Buscar manutenções com ordenação por data
      final manutencoesSnap = await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('manutencoes')
          .orderBy('data', descending: true)
          .get();

      for (var doc in manutencoesSnap.docs) {
        try {
          final data = doc.data();
          double valor = (data['valor'] ?? 0).toDouble();

          // Verifica se tem o campo data e se é um Timestamp válido
          Timestamp? timestamp = data['data'] as Timestamp?;
          DateTime dataTransacao;

          if (timestamp != null) {
            dataTransacao = timestamp.toDate();
          } else {
            // Se não tem data, usa a data atual
            dataTransacao = DateTime.now();
          }

          tempTransacoes.add({
            'id': doc.id,
            'descricao': data['descricao'] ?? 'Manutenção',
            'valor': -valor,
            'data': dataTransacao,
            'tipo': 'despesa',
          });
        } catch (e) {
          print("Erro ao processar manutenção ${doc.id}: $e");
        }
      }

      // Ordenar por data (mais recente primeiro)
      tempTransacoes.sort((a, b) => b['data'].compareTo(a['data']));

      if (mounted) {
        setState(() {
          transacoes = tempTransacoes;
          carregando = false;
        });
        print(
            "Total de transações carregadas: ${tempTransacoes.length}"); // Debug
      }
    } catch (e) {
      print("Erro ao carregar transações: $e");
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _recebimentosSub?.cancel();
    _abastecimentosSub?.cancel();
    _manutencoesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saldo = ganhos - despesas;
    const fundoEscuro = Color(0xFF111111);

    if (carregando) {
      return const Scaffold(
        backgroundColor: fundoEscuro,
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: fundoEscuro,
      appBar: AppBar(
        backgroundColor: fundoEscuro,
        elevation: 0,
        title: const Text(""),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final sair = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Confirmação',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Deseja realmente sair da conta?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );

              if (sair == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizarTransacoes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Olá, usuário!\n",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "Controle seu negócio",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Saldo Total",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "R\$ ${saldo.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Receitas\nR\$ ${ganhos.toStringAsFixed(2)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Despesas\nR\$ ${despesas.toStringAsFixed(2)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Ações Rápidas",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _acaoRapida(Icons.attach_money, "Nova Receita"),
                  _acaoRapida(Icons.local_gas_station, "Nova Despesa"),
                  _acaoRapida(Icons.build, "Manutenção"),
                  _acaoRapida(Icons.bar_chart, "Relatórios"),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Todas as Transações",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${transacoes.length} registros",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Verifica se há transações
              transacoes.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: Colors.white54,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Nenhuma transação encontrada",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Adicione receitas ou despesas para começar",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transacoes.length,
                      itemBuilder: (context, index) {
                        return _buildTransacao(transacoes[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _acaoRapida(IconData icon, String label) {
    return InkWell(
      onTap: () async {
        if (label == "Nova Receita") {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecebimentosPage()),
          );
          // Força atualização das transações após retornar
          if (mounted) {
            await _atualizarTransacoes();
          }
        } else if (label == "Nova Despesa") {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => abastecimento_page.AbastecimentoPage(),
            ),
          );
          // Força atualização das transações após retornar
          if (mounted) {
            await _atualizarTransacoes();
          }
        } else if (label == "Manutenção") {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => manutencao_page.ManutencaoPage(),
            ),
          );
          // Força atualização das transações após retornar
          if (mounted) {
            await _atualizarTransacoes();
          }
        } else if (label == "Relatórios") {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RelatoriosPage(),
            ),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            radius: 26,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransacao(Map<String, dynamic> t) {
    final valor = t['valor'] ?? 0.0;
    final corValor = valor >= 0 ? Colors.greenAccent : Colors.redAccent;
    final dataFormatada = DateFormat('dd/MM/yyyy').format(t['data']);
    final horaFormatada = DateFormat('HH:mm').format(t['data']);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícone do tipo de transação
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corValor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              valor >= 0 ? Icons.trending_up : Icons.trending_down,
              color: corValor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Informações da transação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['descricao'] ?? 'Sem descrição',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "$dataFormatada às $horaFormatada",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Valor
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${valor >= 0 ? '+' : ''}R\$ ${valor.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  color: corValor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                t['tipo'] ?? '',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
