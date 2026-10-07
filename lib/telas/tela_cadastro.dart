import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modelos/obra.dart';
import '../banco/banco_dados.dart';
import '../servicos/biblioteca_memoria.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController tituloController = TextEditingController();

  final TextEditingController progressoController = TextEditingController(
    text: '0',
  );

  final TextEditingController linkController = TextEditingController();

  final TextEditingController capaController = TextEditingController();

  String tipo = 'Livro';
  String status = 'Quero ler';

  bool salvando = false;

  Future<void> salvar() async {
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
      final obra = Obra(
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
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar obra: $erro')));
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
          'Cadastrar obra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.library_add, size: 80, color: Color(0xFFE50914)),

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
                labelText: 'Link para leitura (opcional)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: capaController,
              decoration: const InputDecoration(
                labelText: 'Link da capa (opcional)',
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
                    onPressed: salvando ? null : salvar,
                    icon: salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Cadastrar'),
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
