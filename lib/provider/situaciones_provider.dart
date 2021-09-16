import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:fluffychat/data/mapa_efectores.dart';

import 'package:csv/csv.dart';

import 'package:fluffychat/stats_dashboard/models/situacion_model.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';

class SituacionesProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String _userId;
  String get userId => _userId;

  bool _isLoading;
  bool get isLoading => _isLoading;

  Situacion _situacionActiva;
  Situacion get situacionActiva => _situacionActiva;

  List<Situacion> _listadoSituaciones = [];
  List<Situacion> get listadoSituaciones => _listadoSituaciones;

  Map<String, Object> _initialValues;
  Map<String, Object> get initialValues => _initialValues;

  dynamic _listadoParaExportar;
  dynamic get listadoParaExportar => _listadoParaExportar;

  List<String> _listadoNombresEfectores;
  List<String> get listadoNombresEfectores => _listadoNombresEfectores;

  final Map<int, String> _mapaDerivacionEfectores = mapaEfectoresOriginal;
  Map<int, String> get mapaDerivacionEfectores => _mapaDerivacionEfectores;

  void setUserId(String userId) {
    _userId = userId;
  }

  void setListadoParaExportar(dynamic parsedJson) {
    _listadoParaExportar = parsedJson;
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSituacionActivaInterna(Situacion situacion) {
    _situacionActiva = situacion;
    notifyListeners();
  }

  void setListadoSituaciones(List<Situacion> listaSituaciones) {
    _listadoSituaciones = listaSituaciones;
    notifyListeners();
  }

  void setInitialValue(Situacion situacion) {
    String getDerivacionEfectoValue(int derivacionEfectorId) {
      String derivacionEfecto;

      if (derivacionEfectorId != null) {
        if (mapaDerivacionEfectores.containsKey(derivacionEfectorId)) {
          derivacionEfecto = mapaDerivacionEfectores[derivacionEfectorId];
        }
      } else {
        derivacionEfecto = 'No identificado';
      }

      return derivacionEfecto;
    }

    _initialValues = {
      'id': situacion.id ?? 0,
      'efector': situacion.efector ?? 1,
      'persona-consulta-fecha':
          situacion.personaConsultaFecha ?? DateTime.now(),
      'persona-dni': situacion.personaDni.toString() ?? 0,
      'persona-nombre': situacion.personaNombre ?? '',
      'persona-apellido': situacion.personaApellido ?? '',
      'persona-nacimiento-fecha':
          situacion.personaNacimientoFecha ?? DateTime(2001),
      'persona-identidad-de-genero': situacion.personaIdentidadDeGenero ?? '',
      'persona-con-discapacidad': situacion.personaConDiscapacidad ?? '',
      'persona-obra-social': situacion.personaObraSocial ?? '',
      'partos': situacion.partos ?? 0,
      'cesareas': situacion.cesareas ?? 0,
      'abortos': situacion.abortos ?? 0,
      'consulta-situacion': situacion.consultaSituacion ?? '',
      'semanas-gestacion': situacion.semanasGestacion ?? 14.6,
      'consulta-causal': situacion.consultaCausal ?? '',
      'consulta-origen': situacion.consultaOrigen ?? '',
      'consulta-derivacion': situacion.consultaDerivacion ?? '',
      'derivacion-efector':
          getDerivacionEfectoValue(int.parse(situacion.derivacionEfector)) ??
              '',
      'derivacion-motivo': situacion.derivacionMotivo ?? '',
      'tratamiento-fecha': situacion.tratamientoFecha ?? DateTime.now(),
      'tratamiento-tipo': situacion.tratamientoTipo ?? '',
      'tratamiento-comprimidos': situacion.tratamientoComprimidos ?? 0,
      'tratamiento-quirurgico': situacion.tratamientoQuirurgico ?? '',
      'semanas-resolucion': situacion.semanasResolucion ?? 14.6,
      'complicaciones': situacion.complicaciones ?? '',
      'aipe': situacion.aipe ?? '',
      'observaciones': situacion.observaciones ?? '',
      'user': situacion.user,
    };
    notifyListeners();
  }

  void setSituacionActiva(Situacion situacion) {
    setIsLoading(true);

    setSituacionActivaInterna(situacion);
    setInitialValue(situacion);

    setIsLoading(false);
  }

  void getSituaciones() async {
    await decodeCsvEfectores();
    var situacionesInfoJson = await DashboardService().getSituaciones(userId);

    if (situacionesInfoJson != null) {
      var situaciones = situacionFromJson(situacionesInfoJson);

      var parsedJson = json.decode(situacionesInfoJson);

      setListadoParaExportar(parsedJson);

      setListadoSituaciones(situaciones);
    } else {
      setListadoParaExportar(null);

      setListadoSituaciones(null);
    }
  }

  void enviarSituacion(formdata) async {
    setIsLoading(true);
    // print('ENVIA SITUACION');
    // print(formdata);

    //TODO: Falta validar en la UI cuando el formulario falla, deberia mostrar mensaje de que el envio fallo.
    var respuestaSendSituacion =
        await DashboardService().sendSituacion(formdata);

    var situacionesInfoJson = await DashboardService().getSituaciones(userId);

    var situaciones = situacionFromJson(situacionesInfoJson);

    var parsedJson = json.decode(situacionesInfoJson);

    setListadoParaExportar(parsedJson);

    setListadoSituaciones(situaciones);

    _situacionActiva = null;
    setIsLoading(false);
  }

  void decodeCsvEfectores() async {
    /* var myData = await rootBundle.loadString('/csv/EfectoresILE.csv');
    final csvTable = CsvToListConverter(eol: '\r\n').convert(myData);

    print('csvTable');
    print(csvTable);


    final data = [];
    csvTable.forEach((value) {
      data.add(value.toString());
    });

    Map<int, String> mapaEfDecodeado = {};

    data.forEach((value) {
      final key = int.parse(value.substring(1, 15));
      final valueFinal = value.toString().substring(18, value.length - 4);

      mapaEfDecodeado[key] = valueFinal;
    });

    _mapaDerivacionEfectores = mapaEfDecodeado;
    notifyListeners(); */

    final List<String> listadoEfectoresValues = [];

    mapaDerivacionEfectores.values
        .forEach((value) => listadoEfectoresValues.add(value));
    _listadoNombresEfectores = listadoEfectoresValues;
    // notifyListeners();

    // print(mapaEfDecodeado);
  }

  String transfromStringToIntInEfectores(String value) {
    // print('Entro transfromStringToIntInEfectores');
    // print(value);

    if (mapaDerivacionEfectores.containsValue(value)) {
      mapaDerivacionEfectores.containsKey(value);
      MapEntry entry = mapaDerivacionEfectores.entries
          .firstWhere((element) => element.value == value);
      return entry.key.toString();
    }

    return '0';
  }
}
