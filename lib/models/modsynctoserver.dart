// To parse this JSON data, do
//
//     final planters = plantersFromJson(jsonString);

import 'dart:convert';

Planterjson plantersFromJson(String str) =>
    Planterjson.fromJson(json.decode(str));
String plantersToJson(Planterjson data) => json.encode(data.toJson());

class Planterjson {
  Planterjson({required this.data});
  final List<Dtplanters> data;
  factory Planterjson.fromJson(Map<String, dynamic> json) => Planterjson(
    data: List<Dtplanters>.from(
      json["planters"].map((x) => Dtplanters.fromJson(x)),
    ),
  );
  Map<String, dynamic> toJson() => {
    "planters": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtplanters {
  Dtplanters({
    required this.plid,
    required this.plcode,
    required this.plname,
    required this.traflag,
  });
  final String plid;
  final String plcode;
  final String plname;
  final String traflag;
  factory Dtplanters.fromJson(Map<String, dynamic> json) => Dtplanters(
    plid: json["plid"],
    plcode: json["plcode"],
    plname: json["plname"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "plid": plid,
    "plcode": plcode,
    "plname": plname,
    "traflag": traflag,
  };
}

///////-----------------------
PlanterSourcejson PlanterSourceFromJson(String str) =>
    PlanterSourcejson.fromJson(json.decode(str));
String PlanterSourceToJson(PlanterSourcejson data) =>
    json.encode(data.toJson());

class PlanterSourcejson {
  PlanterSourcejson({required this.data});
  final List<Dtplsrc> data;
  factory PlanterSourcejson.fromJson(Map<String, dynamic> json) =>
      PlanterSourcejson(
        data: List<Dtplsrc>.from(
          json["plantersource"].map((x) => Dtplsrc.fromJson(x)),
        ),
      );
  Map<String, dynamic> toJson() => {
    "plantersource": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtplsrc {
  Dtplsrc({
    required this.plsource_id,
    required this.plsource_code,
    required this.plsource_name,
    required this.traflag,
  });

  final String plsource_id;
  final String plsource_code;
  final String plsource_name;
  final String traflag;

  factory Dtplsrc.fromJson(Map<String, dynamic> json) => Dtplsrc(
    plsource_id: json["plid"],
    plsource_code: json["plcode"],
    plsource_name: json["plname"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "plsrc_id": plsource_id,
    "plsrc_code": plsource_code,
    "plsrc_name": plsource_name,
    "traflag": traflag,
  };
}

Coordinatorjson CoordinatorFromJson(String str) =>
    Coordinatorjson.fromJson(json.decode(str));
String CoordinatortoJson(Coordinatorjson data) => json.encode(data.toJson());

class Coordinatorjson {
  Coordinatorjson({required this.data});
  final List<Dtcoordinator> data;
  factory Coordinatorjson.fromJson(Map<String, dynamic> json) =>
      Coordinatorjson(
        data: List<Dtcoordinator>.from(
          json["coordinator"].map((x) => Dtcoordinator.fromJson(x)),
        ),
      );
  Map<String, dynamic> toJson() => {
    "coordinator": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtcoordinator {
  Dtcoordinator({
    required this.fr_id,
    required this.fr_code,
    required this.fr_name,
    required this.traflag,
  });

  final String fr_id;
  final String fr_code;
  final String fr_name;
  final String traflag;

  factory Dtcoordinator.fromJson(Map<String, dynamic> json) => Dtcoordinator(
    fr_id: json["frid"],
    fr_code: json["frcode"],
    fr_name: json["frname"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "fr_id": fr_id,
    "fr_code": fr_code,
    "fr_name": fr_name,
    "traflag": traflag,
  };
}

////--------------------------
Requestjson RequestFromJson(String str) =>
    Requestjson.fromJson(json.decode(str));
String RequestTojson(Requestjson data) => json.encode(data.toJson());

class Requestjson {
  Requestjson({required this.data});
  final List<DtRequestjson> data;
  factory Requestjson.fromJson(Map<String, dynamic> json) => Requestjson(
    data: List<DtRequestjson>.from(
      json["sprequest"].map((x) => DtRequestjson.fromJson(x)),
    ),
  );
  Map<String, dynamic> toJson() => {
    "sprequest": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DtRequestjson {
  DtRequestjson({
    required this.request_id,
    required this.request_no,
    required this.request_date,
    required this.pl_code,
    required this.pl_name,
    required this.location,
    required this.area,
    required this.qty,
    required this.remaining_qty,
    required this.delivered_qty,
    required this.plid,
    required this.forcpr,
    required this.traflag,
  });
  final String request_id;
  final String request_no;
  final String request_date;
  final String pl_code;
  final String pl_name;
  final String location;
  final String area;
  final String qty;
  final String delivered_qty;
  final String remaining_qty;
  final String plid;
  final String forcpr;
  final String traflag;
  factory DtRequestjson.fromJson(Map<String, dynamic> json) => DtRequestjson(
    request_id: json["request_id"],
    request_no: json["request_no"],
    request_date: json["request_date"],
    pl_code: json["pl_code"],
    pl_name: json["pl_name"],
    location: json["location"],
    area: json["area"],
    qty: json["qty"],
    remaining_qty: json["remaining_qty"],
    delivered_qty: json["delivered_qty"],
    plid: json["plid"],
    forcpr: json["forcpr"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "request_id": request_id,
    "request_no": request_no,
    "request_date": request_date,
    "planter_code": pl_code,
    "planter_name": pl_name,
    "lot_location": location,
    "area": area,
    "qty": qty,
    "delivered_qty": delivered_qty,
    "remaining_qty": remaining_qty,
    "planter_id": plid,
    "for_cpr": forcpr,
    "traflag": traflag,
  };
}

////--------------------------

Cutterjson CutterFromJson(String str) => Cutterjson.fromJson(json.decode(str));
String CutterToJson(Cutterjson data) => json.encode(data.toJson());

class Cutterjson {
  Cutterjson({required this.data});
  final List<Dtcutter> data;
  factory Cutterjson.fromJson(Map<String, dynamic> json) => Cutterjson(
    data: List<Dtcutter>.from(json["cutters"].map((x) => Dtcutter.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "cutters": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtcutter {
  Dtcutter({
    required this.id,
    required this.description,
    required this.traflag,
  });

  final String id;
  final String description;
  final String traflag;

  factory Dtcutter.fromJson(Map<String, dynamic> json) => Dtcutter(
    id: json["id"],
    description: json["description"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "traflag": traflag,
  };
}

////--------------------------

LotPictureJson LotPictureFromJson(String str) =>
    LotPictureJson.fromJson(json.decode(str));
String LotPictureToJson(LotPictureJson data) => json.encode(data.toJson());

class LotPictureJson {
  LotPictureJson({required this.data});
  final List<DtLp> data;
  factory LotPictureJson.fromJson(Map<String, dynamic> json) => LotPictureJson(
    data: List<DtLp>.from(
      (json["splotpictures"] ?? []).map((x) => DtLp.fromJson(x)),
    ),
  );
  Map<String, dynamic> toJson() => {
    "splotpictures": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DtLp {
  DtLp({
    required this.collpid,
    required this.collpreqid,
    required this.collandprep,
    required this.collandprepdate,
    required this.collandactual,
    required this.collandactualdate,
    required this.collptraflag,
    required this.colaptraflag,
    // required this.collandtraflag,
  });

  final String collpid;
  final String collpreqid;
  final String collandprep;
  final String collandprepdate;
  final String collandactual;
  final String collandactualdate;
  final String collptraflag;
  final String colaptraflag;
  // final String collandtraflag;

  factory DtLp.fromJson(Map<String, dynamic> json) => DtLp(
    collpid: json["id"],
    collpreqid: json["request_id"],
    collandprep: json["picture1"],
    collandprepdate: json["datepict1"],
    collandactual: json["picture2"],
    collandactualdate: json["datepict2"],
    collptraflag: json["traflag1"],
    colaptraflag: json["traflag2"],
    // collandtraflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "splot_id": collpid,
    "request_id": collpreqid,
    "land_prep": collptraflag,
    "landprep_date": collandprepdate,
    "actual_planted": collandactual,
    "actualplanted_date": collandactualdate,
    "lp_traflag": collptraflag,
    "ap_traflag": colaptraflag,
  };
}

///--------------------------------------

Varietyjson VarietyFromJson(String str) =>
    Varietyjson.fromJson(json.decode(str));
String VarietyToJson(Varietyjson data) => json.encode(data.toJson());

class Varietyjson {
  Varietyjson({required this.data});
  final List<Dtvariety> data;
  factory Varietyjson.fromJson(Map<String, dynamic> json) => Varietyjson(
    data: List<Dtvariety>.from(
      json["variety"].map((x) => Dtvariety.fromJson(x)),
    ),
  );
  Map<String, dynamic> toJson() => {
    "variety": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtvariety {
  Dtvariety({
    required this.id,
    required this.description,
    required this.traflag,
  });

  final String id;
  final String description;
  final String traflag;

  factory Dtvariety.fromJson(Map<String, dynamic> json) => Dtvariety(
    id: json["id"],
    description: json["description"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "traflag": traflag,
  };
}

///--------------------------------------

CMjson CMFromJson(String str) => CMjson.fromJson(json.decode(str));
String CMToJson(CMjson data) => json.encode(data.toJson());

class CMjson {
  CMjson({required this.data});
  final List<DtCM> data;
  factory CMjson.fromJson(Map<String, dynamic> json) => CMjson(
    data: List<DtCM>.from(json["cuttingmode"].map((x) => DtCM.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "cuttingmode": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DtCM {
  DtCM({required this.id, required this.description, required this.traflag});

  final String id;
  final String description;
  final String traflag;

  factory DtCM.fromJson(Map<String, dynamic> json) => DtCM(
    id: json["id"],
    description: json["description"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "traflag": traflag,
  };
}

///--------------------------------------

SrcLocationjson SrcLocationFromJson(String str) =>
    SrcLocationjson.fromJson(json.decode(str));
String SrcLocationToJson(SrcLocationjson data) => json.encode(data.toJson());

class SrcLocationjson {
  SrcLocationjson({required this.data});
  final List<Dtsrclocation> data;
  factory SrcLocationjson.fromJson(Map<String, dynamic> json) =>
      SrcLocationjson(
        data: List<Dtsrclocation>.from(
          json["locationsource"].map((x) => Dtsrclocation.fromJson(x)),
        ),
      );
  Map<String, dynamic> toJson() => {
    "locationsource": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtsrclocation {
  Dtsrclocation({
    required this.id,
    required this.code,
    required this.location,
    required this.traflag,
  });

  final String id;
  final String code;
  final String location;
  final String traflag;

  factory Dtsrclocation.fromJson(Map<String, dynamic> json) => Dtsrclocation(
    id: json["loid"],
    code: json["locode"],
    location: json["location"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "location": location,
    "traflag": traflag,
  };
}

///------------------------------------
Cprjson CprFromJson(String str) => Cprjson.fromJson(json.decode(str));
String CprToJson(Cprjson data) => json.encode(data.toJson());

class Cprjson {
  Cprjson({required this.data});
  final List<Dtcprjson> data;
  factory Cprjson.fromJson(Map<String, dynamic> json) => Cprjson(
    data: json["cpr"] != null
        ? List<Dtcprjson>.from(json["cpr"].map((x) => Dtcprjson.fromJson(x)))
        : [], // ✅ Return empty list if null
  );
  Map<String, dynamic> toJson() => {
    "cpr": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtcprjson {
  Dtcprjson({
    required this.id,
    required this.cpr_id,
    required this.cpr_refno,
    required this.request_id,
    required this.location_id,
    required this.variety_id,
    required this.planter_id,
    required this.cutter_id,
    required this.qty,
    required this.delivery_date,
    required this.print_count,
    required this.delivered_by_id,
    required this.recieved_by,
    required this.series,
    required this.source_planter,
    required this.traflag,
    required this.rcvfr_id,
    required this.hauling_paid,
    required this.hauling_amount,
    required this.cuttingmode,
    required this.cuttingdate,
    required this.cutting_paid,
    required this.cutting_amount,
    required this.sacks_paid,
    required this.sacks_amount,
    required this.others_paid,
    required this.others_amount,
    required this.lot_code,
  });
  final String id;
  final String cpr_id;
  final String cpr_refno;
  final String request_id;
  final String location_id;
  final String variety_id;
  final String planter_id;
  final String cutter_id;
  final String qty;
  final String delivery_date;
  final String print_count;
  final String delivered_by_id;
  final String recieved_by;
  final String series;
  final String source_planter;
  final String traflag;
  final String rcvfr_id;
  final String hauling_paid;
  final String hauling_amount;
  final String cuttingmode;
  final String cuttingdate;
  final String cutting_paid;
  final String cutting_amount;
  final String sacks_paid;
  final String sacks_amount;
  final String others_paid;
  final String others_amount;
  final String lot_code;

  factory Dtcprjson.fromJson(Map<String, dynamic> json) => Dtcprjson(
    id: json["id"] ?? '0',
    cpr_id: json["cprid"] ?? '0',
    cpr_refno: json["cprrefno"] ?? '',
    request_id: json["cprrequest_id"] ?? '0',
    location_id: json["cprlosource"] ?? '0',
    source_planter: json["cprplsource"] ?? '0',
    variety_id: json["cprvariety_id"] ?? '0',
    cutter_id: json["cprcutter_id"] ?? '0',
    qty: json["cprqty"] ?? '0',
    delivery_date: json["cprtrndate"] ?? '',
    recieved_by: json["cprreceivedby"] ?? '',
    series: json["cprseries"] ?? '0',
    traflag: 'S', // ← Default to 'S' (synced)
    planter_id: json["cprpl_id"] ?? '0',
    print_count: json["cprprintcount"] ?? '0',
    delivered_by_id: json["cprusername_id"] ?? '0',
    rcvfr_id: json["cprrequested_fr_id"] ?? '0',
    hauling_paid: json["hauling_paid"] ?? '0',
    hauling_amount: json["hauling_amount"] ?? '0',
    cuttingmode: json["cuttingmode"] ?? '0',
    cuttingdate: json["cuttingdate"] ?? '0',
    cutting_paid: json["cutting_paid"] ?? '0',
    cutting_amount: json["cutting_amount"] ?? '0',
    sacks_paid: json["sacks_paid"] ?? '0',
    sacks_amount: json["sacks_amount"] ?? '0',
    others_paid: json["others_paid"] ?? '0',
    others_amount: json["others_amount"] ?? '0',
    lot_code: json["source_lot_code"] ?? '',
  );
  Map<String, dynamic> toJson() => {
    "cpr_id": cpr_id,
    "cpr_refno": cpr_refno,
    "request_id": request_id,
    "location_id": location_id,
    "variety_id": variety_id,
    "planter_id": planter_id,
    "cutter_id": cutter_id,
    "qty": qty,
    "delivery_date": delivery_date,
    "print_count": print_count,
    "delivered_by_id": delivered_by_id,
    "recieved_by": recieved_by,
    "series": series,
    "traflag": traflag,
    "rcvfr_id": rcvfr_id,
    "hauling_paid": hauling_paid,
    "hauling_amount": hauling_amount,
    "cuttingmode": cuttingmode,
    "cuttingdate": cuttingdate,
    "cutting_paid": cutting_paid,
    "cutting_amount": cutting_amount,
    "sacks_paid": sacks_paid,
    "sacks_amount": sacks_amount,
    "others_paid": others_paid,
    "others_amount": others_amount,
    "lot_code": lot_code,
  };
}

///--------------------------------------

NotificationJson NotificationFromJson(String str) =>
    NotificationJson.fromJson(json.decode(str));
String NotificationToJson(NotificationJson data) => json.encode(data.toJson());

class NotificationJson {
  NotificationJson({required this.data});
  final List<Dtnotif> data;
  factory NotificationJson.fromJson(Map<String, dynamic> json) =>
      NotificationJson(
        data: List<Dtnotif>.from(json["notif"].map((x) => Dtnotif.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
    "notif": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtnotif {
  Dtnotif({required this.datetime, required this.title, required this.body});

  final String datetime;
  final String title;
  final String body;

  factory Dtnotif.fromJson(Map<String, dynamic> json) => Dtnotif(
    datetime: json["trn_date"],
    title: json["title"],
    body: json["body"],
  );
  Map<String, dynamic> toJson() => {
    "date_time": datetime,
    "title": title,
    "body": body,
  };
}

///--------------------------------------

LotCodejson LotCodeFromJson(String str) =>
    LotCodejson.fromJson(json.decode(str));
String LotCodeToJson(LotCodejson data) => json.encode(data.toJson());

class LotCodejson {
  LotCodejson({required this.data});
  final List<Dtlotcode> data;
  factory LotCodejson.fromJson(Map<String, dynamic> json) => LotCodejson(
    data: List<Dtlotcode>.from(
      json["lotcodes"].map((x) => Dtlotcode.fromJson(x)),
    ),
  );
  Map<String, dynamic> toJson() => {
    "lotcodes": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtlotcode {
  Dtlotcode({
    required this.lotcodeid,
    required this.lotcodename,
    required this.plantersrcId,
    required this.traflag,
  });

  final String lotcodeid;
  final String lotcodename;
  final String plantersrcId;
  final String traflag;
  factory Dtlotcode.fromJson(Map<String, dynamic> json) => Dtlotcode(
    lotcodeid: json["id"],
    lotcodename: json["description"],
    plantersrcId: json["pl_id"],
    traflag: json["traflag"],
  );
  Map<String, dynamic> toJson() => {
    "lotcode_id": lotcodeid,
    "lotcode_name": lotcodename,
    "plsrc_id": plantersrcId,
    "traflag": traflag,
  };
}

///--------------------------------------

PermissionsJson PermissionsFromJson(String str) =>
    PermissionsJson.fromJson(json.decode(str));
String PermissionsToJson(PermissionsJson data) => json.encode(data.toJson());

class PermissionsJson {
  PermissionsJson({required this.data});
  final List<Dtpermission> data;
  factory PermissionsJson.fromJson(Map<String, dynamic> json) =>
      PermissionsJson(
        data: List<Dtpermission>.from(
          json["permission"].map((x) => Dtpermission.fromJson(x)),
        ),
      );
  Map<String, dynamic> toJson() => {
    "permission": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Dtpermission {
  Dtpermission({required this.moduleid, required this.hasaccess});

  final String moduleid;
  final String hasaccess;

  factory Dtpermission.fromJson(Map<String, dynamic> json) =>
      Dtpermission(moduleid: json["module_id"], hasaccess: json["hasaccess"]);
  Map<String, dynamic> toJson() => {
    "module_id": moduleid,
    "has_access": hasaccess,
  };
}
