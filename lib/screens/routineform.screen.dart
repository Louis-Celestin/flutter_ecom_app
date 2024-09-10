import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/consts/env.const.dart';
import 'package:flutter_application_routinggp/models/routine.models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutineFormPage extends StatefulWidget {
  @override
  _RoutineFormPageState createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _controller;
  int commercialId = 0;
  int routingId = 0;
  String pointMarchand = '';
  String veilleConcurrentielle = '';
  String commentaireRoutine = '';
  double latitudeReel = 0.0;
  double longitudeReel = 0.0;
  List<Tpe> tpeList = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _pointsMarchand = [];
  String? _selectedPointMarchand;
  List<String> _serialNumbers = [];
  List<Widget> _tpeForms = [];

  bool _visibleProblemeMobile = false;
  bool _visibleProblemeBancaire = false;

  final List<Map<String, dynamic>> _items = [
    {'value': 'N/A', 'label': 'N/A'},
    {'value': 'MOOV', 'label': 'Moov'},
    {'value': 'MTN', 'label': 'MTN'},
    {'value': 'ORANGE', 'label': 'Orange'},
    {'value': 'WAVE', 'label': 'Wave'},
  ];

  List<Routine> routines = [];

  final List<Map<String, dynamic>> _etatItems = [
    {'value': 'OK', 'label': 'OK'},
    {'value': 'NON OK', 'label': 'NON OK'},
  ];

  final List<Map<String, dynamic>> _problemeItems = [
    {'value': 'OUI', 'label': 'OUI'},
    {'value': 'NON', 'label': 'NON'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCommercialId();
    _controller = TextEditingController(text: '2');
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      await _getCurrentLocation();
      _loadPointsMarchand();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Location services are disabled. Please enable them.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitudeReel = position.latitude;
        longitudeReel = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _loadPointsMarchand() async {
    try {
      final response = await http.post(
        Uri.parse(baseLocalUrl + '/getpm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitudeTelephone': latitudeReel,
          'longitudeTelephone': longitudeReel
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _pointsMarchand = data.map((point) {
            return {
              'value': point['nom_pm'],
              'label': point['nom_pm'],
            };
          }).toList();
        });
      } else if (response.statusCode == 401) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('selectedRoutingId');
        print('Voici le routing Id');
        print(prefs.get("selectedRoutingId"));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous êtes surement loin du PM')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading points marchand: $e')),
      );
    }
  }

  Future<void> _loadCommercialId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      commercialId = prefs.getInt('agentId') ?? 0;
    });
  }

  Future<void> _pickImage(Tpe tpe) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        tpe.imageTpeRoutine = base64Image;
      });
    }
  }

  void _removeTpe(int index) {
    setState(() {
      // Supprimer le formulaire TPE à l'index spécifié
      _tpeForms.removeAt(index);

      // Supprimer le TPE correspondant de la liste tpeList
      tpeList.removeAt(index);

      // Réinitialiser les indices des TPE restants
      for (int i = 0; i < _tpeForms.length; i++) {
        // Mettre à jour les indices dans chaque formulaire
        // Ce code suppose que le formulaire est toujours en tête de la liste
        // et qu'il n'y a pas de glissement d'index autre que la suppression
        _tpeForms[i] = _buildTpeForm(tpeList[i], i);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Vérifier que chaque TPE a une image
      bool isImageMissing = false;
      for (var tpe in tpeList) {
        if (tpe.imageTpeRoutine == null || tpe.imageTpeRoutine!.isEmpty) {
          isImageMissing = true;
          break;
        }
      }

      if (isImageMissing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez fournir une photo pour chaque TPE')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      routingId = prefs.getInt('selectedRoutingId') ?? 0;
      final routineData = {
        'routing_id': routingId,
        'commercialId': commercialId,
        'pointMarchand': pointMarchand,
        'veilleConcurrentielle': veilleConcurrentielle,
        'commentaire_routine': commentaireRoutine,
        'latitudeReel': latitudeReel,
        'longitudeReel': longitudeReel,
        'tpeList': tpeList.map((tpe) => tpe.toJson()).toList(),
      };

      if (routingId == 0) {
        routineData['routing_id'] = "";
      }

      print(routineData);

      try {
        final response = await http.post(
          Uri.parse(baseLocalUrl + '/makeRoutine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(routineData),
        );
        setState(() {
          _isLoading = false;
        });
        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt("selectedRoutingId", 0);
          print(prefs.get("selectedRoutingId"));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Routine enregistrée avec succès')),
          );

          Navigator.pop(context, true);
        } else if (response.statusCode == 401) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('selectedRoutingId');
          print('Voici le routing Id');
          print(prefs.get("selectedRoutingId"));
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vous devez vous rapprocher du TPE')),
          );
        } else if (response.statusCode == 400) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('selectedRoutingId');
          print('Voici le routing Id');
          print(prefs.get("selectedRoutingId"));
          print((response.body));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('selectedRoutingId');
        print('Voici le routing Id');
        print(prefs.get("selectedRoutingId"));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchSerialNumbers(String selectedPointMarchand) async {
    try {
      final response = await http.post(
        Uri.parse(baseLocalUrl + '/getSnBypointMarchand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pointMarchand': selectedPointMarchand,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _serialNumbers = List<String>.from(data
              .map((serialNumber) => serialNumber['SERIAL_NUMBER'])
              .toList());
        });
        _generateTpeForms();
      } else if (response.statusCode == 401) {
        print('Failed to load serial numbers: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun TPE trouvé.')),
        );
      }
    } catch (e) {
      print('Error loading serial numbers: $e');
    }
  }

  void _generateTpeForms() {
    _tpeForms.clear();
    tpeList.clear();

    for (int i = 0; i < _serialNumbers.length; i++) {
      String serialNumber = _serialNumbers[i];
      Tpe tpe = Tpe(
        problemeBancaire: '',
        descriptionProblemeBancaire: '',
        problemeMobile: '',
        descriptionProblemeMobile: '',
        idTerminal: serialNumber,
        etatTpeRoutine: '',
        etatChargeurTpeRoutine: '',
        commenttaireTpeRoutine: '',
        imageTpeRoutine: '',
      );
      tpeList.add(tpe);
      _tpeForms.add(_buildTpeForm(tpe, i));
    }
  }

  Widget _buildTpeForm(Tpe tpe, int index) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Terminal SN: ${tpe.idTerminal}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TPE ${index + 1}'),
            IconButton(
              icon:
                  Icon(Icons.delete, color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () => _removeTpe(index),
            ),
          ],
        ),
        SelectFormField(
          type: SelectFormFieldType.dropdown,
          initialValue: tpe.etatTpeRoutine.isEmpty ? 'OK' : tpe.etatTpeRoutine,
          labelText: 'Etat du TPE',
          items: _etatItems,
          onChanged: (value) {
            setState(() {
              tpe.etatTpeRoutine = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            return null;
          },
        ),
        SelectFormField(
          type: SelectFormFieldType.dropdown,
          initialValue: tpe.etatChargeurTpeRoutine.isEmpty
              ? 'OK'
              : tpe.etatChargeurTpeRoutine,
          labelText: 'Etat du Chargeur',
          items: _etatItems,
          onChanged: (value) {
            setState(() {
              tpe.etatChargeurTpeRoutine = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            return null;
          },
        ),
        SelectFormField(
          type: SelectFormFieldType.dropdown,
          initialValue:
              tpe.problemeBancaire.isEmpty ? 'NON' : tpe.problemeBancaire,
          labelText: 'Problème Bancaire',
          items: _problemeItems,
          onChanged: (value) {
            setState(() {
              tpe.problemeBancaire = value;
              _visibleProblemeBancaire = true;
              // Réinitialiser la description si 'NON'
              if (value == 'NON') {
                tpe.descriptionProblemeBancaire = '';
              }
            });
          },
        ),
        Visibility(
          visible: _visibleProblemeBancaire,
          child: TextFormField(
            initialValue: tpe.descriptionProblemeBancaire ?? '',
            decoration:
                InputDecoration(labelText: 'Description du Problème Bancaire'),
            onChanged: (value) {
              setState(() {
                tpe.descriptionProblemeBancaire = value;
              });
            },
          ),
        ),
        SelectFormField(
          type: SelectFormFieldType.dropdown,
          initialValue: tpe.problemeMobile.isEmpty ? 'NON' : tpe.problemeMobile,
          labelText: 'Problème Mobile',
          items: _problemeItems,
          onChanged: (value) {
            setState(() {
              tpe.problemeMobile = value;
              _visibleProblemeMobile = true;
              // Réinitialiser la description si 'NON'
              if (value == 'NON') {
                tpe.descriptionProblemeMobile = '';
              }
            });
          },
        ),
        Visibility(
          visible: _visibleProblemeMobile,
          child: TextFormField(
            initialValue: tpe.descriptionProblemeMobile ?? '',
            decoration:
                InputDecoration(labelText: 'Description du Problème Mobile'),
            onChanged: (value) {
              setState(() {
                tpe.descriptionProblemeMobile = value;
              });
            },
          ),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Commentaire TPE'),
          initialValue: tpe.commenttaireTpeRoutine,
          onChanged: (value) {
            setState(() {
              tpe.commenttaireTpeRoutine = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            return null;
          },
        ),
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: () => _pickImage(tpe),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire de routine'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SelectFormField(
                        type: SelectFormFieldType.dropdown,
                        initialValue: _selectedPointMarchand,
                        labelText: 'Point Marchand',
                        items: _pointsMarchand,
                        onChanged: (value) {
                          setState(() {
                            _selectedPointMarchand = value;
                            pointMarchand = value!;
                            _fetchSerialNumbers(value);
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      SelectFormField(
                        type: SelectFormFieldType.dropdown,
                        initialValue: 'N/A',
                        labelText: 'Veille Concurrentielle',
                        items: _items,
                        onChanged: (value) {
                          setState(() {
                            veilleConcurrentielle = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Commentaire Routine'),
                        onChanged: (value) {
                          setState(() {
                            commentaireRoutine = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ..._tpeForms,
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Soumettre'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
