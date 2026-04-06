import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Users table columns
String userTable = 'useraccount';
String usernameid = 'usernameid';
String username = 'username';
String password = 'password';
String fullname = 'fullname';
// Planter table columns
String planterTable = 'planter_table';
String colPlid = 'pl_id';
String colPlcode = 'pl_code';
String colPlname = 'pl_name';
String colPltraflag = 'traflag';

//lot_pictures
String lotPicturesTable = 'lotpictures_table';
String collpid = 'id';
String collpreqid = 'request_id';
String collandprep = 'land_prep';
String collptraflag = 'lp_traflag';
String collandprepdate = 'landprep_date';
String collandactual = 'actual_planted';
String colaptraflag = 'ap_traflag';
String collandactualdate = 'actualplanted_date';
String collandptraflag = 'traflag';
// Coordinator table columns
String frTable = 'coordinator_table';
String colfrid = 'fr_id';
String colfrcode = 'fr_code';
String colfrname = 'fr_name';
String colfrtraflag = 'traflag';

// Planter Sources
String srcplanterTable = 'plsource_table';
String colPlsrcid = 'plsrc_id';
String colPlsrccode = 'plsrc_code';
String colPlsrcname = 'plsrc_name';
String colPlsrctraflag = 'traflag';

String requestTable = 'request_table';
String colReqid = 'request_id';
String colReqno = 'request_no';
String colReqdtr = 'request_date';
String colReqplname = 'planter_name';
String colReqplcode = 'planter_code';
String colReqplid = 'planter_id';
String colReqlotlocation = 'lot_location';
String colReqlothectare = 'area';
String colReqttlqty = 'qty';
String colReqdlqty = 'delivered_qty';
String colReqrmqty = 'remaining_qty';
String colReqtraflag = 'traflag';

String locationtable = 'srclocation_table';
String collocid = 'id';
String colloccode = 'code';
String colloclocation = 'location';
String colloctraflag = 'traflag';

String varietytable = 'variety_table';
String colvarid = 'id';
String colvardesc = 'description';
String colvartraflag = 'traflag';

String cuttertable = 'cutter_table';
String colctrid = 'id';
String colctrdesc = 'description';
String colctrtraflag = 'traflag';

String cuttingmodetable = 'cutting_table';
String colcmid = 'id';
String colcmdesc = 'description';
String colcmtraflag = 'traflag';

String cprtable = 'cpr_table';
String colcprid = 'cpr_id';
String colccprrefno = 'cpr_refno';
String colcprrequestid = 'request_id';
String colcprlocid = 'location_id';
String colcprvariety = 'variety_id';
String colcprplanterid = 'planter_id';
String colcprcutter = 'cutter_id';
String colcprfrid = 'rcvfr_id';
String colcprqty = 'qty';
String colcprdatedelivered = 'delivery_date';
String colcprcounter = 'print_count';
String colcprdeliveredby = 'delivered_by_id';
String colcprrecievedby = 'recieved_by';
String colcprseries = 'series';
String colcprspl = 'source_planter';
String colcprhlngstat = 'hauling_paid';
String colcprhlngqty = 'hauling_amount';
String colcprcm = 'cuttingmode';
String colcprcmdate = 'cuttingdate';
String colcprtraflag = 'traflag';

String notiftable = 'notif_table';
String colnotifid = 'id';
String colnotiftitle = 'title';
String colnotifbody = 'body';
String colnotifdatetime = 'date_time';
String colnotiftraflag = 'traflag';

String userpermissionstable = 'user_permissions';
String colpermissionid = 'id';
String colmoduleid = 'module_id';
String colhasaccess = 'has_access';

