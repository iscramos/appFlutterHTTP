import 'dart:convert';

List<Usuarios> usuariosFromJson(String str) =>
    List<Usuarios>.from(json.decode(str).map((x) => Usuarios.fromJson(x)));

String usuariosToJson(List<Usuarios> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Usuarios {
  Usuarios({
    required this.idUsuario,
    required this.correo,
    required this.nombre,
  });

  String idUsuario = '';
  String correo = '';
  String nombre = '';

  factory Usuarios.fromJson(Map<String, dynamic> json) => Usuarios(
        idUsuario: json["idUsuario"],
        correo: json["correo"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "idUsuario": idUsuario,
        "correo": correo,
        "nombre": nombre,
      };
}
