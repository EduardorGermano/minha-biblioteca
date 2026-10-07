import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modelos/obra.dart';

class BancoDados {
  static Future<Database> conectar() async {
    final caminhoBanco = await getDatabasesPath();

    final caminho = join(caminhoBanco, 'biblioteca.db');

    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE obras(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            tipo TEXT NOT NULL,
            status TEXT NOT NULL,
            progresso INTEGER NOT NULL,
            link TEXT,
            capa TEXT
          )
        ''');
      },
    );
  }

  static Future<void> inserirObra(Obra obra) async {
    final db = await conectar();

    await db.insert('obras', obra.toMap());
  }

  static Future<List<Obra>> listarObras() async {
    final db = await conectar();

    final resultado = await db.query('obras', orderBy: 'id DESC');

    return resultado.map((map) {
      return Obra.fromMap(map);
    }).toList();
  }

  static Future<void> atualizarObra(Obra obra) async {
    final db = await conectar();

    await db.update(
      'obras',
      obra.toMap(),
      where: 'id = ?',
      whereArgs: [obra.id],
    );
  }

  static Future<void> excluirObra(int id) async {
    final db = await conectar();

    await db.delete('obras', where: 'id = ?', whereArgs: [id]);
  }
}