String gallerytable = 'gallery';
String colimageid = 'id';
String colimageblob = 'image';
String colcreatedat = 'created_at';
String colgallerytraflag = 'traflag';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $userTable (
            $usernameid INTEGER PRIMARY KEY,
            $username TEXT NOT NULL UNIQUE,
            $password TEXT NOT NULL,
            $fullname TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $userpermissionstable (
                $colpermissionid INTEGER PRIMARY KEY,
                $colmoduleid INTEGER NOT NULL,
                $colhasaccess INTEGER NOT NULL DEFAULT 0
            );
        ''');

        await db.execute('''
          CREATE TABLE $lotPicturesTable (
            $collpid INTEGER PRIMARY KEY,
            $collandprep TEXT,
            $collandprepdate TEXT,
            $collandactual TEXT,
            $collandactualdate TEXT,
            $collpreqid TEXT NOT NULL,
            $collptraflag TEXT,
            $colaptraflag TEXT,
            $collandptraflag TEXT,

           FOREIGN KEY ($collpreqid) REFERENCES $requestTable ($colReqid)
          )
        ''');

        await db.execute('''
          CREATE TABLE $planterTable (
            $colPlid INTEGER PRIMARY KEY,
            $colPlcode TEXT NOT NULL UNIQUE,
            $colPlname TEXT NOT NULL,
            $colPltraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $gallerytable (
            $colimageid INTEGER PRIMARY KEY AUTOINCREMENT,
            $colimageblob TEXT NOT NULL,
            $colcreatedat TEXT NOT NULL,
             $colgallerytraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $frTable (
            $colfrid INTEGER PRIMARY KEY,
            $colfrcode TEXT NOT NULL UNIQUE,
            $colfrname TEXT NOT NULL,
            $colfrtraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $srcplanterTable (
            $colPlsrcid INTEGER PRIMARY KEY,
            $colPlsrccode TEXT NOT NULL UNIQUE,
            $colPlsrcname TEXT NOT NULL,
            $colPlsrctraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $requestTable (
            $colReqid INTEGER PRIMARY KEY,
            $colReqplname TEXT NOT NULL,
            $colReqplcode TEXT NOT NULL,
            $colReqno TEXT NOT NULL,
            $colReqttlqty INTEGER NOT NULL,
            $colReqplid INTEGER NOT NULL,
            $colReqlothectare TEXT NOT NULL,
            $colReqlotlocation TEXT NOT NULL,
            $colReqdlqty INTEGER DEFAULT 0,
            $colReqrmqty INTEGER NOT NULL,
            $colReqdtr TEXT NOT NULL,
            $colReqtraflag TEXT NOT NULL,
          
            FOREIGN KEY ($colReqplcode) REFERENCES $planterTable ($colPlcode)
          )
        ''');

        await db.execute('''
          CREATE TABLE $locationtable (
            $collocid INTEGER PRIMARY KEY,
            $colloccode TEXT NOT NULL UNIQUE,
            $colloclocation TEXT NOT NULL,
            $colloctraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $varietytable (
            $colvarid INTEGER PRIMARY KEY,
            $colvardesc TEXT NOT NULL,
            $colvartraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $notiftable (
            $colnotifid INTEGER PRIMARY KEY AUTOINCREMENT,
            $colnotiftitle TEXT NOT NULL,
            $colnotifbody TEXT NOT NULL,
            $colnotifdatetime TEXT NOT NULL,
            $colnotiftraflag INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE $cuttingmodetable (
             $colcmid INTEGER PRIMARY KEY,
            $colcmdesc TEXT NOT NULL,
            $colcmtraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $cuttertable (
            $colctrid INTEGER PRIMARY KEY,
            $colctrdesc TEXT NOT NULL,
            $colctrtraflag TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $cprtable (
            $colcprid INTEGER PRIMARY KEY,
            $colccprrefno TEXT NOT NULL UNIQUE,
            $colcprplanterid INTEGER,
            $colcprrequestid INTEGER NOT NULL,
            $colcprqty INTEGER,
            $colcprlocid INTEGER,
            $colcprfrid INTEGER,
            $colcprvariety INTEGER,
            $colcprdatedelivered TEXT,
            $colcprcutter INTEGER,
            $colcprcounter INTEGER DEFAULT 0,
            $colcprdeliveredby INTEGER,
            $colcprseries INTEGER,
            $colcprrecievedby TEXT,
            $colcprspl INTEGER,
            $colcprhlngstat INTEGER,
            $colcprhlngqty INTEGER,
            $colcprtraflag TEXT NOT NULL,
             $colcprcm INTEGER,
            $colcprcmdate TEXT NOT NULL,
            FOREIGN KEY ($colcprplanterid) REFERENCES $planterTable ($colPlid),
            FOREIGN KEY ($colcprrequestid) REFERENCES $requestTable ($colReqid),
            FOREIGN KEY ($colcprcutter) REFERENCES $cuttertable ($colctrid),
            FOREIGN KEY ($colcprlocid) REFERENCES $locationtable ($collocid),
            FOREIGN KEY ($colcprvariety) REFERENCES $varietytable ($colvarid),
            FOREIGN KEY ($colcprdeliveredby) REFERENCES $userTable ($usernameid)
          )
        ''');
      },
    );
  }

  static Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
    return await dbClient.insert(
      userTable,
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertGallery(Map<String, dynamic> gallery) async {
    final dbClient = await db;
    return await dbClient.insert(
      gallerytable,
      gallery,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteGallery(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      gallerytable,
      where: '$colimageid = ?',
      whereArgs: [id],
    );
  }

  // static Future<void> clearAnnouncements() async {
  //   final dbClient = await db;
  //   await dbClient.delete(announcementstable);
  // }

  static Future<int> insertUserpermission(
    Map<String, dynamic> userpermissions,
  ) async {
    final dbClient = await db;
    return await dbClient.insert(
      userpermissionstable,
      userpermissions,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertNotif(Map<String, dynamic> notif) async {
    final dbClient = await db;
    return await dbClient.insert(
      notiftable,
      notif,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertLotPicture(Map<String, dynamic> lp) async {
    final dbClient = await db;
    return await dbClient.insert(
      lotPicturesTable,
      lp,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertPlanter(Map<String, dynamic> planter) async {
    final dbClient = await db;
    return await dbClient.insert(
      planterTable,
      planter,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertSourcePlanter(Map<String, dynamic> planter) async {
    final dbClient = await db;
    return await dbClient.insert(
      srcplanterTable,
      planter,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertCoords(Map<String, dynamic> fr) async {
    final dbClient = await db;
    return await dbClient.insert(
      frTable,
      fr,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertLocation(Map<String, dynamic> location) async {
    final dbClient = await db;
    return await dbClient.insert(
      locationtable,
      location,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertReq(Map<String, dynamic> req) async {
    final dbClient = await db;
    return await dbClient.insert(
      requestTable,
      req,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertCutter(Map<String, dynamic> cut) async {
    final dbClient = await db;
    return await dbClient.insert(
      cuttertable,
      cut,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertVariety(Map<String, dynamic> vrt) async {
    final dbClient = await db;
    return await dbClient.insert(
      varietytable,
      vrt,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertCPR(Map<String, dynamic> cpr) async {
    final dbClient = await db;
    return await dbClient.insert(
      cprtable,
      cpr,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertCM(Map<String, dynamic> cut) async {
    final dbClient = await db;
    return await dbClient.insert(
      cuttingmodetable,
      cut,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateSourcePlanter(
    Map<String, dynamic> data,
    int id,
  ) async {
    final db = await DBHelper.db;
    return await db.update(
      srcplanterTable,
      data,
      where: '$colPlsrcid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateGallery(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      gallerytable,
      data,
      where: '$colimageid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateLotPicture(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      lotPicturesTable,
      data,
      where: '$collpid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateReq(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      requestTable,
      data,
      where: '$colReqid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateCoords(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      frTable,
      data,
      where: '$colfrid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateCutter(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      cuttertable,
      data,
      where: '$colctrid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateVariety(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      varietytable,
      data,
      where: '$colvarid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateLocation(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      locationtable,
      data,
      where: '$collocid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateCPR(Map<String, dynamic> data, int id) async {
    final db = await DBHelper.db;
    return await db.update(
      cprtable,
      data,
      where: '$colcprid = ?',
      whereArgs: [id],
    );
  }

  //---delete
  static Future<int> deleteReq(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      requestTable,
      where: '$colReqid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deletLotPictures(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      requestTable,
      where: '$collpid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteSourcePlanter(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      srcplanterTable,
      where: '$colPlsrcid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCoords(int id) async {
    final db = await DBHelper.db;
    return await db.delete(frTable, where: '$colfrid = ?', whereArgs: [id]);
  }

  static Future<int> deleteCutter(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      cuttertable,
      where: '$colctrid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteVariety(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      varietytable,
      where: '$colvarid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteLocation(int id) async {
    final db = await DBHelper.db;
    return await db.delete(
      locationtable,
      where: '$collocid = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCPR(int id) async {
    final db = await DBHelper.db;
    return await db.delete(cprtable, where: '$colcprid = ?', whereArgs: [id]);
  }

  static Future<List<int>> getAccessibleModuleIds() async {
    final dbClient = await db;
    final result = await dbClient.query(
      userpermissionstable,
      columns: [colmoduleid],
      where: '$colhasaccess = 1',
    );
    return result.map((r) => r[colmoduleid] as int).toList();
  }

  static Future<Map<String, dynamic>?> getUserByUsername(String user) async {
    final dbClient = await db;
    final result = await dbClient.query(
      userTable,
      where: '$username = ?',
      whereArgs: [user],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> clearAllData() async {
    final dbClient = await db;
    await dbClient.delete(cprtable);
    await dbClient.delete(requestTable);
    await dbClient.delete(planterTable);
    await dbClient.delete(locationtable);
    await dbClient.delete(varietytable);
    await dbClient.delete(cuttertable);
    await dbClient.delete(cuttingmodetable);
  }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await databaseFactory.deleteDatabase(path);
    _db = null;
  }
}
