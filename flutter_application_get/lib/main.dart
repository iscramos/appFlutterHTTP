import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_get/models/usuarios.model.dart';

const posi = 0;
void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Principal',
      home: PantallaUno(0),
    ));

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({Key? key}) : super(key: key);

  @override
  _ListadoUsuarios createState() => _ListadoUsuarios();
}

class _ListadoUsuarios extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PantallaNuevo()))
              .then((value) => _stateUpdate());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: FutureBuilder(
          future: getUsuarios(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      title: Text(snapshot.data[i].nombre),
                      subtitle: Text(snapshot.data[i].correo),
                      leading: CircleAvatar(
                        child: Text((i + 1).toString()),
                      ),
                      trailing: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.red,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PantallaEliminar(
                                          registroEliminar: snapshot.data[i],
                                          idU: snapshot.data[i].idUsuario)))
                              .then((value) => _stateUpdate());
                        },
                        child: const Text('Eliminar'),
                      ),
                    );
                  });
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  void _stateUpdate() {
    setState(() {});
  }
}

class PantallaUno extends StatefulWidget {
  const PantallaUno(int i, {Key? key}) : super(key: key);

  @override
  State<PantallaUno> createState() => _PantallaUno();
}

// Esta clase es para navegar con los botones del bottom
class _PantallaUno extends State<PantallaUno> {
  int selectedIndex = 0;

  final List<Widget> widgetOptions = <Widget>[
    const Text('Bienvenidos a la sesión II'),
    const PantallaUsuarios(),
  ];

  onItemTapped(int index) {
    //print('Opcíon -> $index');
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Obtener y enviar información HTTP'),
          automaticallyImplyLeading: false),
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Usuarios'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}

Future<List<Usuarios>> getUsuarios() async {
  final response =
      await http.get(Uri.parse('https://cenedic4.ucol.mx/demopa/usersApi.php'));

  if (response.statusCode == 200) {
    // Si el servidor devuelve una repuesta OK, parseamos el JSON
    //print(response.body);
    return usuariosFromJson(response.body);
  } else {
    // Si esta respuesta no fue OK, lanza un error.
    return throw Exception('Failed to load post');
  }
}

// Pantalla nuevo
class PantallaNuevo extends StatelessWidget {
  const PantallaNuevo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: const MiFormulario(),
      ),
    );
  }
}

class MiFormulario extends StatefulWidget {
  const MiFormulario({Key? key}) : super(key: key);

  @override
  Formulario createState() {
    return Formulario();
  }
}

class Formulario extends State<MiFormulario> {
  final _miNombre = TextEditingController();
  final _miCorreo = TextEditingController();
  final _miPassword = TextEditingController();

  //Future<http.Response>? _futureUsuario;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _miNombre,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) {
              if (value == '') {
                return '*';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _miCorreo,
            decoration: const InputDecoration(labelText: 'Correo'),
            validator: (value) {
              if (value == '') {
                return '*';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _miPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value == '') {
                return '*';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Usuario guardado...'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ));

                  setState(() {
                    createUsuario(
                        _miNombre.text, _miCorreo.text, _miPassword.text);

                    /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PantallaUno(1)));*/
                  });

                  Future.delayed(const Duration(seconds: 2), () async {
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          )
        ],
      ),
    );
  }
}

/*Future<String> createUsuario(
  String nombre,
  String correo,
  String password,
) async {
  final response = await http.post(
    Uri.parse('https://cenedic4.ucol.mx/demopa/createUser.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String>{
      'nombre': nombre,
      'correo': correo,
      'password': password
    }),
  );

  final body = (response.body);
  print(body);

  if (response.statusCode == 200) {
    return body;
  } else {
    throw Exception('Failed to create usuario');
  }
}*/

Future<http.Response> createUsuario(
    String nombre, String correo, String password) {
  return http.post(
    Uri.parse('https://cenedic4.ucol.mx/demopa/createUser.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'nombre': nombre,
      'correo': correo,
      'password': password
    }),
  );
}

// ventana de eliminar

class PantallaEliminar extends StatelessWidget {
  final String idU;
  final Usuarios registroEliminar;

  // En el constructor, se requiere un objeto Todo
  const PantallaEliminar(
      {Key? key, required this.registroEliminar, required this.idU})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mensaje'),
      content: Text('¿Desea eliminar a ${registroEliminar.nombre} ?',
          style: const TextStyle(fontSize: 16, color: Colors.red)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'No'),
          child: const Text('No'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          onPressed: () {
            final regPersonitaEliminar = Personita();
            regPersonitaEliminar.eliminarPesona(idU);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('¡${registroEliminar.nombre} eliminado!'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ));

            Future.delayed(const Duration(seconds: 2), () async {
              Navigator.pop(context);
            });
          } /*=> Navigator.pop(context, 'Sí')*/,
          child: const Text('Sí'),
        ),
      ],
    );
  }
}

class Personita {
  void eliminarPesona(String idU) {
    eliminarUsuario(idU);
  }
}

Future<http.Request?> eliminarUsuario(String idU) async {
  //print(idU);
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'GET', Uri.parse('https://cenedic4.ucol.mx/demopa/delUsuario.php'));
  request.body = json.encode({"id": idU});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    response.stream.bytesToString();
  } else {
    response.reasonPhrase;
  }
  return null;
}
