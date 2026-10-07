import '../modelos/obra.dart';

class BibliotecaMemoria {
  static final List<Obra> obras = [];

  static void adicionar(Obra obra) {
    obras.add(obra);
  }

  static void excluir(Obra obra) {
    obras.remove(obra);
  }

  static void atualizar(Obra obraAntiga, Obra obraNova) {
    final index = obras.indexOf(obraAntiga);

    if (index != -1) {
      obras[index] = obraNova;
    }
  }
}
