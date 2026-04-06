class ApiConstants {
  ApiConstants._();

  /// Set once when user picks a connection: 1 = Internet, 2 = Local WiFi
  static int conntype = 1;

  /// Base URLs
  static const String localBase =
      // "http://172.16.0.252/caterp/jsonapi/sugar_production";
      "http://172.16.0.252/caterp/jsonapi/sugar_production";
  // "http://172.16.1.198/wsserver";

  static const String productionBase =
      "https://cattarlac.com/caterp/jsonapi/sugar_production";
  // "http://172.16.0.252/caterp/jsonapi/sugar_production";

  /// Active base URL — reads the globally set conntype
  static String get baseUrl => conntype == 1 ? localBase : productionBase;

  /// Endpoints
  static const String users = "datausersget.php";
  static const String savesyncfirst = "datasynctoserverfirst.php";
  static const String syncUpdate = "datasynctoserverupdate.php";
  static const String gallery = "announcement.php";
  static const String notifications = "datanotif.php";
}
