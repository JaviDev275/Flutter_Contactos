import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List contactList = [];
  var isLoading = true;
  contactFetch() async {
    if (await FlutterContacts.requestPermission()) {
      var contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      var encodeData = await jsonEncode(contacts);
      var decodeData = await jsonDecode(encodeData);
      contactList = await decodeData;
      print(decodeData);
      setState(() {});
    }
    isLoading = false;
  }

  @override
  void initState() {
    contactFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Contactos"),
      ),
      body: Center(
        child: 
          contactList.isEmpty
          ?isLoading
            ?CircularProgressIndicator()
              : Text(
                    'No se han encontrado contactos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  
                )
              : ListView.builder(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemCount: contactList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        contactList[index]['displayName'],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        contactList[index]['phones'][0]['number'],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
