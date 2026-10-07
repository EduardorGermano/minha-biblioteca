class Obra {
  final int? id;
  final String titulo;
  final String tipo;
  final String status;
  final int progresso;
  final String? link;
  final String? capa;

  Obra({
    this.id,
    required this.titulo,
    required this.tipo,
    required this.status,
    required this.progresso,
    this.link,
    this.capa,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'status': status,
      'progresso': progresso,
      'link': link,
      'capa': capa,
    };
  }

  factory Obra.fromMap(Map<String, dynamic> map) {
    return Obra(
      id: map['id'],
      titulo: map['titulo'],
      tipo: map['tipo'],
      status: map['status'],
      progresso: map['progresso'],
      link: map['link'],
      capa: map['capa'],
    );
  }
}