import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_routinggp/consts/env.const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, String>> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final agentId = prefs.getInt('agentId');

    if (agentId == null) {
      throw Exception('Agent ID non disponible');
    }

    final response = await http.post(
      Uri.parse(baseLocalUrl + '/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'agentId': agentId}),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final profile = data[0];
      return {
        'nom': profile['nom_agent'],
        'prenom': profile['prenom_agent'],
        'email': profile['email_pro_agent'],
        'numero': profile['numero_telephone_agent'].toString(),
      };
    } else {
      throw Exception('Échec du chargement des données de profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: fetchProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profileData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${profileData['prenom']} ${profileData['nom']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.indigo),
                    title: Text(
                      'Email',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      profileData['email']!,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.indigo),
                    title: Text(
                      'Numéro de téléphone',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      profileData['numero']!,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        },
      ),
    );
  }
}
