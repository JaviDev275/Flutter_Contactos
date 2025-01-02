import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';


class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _MyContactsPageState();
}

class _MyContactsPageState extends State<Contacts> {
  Map<String, List<dynamic>> groupedContacts = {};
  bool isLoading = true;

  contactFetch() async {
    var status = await Permission.contacts.request();

    if (status.isGranted) {
      var contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Agrupar contactos por la primera letra de su nombre
      Map<String, List<dynamic>> grouped = {};
      for (var contact in contacts) {
        String initial = contact.displayName[0].toUpperCase();
        if (!grouped.containsKey(initial)) {
          grouped[initial] = [];
        }
        grouped[initial]?.add(contact);
      }

      setState(() {
        groupedContacts = grouped;
        isLoading = false;
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
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
        leading: IconButton(
          onPressed: () => {},
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text("Contactos", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 1),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedContacts.isEmpty
              ? const Center(
                  child: Text(
                    'No se han encontrado contactos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                )
              : ListView.builder(
                  itemCount: groupedContacts.keys.length,
                  itemBuilder: (context, index) {
                    String letter = groupedContacts.keys.elementAt(index);
                    List<dynamic> contacts = groupedContacts[letter]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            letter,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...contacts.map((contact) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: contact.photo != null
                                  ? Image.memory(contact.photo!)
                                  : Text(contact.displayName[0]),
                            ),
                            
                            title: Text(contact.displayName),
                            subtitle: contact.phones.isNotEmpty
                                ? Text(contact.phones[0].number)
                                : const Text('Sin número'),
                          );
                        })
                      ],
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () =>(),
                  backgroundColor: Color.fromRGBO(0, 122, 255, 1),
                  child: const Icon(Icons.add_outlined, color: Colors.white,),
                ),
    );
  }
}
