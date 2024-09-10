import 'dart:convert';

class Routing {
  final int id;
  final int agentRoutingId;
  final int bdmRoutingId;
  final String descriptionRouting;
  final DateTime dateDebutRouting;
  final DateTime dateFinRouting;
  final List<PointMarchand> pmRouting;

  Routing({
    required this.id,
    required this.agentRoutingId,
    required this.bdmRoutingId,
    required this.descriptionRouting,
    required this.dateDebutRouting,
    required this.dateFinRouting,
    required this.pmRouting,
  });

  factory Routing.fromJson(Map<String, dynamic> json) {
    var list = json['pm_routing'] as String;
    List<dynamic> parsedList = jsonDecode(list);
    List<PointMarchand> pmRouting =
        parsedList.map((i) => PointMarchand.fromJson(i)).toList();

    return Routing(
      id: json['id'],
      agentRoutingId: json['agent_routing_id'],
      bdmRoutingId: json['bdm_routing_id'],
      descriptionRouting: json['description_routing'],
      dateDebutRouting: DateTime.parse(json['date_debut_routing']),
      dateFinRouting: DateTime.parse(json['date_fin_routing']),
      pmRouting: pmRouting,
    );
  }
}

class PointMarchand {
  final String nomPm;

  PointMarchand({required this.nomPm});

  factory PointMarchand.fromJson(Map<String, dynamic> json) {
    return PointMarchand(
      nomPm: json['nom_Pm'],
    );
  }
}
