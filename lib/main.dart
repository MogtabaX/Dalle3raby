import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "دالي بالعربي",
      theme: ThemeData(primaryColor: Colors.red),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController input = TextEditingController();
  String apikey = dotenv.env['key'] ?? 'API URL NOT FOUND';
  String url = "https://api.openai.com/v1/images/generations";
  String? image;
  GoogleTranslator translator = GoogleTranslator();
  String translated = "";
  void translate() {
    translator.translate(input.text, to: "en").then((output) {
      setState(() {
        translated = output.text;
        getAiImage(translated);
      });
    });
  }

  void getAiImage(String outx) async {
    if (input.text.isNotEmpty) {
      var data = {
        "prompt": outx,
        "n": 1,
        "size": "256x256",
      };

      var res = await http.post(Uri.parse(url),
          headers: {
            "Authorization": "Bearer ${apikey}",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data));

      var jsonResponse = jsonDecode(res.body);

      image = jsonResponse['data'][0]['url'];

      setState(() {});
    } else {
      print("Enter something");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "دالي بالعربي",
          textAlign: TextAlign.end,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null
                ? Image.network(image!, width: 256, height: 265)
                : Container(
                    child: Text("ستظهر الصورة هنا"),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                controller: input,
                decoration: InputDecoration(
                    hintText: " اكتب هنا",
                    filled: true,
                    fillColor: Colors.blue.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    )),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                translate();
              },
              child: Text("انشاء"),
            ),
            OutlinedButton(
              onPressed: () {},
              child: Text("تحميل"),
            )
          ],
        ),
      ),
    );
  }
}
