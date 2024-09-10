import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/components/sidebar.components.dart';
import 'package:flutter_application_routinggp/models/routing.models.dart';
import 'package:flutter_application_routinggp/screens/routing.screen.dart';
import 'package:flutter_application_routinggp/screens/routine.screen.dart';
import 'package:flutter_application_routinggp/screens/routineform.screen.dart';
import 'package:flutter_application_routinggp/screens/profile.screen.dart'; // Import the profile screen
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:flutter_application_routinggp/screens/login.screen.dart'; // Import the login screen

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  // Future<void> _logout(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs
  //       .remove('username'); // Remove the user data from shared_preferences
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //     (Route<dynamic> route) => false,
  //   ); // Redirect to the login page
  // }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('token');
    await prefs.remove('agentId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    List<String> imgdata = [
      "assets/images/others/routine.png",
      "assets/images/others/deploy.png"
    ];

    List<String> titles = ["ROUTINE", "ROUTING"];

    return Scaffold(
      drawer: Sidebar(),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          color: Colors.indigo,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(),
                height: height * 0.25,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 35, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) => InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: const Icon(
                                Icons.sort,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'profile') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              } else if (result == 'logout') {
                                _logout(context);
                              }
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/images/others/user.png"),
                                ),
                              ),
                              height: 50,
                              width: 40,
                            ),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'profile',
                                child: Text('Profil'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Text('Déconnexion'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, left: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tableau de bord",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: height * 0.75,
                width: width,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 25,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: imgdata.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoutinePage()),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoutingPage()),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              imgdata[index],
                              width: 100,
                            ),
                            Text(
                              titles[index],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
