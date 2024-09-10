class Routine {
  int id;
  int? commercialRoutineId;
  String pointMarchandRoutine;
  String latitudeMarchandRoutine;
  String longitudeMarchandRoutine;
  String veilleConcurentielleRoutine;
  DateTime? dateRoutine;
  String? commentaireRoutine;
  int? routingId;
  List<Tpe> tpeRoutine;

  Routine({
    this.id = 0,
    this.commercialRoutineId,
    required this.pointMarchandRoutine,
    required this.latitudeMarchandRoutine,
    required this.longitudeMarchandRoutine,
    required this.veilleConcurentielleRoutine,
    this.dateRoutine,
    required this.commentaireRoutine,
    required this.routingId,
    required this.tpeRoutine,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] ?? 0,
      commercialRoutineId: json['commercial_routine_id'],
      pointMarchandRoutine: json['point_marchand_routine'] ?? '',
      latitudeMarchandRoutine: json['latitude_marchand_routine'] ?? '',
      longitudeMarchandRoutine: json['longitude_marchand_routine'] ?? '',
      veilleConcurentielleRoutine: json['veille_concurentielle_routine'] ?? '',
      commentaireRoutine: json['commentaire_routine'] ?? '',
      routingId: json['routing_id'] ?? '',
      dateRoutine: json['date_routine'] != null
          ? DateTime.parse(json['date_routine'])
          : null,
      tpeRoutine: (json['tpe_routine'] as List)
          .map((data) => Tpe.fromJson(data))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commercial_routine_id': commercialRoutineId,
      'point_marchand_routine': pointMarchandRoutine,
      'latitude_marchand_routine': latitudeMarchandRoutine,
      'longitude_marchand_routine': longitudeMarchandRoutine,
      'veille_concurentielle_routine': veilleConcurentielleRoutine,
      'commentaire_routine': commentaireRoutine,
      'routing_id': routingId,
      'date_routine': dateRoutine?.toIso8601String(),
      'tpe_routine': tpeRoutine.map((tpe) => tpe.toJson()).toList(),
    };
  }
}

class Tpe {
  int id;
  int? routineId;
  String idTerminal;
  String etatTpeRoutine;
  String etatChargeurTpeRoutine;
  String problemeBancaire;
  String? descriptionProblemeBancaire;
  String problemeMobile;
  String? descriptionProblemeMobile;
  String? commenttaireTpeRoutine;
  String? imageTpeRoutine;
  bool visibleProblemeMobile;
  bool visibleProblemeBancaire;

  Tpe(
      {this.id = 0,
      this.routineId,
      required this.idTerminal,
      required this.etatTpeRoutine,
      required this.etatChargeurTpeRoutine,
      required this.problemeBancaire,
      this.descriptionProblemeBancaire,
      required this.problemeMobile,
      this.descriptionProblemeMobile,
      required this.commenttaireTpeRoutine,
      this.visibleProblemeMobile = false,
      this.visibleProblemeBancaire = false,
      required this.imageTpeRoutine});

  factory Tpe.fromJson(Map<String, dynamic> json) {
    return Tpe(
        id: json['id'] ?? 0,
        routineId: json['routine_id'],
        idTerminal: json['idTerminal'] ?? '',
        etatTpeRoutine: json['etatTpe'] ?? '',
        etatChargeurTpeRoutine: json['etatChargeur'] ?? '',
        problemeBancaire: json['problemeBancaire'] ?? '',
        descriptionProblemeBancaire: json['descriptionProblemeBancaire'],
        problemeMobile: json['problemeMobile'] ?? '',
        descriptionProblemeMobile: json['descriptionProblemeMobile'],
        commenttaireTpeRoutine: json['commenttaire_tpe_routine'],
        imageTpeRoutine: json['image_tpe_routine']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine_id': routineId,
      'idTerminal': idTerminal,
      'etatTpe': etatTpeRoutine,
      'etatChargeur': etatChargeurTpeRoutine,
      'problemeBancaire': problemeBancaire,
      'descriptionProblemeBancaire': descriptionProblemeBancaire,
      'problemeMobile': problemeMobile,
      'descriptionProblemeMobile': descriptionProblemeMobile,
      'commenttaire_tpe_routine': commenttaireTpeRoutine,
      'image_tpe_routine': imageTpeRoutine
    };
  }
}
