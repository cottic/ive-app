import 'dart:convert';

import 'package:fluffychat/stats_dashboard/models/situacion_model.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
    _initialValues = {
      'id': situacion.id,
      'efector': situacion.efector,
      'persona-consulta-fecha': situacion.personaConsultaFecha,
      'persona-dni': situacion.personaDni.toString(),
      'persona-nombre': situacion.personaNombre,
      'persona-apellido': situacion.personaApellido,
      'persona-nacimiento-fecha': situacion.personaNacimientoFecha,
      'persona-identidad-de-genero': situacion.personaIdentidadDeGenero,
      'persona-con-discapacidad': situacion.personaConDiscapacidad,
      'persona-obra-social': situacion.personaObraSocial,
      'partos': situacion.partos,
      'cesareas': situacion.cesareas,
      'abortos': situacion.abortos,
      'consulta-situacion': situacion.consultaSituacion,
      'semanas-gestacion': situacion.semanasGestacion,
      'consulta-causal': situacion.consultaCausal,
      'consulta-origen': situacion.consultaOrigen,
      'consulta-derivacion': situacion.consultaDerivacion,
      'derivacion-efector': situacion.derivacionEfector.toString(),
      'derivacion-motivo': situacion.derivacionMotivo,
      'tratamiento-fecha': situacion.tratamientoFecha,
      'tratamiento-tipo': situacion.tratamientoTipo,
      'tratamiento-comprimidos': situacion.tratamientoComprimidos,
      'tratamiento-quirurgico': situacion.tratamientoQuirurgico,
      'semanas-resolucion': situacion.semanasResolucion,
      'complicaciones': situacion.complicaciones,
      'aipe': situacion.aipe,
      'observaciones': situacion.observaciones,
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

    var situacionesInfoJson = await DashboardService().getSituaciones(userId);

    var situaciones = situacionFromJson(situacionesInfoJson);

    var parsedJson = json.decode(situacionesInfoJson);

    setListadoParaExportar(parsedJson);

    setListadoSituaciones(situaciones);
  }

  void enviarSituacion(formdata) async {
    setIsLoading(true);

    print('formdata');
    print(formdata);

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
}

/*  var situacionParaActualizar = Situacion(
      efector: formdata['efector'],
      personaConsultaFecha: DateTime.parse(formdata['persona-consulta-fecha']),
      personaDni: int.parse(formdata['persona-dni']),
      personaNombre: formdata['persona-nombre'],
      personaApellido: formdata['persona-apellido'],
      personaNacimientoFecha:
          DateTime.parse(formdata['persona-nacimiento-fecha']),
      personaIdentidadDeGenero: formdata['persona-identidad-de-genero'],
      personaConDiscapacidad: formdata['persona-con-discapacidad'],
      personaObraSocial: formdata['persona-obra-social'],
      partos: formdata['partos'],
      cesareas: formdata['cesareas'],
      abortos: formdata['abortos'],
      consultaSituacion: formdata['consulta-situacion'],
      semanasGestacion: formdata['semanas-gestacion'],
      consultaCausal: formdata['consulta-causal'],
      consultaOrigen: formdata['consulta-origen'],
      consultaDerivacion: formdata['consulta-derivacion'],
      derivacionEfector: int.parse(formdata['derivacion-efector']),
      derivacionMotivo: formdata['derivacion-motivo'],
      tratamientoFecha: DateTime.parse(formdata['tratamiento-fecha']),
      tratamientoTipo: formdata['tratamiento-tipo'],
      tratamientoComprimidos: formdata['tratamiento-comprimidos'],
      tratamientoQuirurgico: formdata['tratamiento-quirurgico'],
      semanasResolucion: formdata['semanas-resolucion'],
      complicaciones: formdata['complicaciones'],
      aipe: formdata['aipe'],
      observaciones: formdata['observaciones'],
      user: formdata['user'],
      id: formdata['id'],
    ); */

/*  print('Listado contiene elemento');
    print(_listadoSituaciones
        .firstWhere((element) => element.id == situacionParaActualizar.id) != null);

    _listadoSituaciones[_listadoSituaciones.indexWhere(
            (element) => element.id == situacionParaActualizar.id)] =
        situacionParaActualizar; */

/* Map<String, Object> getInitialValues() {
    if (_initialValues.isEmpty) {
      _initialValues = {
        'id': 1,
        'efector': 1,
        'persona-consulta-fecha': DateTime.now(),
        'persona-dni': '',
        'persona-nombre': '',
        'persona-apellido': '',
        'persona-nacimiento-fecha': DateTime(2001),
        'persona-identidad-de-genero': '',
        'persona-con-discapacidad': '',
        'persona-obra-social': '',
        'partos': 0,
        'cesareas': 0,
        'abortos': 0,
        'consulta-situacion': '',
        'semanas-gestacion': 14.6,
        'consulta-causal': '',
        'consulta-origen': '',
        'consulta-derivacion': '',
        'derivacion-efector': '',
        'derivacion-motivo': '',
        'tratamiento-fecha': DateTime.now(),
        'tratamiento-tipo': '',
        'tratamiento-comprimidos': 0,
        'tratamiento-quirurgico': '',
        'semanas-resolucion': 14.6,
        'complicaciones': '',
        'aipe': '',
        'observaciones': '',
        'user': '',
      };
    }
    return _initialValues;
  } */
