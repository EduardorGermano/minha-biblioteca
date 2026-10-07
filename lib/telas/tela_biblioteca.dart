import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modelos/obra.dart';
import '../banco/banco_dados.dart';
import '../servicos/biblioteca_memoria.dart';

class TelaBiblioteca extends StatefulWidget {
  const TelaBiblioteca({super.key});

  @override
  State<TelaBiblioteca> createState() => _TelaBibliotecaState();
}

class _TelaBibliotecaState extends State<TelaBiblioteca> {
  List<Obra> obras = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarObras();
  }

  Future<void> carregarObras() async {
    if (kIsWeb) {
      setState(() {
        obras = List.from(BibliotecaMemoria.obras);
        carregando = false;
      });

      return;
    }

    final resultado = await BancoDados.listarObras();

    if (!mounted) return;

    setState(() {
      obras = resultado;
      carregando = false;
    });
  }

  Future<void> excluirObra(Obra obra) async {
    if (kIsWeb) {
      BibliotecaMemoria.excluir(obra);
    } else {
      if (obra.id != null) {
        await BancoDados.excluirObra(obra.id!);
      }
    }

    await carregarObras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Biblioteca',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'cadastro',
            tooltip: 'Cadastrar obra',
            onPressed: () {
              context.go('/cadastro');
            },
            child: const Icon(Icons.edit),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: 'pesquisa',
            tooltip: 'Pesquisar obras',
            onPressed: () {
              context.go('/pesquisa');
            },
            child: const Icon(Icons.search),
          ),
        ],
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : obras.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_books,
                    size: 90,
                    color: Colors.white38,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Sua biblioteca está vazia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Pesquise uma obra ou faça um cadastro manual.',
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/pesquisa');
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Pesquisar obras'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () {
                      context.go('/cadastro');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Cadastrar manualmente'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: obras.length,
              itemBuilder: (context, index) {
                final obra = obras[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    onTap: () {
                      context.go('/editar', extra: obra);
                    },

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: obra.capa != null
                          ? Image.network(
                              obra.capa!,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 50,
                                  height: 70,
                                  child: Icon(Icons.menu_book, size: 35),
                                );
                              },
                            )
                          : const SizedBox(
                              width: 50,
                              height: 70,
                              child: Icon(Icons.menu_book, size: 35),
                            ),
                    ),

                    title: Text(
                      obra.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${obra.tipo} • ${obra.status}\n'
                        'Progresso: ${obra.progresso}',
                      ),
                    ),

                    isThreeLine: true,

                    trailing: IconButton(
                      tooltip: 'Excluir',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE50914),
                      ),
                      onPressed: () {
                        excluirObra(obra);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
