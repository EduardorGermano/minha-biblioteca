import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modelos/obra.dart';
import '../servicos/open_library_service.dart';

class TelaPesquisa extends StatefulWidget {
  const TelaPesquisa({super.key});

  @override
  State<TelaPesquisa> createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  final TextEditingController pesquisaController = TextEditingController();

  List<dynamic> resultados = [];

  bool carregando = false;

  Future<void> pesquisar() async {
    if (pesquisaController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final livros = await OpenLibraryService.pesquisarLivros(
        pesquisaController.text,
      );

      if (!mounted) return;

      setState(() {
        resultados = livros;
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao pesquisar obras')));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: const Text(
          'Pesquisar obras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesquisaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da obra',
                      hintText: 'Ex: Harry Potter',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (valor) {
                      pesquisar();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: carregando ? null : pesquisar,
                  child: const Text('Pesquisar'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (carregando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (resultados.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Pesquise uma obra para começar.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final livro = resultados[index];

                    final titulo = livro['title'] ?? 'Título desconhecido';

                    final autores = livro['author_name'];

                    String autor = 'Autor desconhecido';

                    if (autores != null && autores.isNotEmpty) {
                      autor = autores[0];
                    }

                    final capaId = livro['cover_i'];

                    final String? capa = capaId != null
                        ? 'https://covers.openlibrary.org/b/id/$capaId-L.jpg'
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: capa != null
                              ? Image.network(
                                  capa,
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
                          titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(autor),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                        onTap: () {
                          final obra = Obra(
                            titulo: titulo,
                            tipo: 'Livro',
                            status: 'Quero ler',
                            progresso: 0,
                            capa: capa,
                          );

                          context.go('/detalhes', extra: obra);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
