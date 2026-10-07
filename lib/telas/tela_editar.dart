import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modelos/obra.dart';
import '../banco/banco_dados.dart';
import '../servicos/biblioteca_memoria.dart';

class TelaEditar extends StatefulWidget {
  final Obra obra;

  const TelaEditar({super.key, required this.obra});

  @override
  State<TelaEditar> createState() => _TelaEditarState();
}

class _TelaEditarState extends State<TelaEditar> {
  late String tipo;
  late String status;

  late TextEditingController tituloController;
  late TextEditingController progressoController;
  late TextEditingController linkController;
  late TextEditingController capaController;

  bool salvando = false;

  @override
  void initState() {
    super.initState();

    tipo = widget.obra.tipo;
    status = widget.obra.status;

    tituloController = TextEditingController(text: widget.obra.titulo);

    progressoController = TextEditingController(
      text: widget.obra.progresso.toString(),
    );

    linkController = TextEditingController(text: widget.obra.link ?? '');

    capaController = TextEditingController(text: widget.obra.capa ?? '');
  }

  Future<void> salvarAlteracoes() async {
    final titulo = tituloController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da obra.')),
      );

      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final obraAtualizada = Obra(
        id: widget.obra.id,
        titulo: titulo,
        tipo: tipo,
        status: status,
        progresso: int.tryParse(progressoController.text) ?? 0,
        link: linkController.text.trim().isEmpty
            ? null
            : linkController.text.trim(),
        capa: capaController.text.trim().isEmpty
            ? null
            : capaController.text.trim(),
      );

      if (kIsWeb) {
        BibliotecaMemoria.atualizar(widget.obra, obraAtualizada);
      } else {
        await BancoDados.atualizarObra(obraAtualizada);
      }

      if (!mounted) return;

      context.go('/');
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar obra: $erro')));
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
    tituloController.dispose();
    progressoController.dispose();
    linkController.dispose();
    capaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar obra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.obra.capa != null
                  ? Image.network(
                      widget.obra.capa!,
                      width: 140,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 140,
                          height: 200,
                          child: Icon(Icons.menu_book, size: 100),
                        );
                      },
                    )
                  : const SizedBox(
                      width: 140,
                      height: 200,
                      child: Icon(Icons.menu_book, size: 100),
                    ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 20),

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

            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Link para leitura',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: capaController,
              decoration: const InputDecoration(
                labelText: 'Link da capa',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.image),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: salvando
                        ? null
                        : () {
                            context.go('/');
                          },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : salvarAlteracoes,
                    icon: salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Salvar alterações'),
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
