import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenLibraryService {
  static Future<List<dynamic>> pesquisarLivros(String pesquisa) async {
    final url = Uri.parse(
      'https://openlibrary.org/search.json?q=${Uri.encodeComponent(pesquisa)}&limit=10',
    );

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      return dados['docs'];
    } else {
      throw Exception('Erro ao pesquisar livros');
    }
  }
}