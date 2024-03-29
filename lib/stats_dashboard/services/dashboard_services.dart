import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../components/matrix.dart';

class DashboardService {
  String chartFromApi;

  static final String _baseUrl =
      'https://proyecto.codigoi.com.ar/siilve/ile-api-tableros';

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
    final url = '$_baseUrl/situaciones/';

    // print('situacion a eniar');

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

      chartFromApi = _source;
      return chartFromApi;
    }
    return null;
  }

  Future<String> getSituaciones(String user) async {
    final url = '$_baseUrl/situaciones/?user=' + user;

    // print(url);

    var response = await http.get(
      url,
      /* headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },*/
    );

    if (response.statusCode == 200) {
      if (response.body.toString() == '{}') {
        return null;
      } else {
        return Utf8Decoder().convert(response.bodyBytes);
      }
    }
    return null;
  }
}
