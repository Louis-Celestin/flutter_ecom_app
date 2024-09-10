import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/consts/env.const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_routinggp/models/routine.models.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'routineform.screen.dart';

class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  List<Routine> routines = [];
  List<Routine> filteredRoutines = [];
  bool isLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    loadRoutineData();
  }

  void loadRoutineData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? agentId = prefs.getInt('agentId');

    if (agentId != null) {
      final response = await http.post(
        Uri.parse('$baseLocalUrl/getRoutineByCommercial'),
        body: {'agentId': agentId.toString()},
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          setState(() {
            routines = jsonData.map((data) => Routine.fromJson(data)).toList();
            filteredRoutines =
                List.from(routines); // Initialize with all routines
            isLoading = false;
          });

          if (routines.isEmpty) {
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
        print('Failed to load routines: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des routines.')),
        );
        _refreshController.refreshFailed();
      }
    } else {
      print('Failed to get agentId from preferences');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de récupérer l\'ID de l\'agent.')),
      );
      _refreshController.refreshFailed();
    }
  }

  void _showRoutineDetails(Routine routine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de la Routine'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Marchand: ${routine.pointMarchandRoutine}'),
                Text('Concurrence: ${routine.veilleConcurentielleRoutine}'),
                Text(
                    'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(routine.dateRoutine!.toLocal())}'),
                // Ajoutez ici toutes les informations que vous souhaitez afficher
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterByDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        filteredRoutines = routines.where((routine) {
          if (routine.dateRoutine == null) return false;
          DateTime routineDate = routine.dateRoutine!.toLocal();
          return routineDate.year == selectedDate.year &&
              routineDate.month == selectedDate.month &&
              routineDate.day == selectedDate.day;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routine',
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
              onRefresh: loadRoutineData,
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
                            "Routine",
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowHeight: 30,
                        dataRowHeight: 40,
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 14,
                        ),
                        columns: [
                          DataColumn(
                              label: Text('Marchand',
                                  style: TextStyle(fontSize: 12))),
                          DataColumn(
                              label: Text('Concurrence',
                                  style: TextStyle(fontSize: 12))),
                          DataColumn(
                            label: Row(
                              children: [
                                Text('Date', style: TextStyle(fontSize: 12)),
                                IconButton(
                                  icon:
                                      Icon(Icons.filter_alt_outlined, size: 18),
                                  onPressed: _filterByDate,
                                ),
                              ],
                            ),
                          ),
                        ],
                        rows: filteredRoutines.map((routine) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  routine.pointMarchandRoutine,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  _showRoutineDetails(routine);
                                },
                              ),
                              DataCell(
                                Text(
                                  routine.veilleConcurentielleRoutine,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  _showRoutineDetails(routine);
                                },
                              ),
                              DataCell(
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(routine.dateRoutine!.toLocal()),
                                  style: TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  _showRoutineDetails(routine);
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineFormPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
