import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=834c63c9";
main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.greenAccent[400],
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent[400])),
          hintStyle: TextStyle(color: Colors.greenAccent[400]),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar / this.dolar).toStringAsFixed(2);
    euroController.text = (dolar / this.dolar * euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro / this.euro).toStringAsFixed(2);
    dolarController.text = (euro / this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de moeda"),
        backgroundColor: Colors.greenAccent[400],
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.greenAccent[400], fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro...",
                      style: TextStyle(color: Colors.greenAccent[400], fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  var data = snapshot.data["results"]["currencies"];
                  dolar = data["USD"]["buy"];
                  euro = data["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.greenAccent[400]),
                        Divider(),
                        buildTextFiel(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextFiel(
                            "Dolares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextFiel(
                            "Euros", "€\$", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFiel(String label, String prefix,
    TextEditingController controller, Function func) {
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: func,
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.greenAccent[400]),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.greenAccent[400], fontSize: 25),
  );
}
