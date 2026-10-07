import 'package:go_router/go_router.dart';

import 'modelos/obra.dart';
import 'telas/tela_biblioteca.dart';
import 'telas/tela_pesquisa.dart';
import 'telas/tela_detalhes.dart';
import 'telas/tela_cadastro.dart';
import 'telas/tela_editar.dart';

final GoRouter rotas = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TelaBiblioteca()),

    GoRoute(
      path: '/pesquisa',
      builder: (context, state) => const TelaPesquisa(),
    ),

    GoRoute(
      path: '/detalhes',
      builder: (context, state) {
        final obra = state.extra as Obra;

        return TelaDetalhes(obra: obra);
      },
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const TelaCadastro(),
    ),
    GoRoute(
      path: '/editar',
      builder: (context, state) {
        final obra = state.extra as Obra;

        return TelaEditar(obra: obra);
      },
    ),
  ],
);
