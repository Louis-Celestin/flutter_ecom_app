import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/consts/env.const.dart';
import 'package:flutter_application_routinggp/models/routing.models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'routineform.screen.dart';

class RoutingPage extends StatefulWidget {
  @override
  _RoutingPageState createState() => _RoutingPageState();
}

class _RoutingPageState extends State<RoutingPage> {
  List<Routing> routings = [];
  bool isLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadRoutingData();
  }

  void loadRoutingData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? agentId = prefs.getInt('agentId');

    if (agentId != null) {
      final response = await http.post(
        Uri.parse('$baseLocalUrl/getRoutingByCommercial'),
        body: {'agentId': agentId.toString()},
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          setState(() {
            routings = jsonData.map((data) => Routing.fromJson(data)).toList();
            isLoading = false;
          });

          if (routings.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucune routine disponible.')),
            );
          }

          _refreshController.refreshCompleted();
        } catch (e) {
          print('Failed to parse routines: $e');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors du traitement des données.')),
          );
          _refreshController.refreshFailed();
        }
      } else {
        print('Failed to load routings: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des routings.')),
        );
        _refreshController.refreshFailed();
      }
    }
  }

  void _showRoutingDetailsModal(BuildContext context, Routing routing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du Routing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${routing.descriptionRouting}'),
              Text(
                  'Date début: ${DateFormat('dd/MM/yyyy HH:mm').format(routing.dateDebutRouting)}'),
              Text(
                  'Date fin: ${DateFormat('dd/MM/yyyy HH:mm').format(routing.dateFinRouting)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la modal
              },
              child: Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('selectedRoutingId', routing.id);
                print("Le routing Id est");
                print(routing.id);
                Navigator.of(context).pop(); // Fermer la modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineFormPage(),
                  ),
                );
              },
              child: Text('Faire la routine'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routing',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: loadRoutingData,
              header: WaterDropHeader(
                completeDuration: Duration(milliseconds: 500),
                idleIcon: Icon(Icons.arrow_downward, color: Colors.indigo),
                refresh: SizedBox(
                  height: 55.0,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: height * 0.08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Routing",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                          10), // Réduit le padding autour du tableau
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius:
                                3, // Réduit la taille de l'ombre portée
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowHeight: 30, // Réduit la hauteur de l'en-tête
                        dataRowHeight:
                            40, // Réduit la hauteur des lignes de données
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize:
                              14, // Réduit la taille du texte dans l'en-tête
                        ),
                        columns: [
                          DataColumn(
                              label: Text('Description',
                                  style: TextStyle(fontSize: 12))),
                          DataColumn(
                              label: Text('Date début',
                                  style: TextStyle(fontSize: 12))),
                          DataColumn(
                              label: Text('Date fin',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        rows: routings
                            .map(
                              (routing) => DataRow(
                                cells: [
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        _showRoutingDetailsModal(
                                            context, routing);
                                      },
                                      child: Text(routing.descriptionRouting),
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        _showRoutingDetailsModal(
                                            context, routing);
                                      },
                                      child: Text(DateFormat('dd/MM/yyyy HH:mm')
                                          .format(routing.dateDebutRouting)),
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        _showRoutingDetailsModal(
                                            context, routing);
                                      },
                                      child: Text(DateFormat('dd/MM/yyyy HH:mm')
                                          .format(routing.dateFinRouting)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
