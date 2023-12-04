class Categories {
  final int? id;
  final String imagen;
  final String texto;
  final String colorCategory;

  Categories({this.id, 
  required this.imagen, 
  required this.texto,
  required this.colorCategory});

  Map<String, dynamic> toMap() {
    return {'id': id, 
    'imagen': imagen, 
    'texto': texto,
    'colorCategory': colorCategory};
  }

   Categories.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        imagen = map['imagen'],
        texto = map['texto'],
        colorCategory = map['colorCategory'];
}
