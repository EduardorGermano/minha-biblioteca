import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modelos/obra.dart';
import '../banco/banco_dados.dart';
import '../servicos/biblioteca_memoria.dart';

class TelaDetalhes extends StatefulWidget {
  final Obra obra;

  const TelaDetalhes({super.key, required this.obra});

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  late String tipo;
  late String status;

  final TextEditingController progressoController = TextEditingController();

  final TextEditingController linkController = TextEditingController();

  bool salvando = false;

  @override
  void initState() {
    super.initState();

    tipo = widget.obra.tipo;
    status = widget.obra.status;

    progressoController.text = widget.obra.progresso.toString();

    linkController.text = widget.obra.link ?? '';
  }

  Future<void> salvarObra() async {
    setState(() {
      salvando = true;
    });

    try {
      final obra = Obra(
        titulo: widget.obra.titulo,
        tipo: tipo,
        status: status,
        progresso: int.tryParse(progressoController.text) ?? 0,
        link: linkController.text.trim().isEmpty
            ? null
            : linkController.text.trim(),
        capa: widget.obra.capa,
      );

      if (kIsWeb) {
        BibliotecaMemoria.adicionar(obra);
      } else {
        await BancoDados.inserirObra(obra);
      }

      if (!mounted) return;

      context.go('/');
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar obra: $erro')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    progressoController.dispose();
    linkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // VOLTAR PARA A PESQUISA
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/pesquisa');
          },
        ),

        title: const Text(
          'Detalhes da obra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CAPA
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.obra.capa != null
                    ? Image.network(
                        widget.obra.capa!,
                        width: 180,
                        height: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 180,
                            height: 260,
                            child: Icon(
                              Icons.menu_book,
                              size: 120,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                    : const SizedBox(
                        width: 180,
                        height: 260,
                        child: Icon(
                          Icons.menu_book,
                          size: 120,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // TÍTULO
            Text(
              widget.obra.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // TIPO
            DropdownButtonFormField<String>(
              initialValue: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'Livro', child: Text('Livro')),
                DropdownMenuItem(value: 'Mangá', child: Text('Mangá')),
                DropdownMenuItem(
                  value: 'Light Novel',
                  child: Text('Light Novel'),
                ),
                DropdownMenuItem(value: 'Web Novel', child: Text('Web Novel')),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    tipo = valor;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // STATUS
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.bookmark),
              ),
              items: const [
                DropdownMenuItem(value: 'Quero ler', child: Text('Quero ler')),
                DropdownMenuItem(value: 'Lendo', child: Text('Lendo')),
                DropdownMenuItem(value: 'Concluído', child: Text('Concluído')),
                DropdownMenuItem(value: 'Pausado', child: Text('Pausado')),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    status = valor;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // PROGRESSO
            TextField(
              controller: progressoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Progresso',
                hintText: 'Página ou capítulo atual',
                prefixIcon: Icon(Icons.auto_stories),
              ),
            ),

            const SizedBox(height: 20),

            // LINK
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Link para leitura (opcional)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÕES
            Row(
              children: [
                // VOLTAR / CANCELAR
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: salvando
                        ? null
                        : () {
                            context.go('/pesquisa');
                          },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ),

                const SizedBox(width: 15),

                // ADICIONAR
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : salvarObra,
                    icon: salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.library_add),
                    label: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
