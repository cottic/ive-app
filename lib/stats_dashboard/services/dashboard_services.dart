import 'dart:convert';

import 'package:http/http.dart' as http;

class DashboardService {
  String chartFromApi;

  static final String _baseUrl =
      'https://proyecto.codigoi.com.ar/ile/ile-api-tableros';

  Future<String> loadChartFromApi(String chartNumber) async {
    final url = '$_baseUrl/dashboard0/?chart=${chartNumber}';

    var response = await http.get(url);

    var _source = Utf8Decoder().convert(response.bodyBytes);

    if (response.statusCode == 200) {
      chartFromApi = _source;
      return chartFromApi;
    }
    return null;
  }

  Future<String> sendSituacion(String formdata) async {
    final url = '$_baseUrl/users/';

    print('situacion a eniar');

    var response = await http.post(
      url,
      /* headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },*/
      body: formdata,
    );

    if (response.statusCode == 200) {
      var _source = Utf8Decoder().convert(response.bodyBytes);
      // print('ENVIO SITUACION, respuesta:');
      // print(_source);

      // chartFromApi = _source;
      return chartFromApi;
    }
    return null;
  }

  Future<String> getSituaciones(String user) async {
    final url = '$_baseUrl/users/?user=' + user;

    var response = await http.get(
      url,
      /* headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },*/
    );

    if (response.statusCode == 200) {
      return Utf8Decoder().convert(response.bodyBytes);
    }
    return null;
  }
}
