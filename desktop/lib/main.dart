import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarUltimaURL();
  }

  Future<File> _obtenerArchivoURL() async {
    final directorio = Directory.current;
    return File("${directorio.path}/url.txt");
  }

  Future<void> _cargarUltimaURL() async {
    try {
      final directorio = Directory.current;
      final rutaArchivo = "${directorio.path}/url.txt";
      File archivo = File(rutaArchivo);
      String url = await archivo.readAsString();
      setState(() {
        _serverUrlController.text = url;
      });
    } catch (e) {
      print("Error al cargar la URL: $e");
    }
  }

  Future<void> _guardarURL(String url) async {
    try {
      final directorio = Directory.current;
      final rutaArchivo = "${directorio.path}/url.txt";
      File archivo = File(rutaArchivo);
      await archivo.writeAsString(url);
      print('URL guardada correctamente: $url');
    } catch (e) {
      print("Error al guardar la URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: InputDecoration(labelText: 'Server URL'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    String serverUrl = _serverUrlController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Aquí deberías realizar la lógica para enviar la solicitud al servidor
    // y manejar la respuesta. Utiliza la URL proporcionada por el usuario
    // para acceder a la API y realizar las operaciones necesarias.

    // Por ejemplo, aquí se puede hacer una solicitud de autenticación
    await _guardarURL(serverUrl); // Guardar la URL introducida por el usuario

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/user/login'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Si la solicitud es exitosa, puedes manejar la respuesta
        // Aquí puedes guardar el token de autenticación en el almacenamiento local, etc.
        // Por ahora, simplemente mostraremos un mensaje de éxito
        final responseData = json.decode(response.body);
        String token = responseData['token'];
        setState(() {
          _errorMessage = 'Login successful! Token: $token';
        });
      } else {
        // Si la solicitud no es exitosa, muestra un mensaje de error
        setState(() {
          _errorMessage =
              'Login failed. Please check your credentials and try again.';
        });
      }
    } catch (e) {
      // En caso de error, muestra un mensaje de error genérico
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }
}
