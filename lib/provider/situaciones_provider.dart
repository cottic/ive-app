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
      'derivacion-efector': situacion.derivacionEfector ?? 0,
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

// Al modificar los valores, recordar que hay que actualizar el valor por default en situaciones_list_refactor.dart
const Map<int, String> mapaDerivacionEfectores = {
  0: '',
  111:
      'UNIDAD SANITARIA GLEW II	DE NAVAZIO Y DI CARLO S/N BO. ALMAFUERTE - GLEW	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  112:
      'UNIDAD SANITARIA N° 10 28 DE DICIEMBRE DE RAFAEL CALZADA	GORRION ENTRE JORGE Y ARROYO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  113:
      'UNIDAD SANITARIA N° 11 LA GLORIA DE SAN JOSE	LA CALANDRIA ENTRE BYNON Y MITRE S/N LA TABLADA SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  114:
      'UNIDAD SANITARIA N° 12 DON ORIONE DE CLAYPOLE	CALLE 11 Y AV. EVA PERON - BARRIO DON ORIONE	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  115:
      'UNIDAD SANITARIA N° 13 DE BURZACO	ALSINA Y MARTIN FIERRO	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  116:
      'UNIDAD SANITARIA N° 16 DE RAFAEL CALZADA	AV. SAN MARTIN 4900 Y SAN CARLOS BARRIO SAN GERONIMO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  117:
      'UNIDAD SANITARIA N° 4 SAN JOSE DE ALMIRANTE BROWN	SAN LUIS 166 SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  118:
      'UNIDAD SANITARIA N° 7 13 DE JULIO DE CLAYPOLE	ANEMONAS 6545 ENTRE CLAVEL Y CAMELIA	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  119:
      'UNIDAD SANITARIA Nº 23 RAMON CARRILLO	ZUFRIATEGUI 3550	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  120:
      'CENTRO DE ATENCION PRIMARIA DE LA SALUD SAKURA	MOLINA MASSEY 3212 E/ LORETO Y MONTE SANTIAGO	BUENOS AIRES	ALMIRANTE BROWN	LONGCHAMPS',
  121:
      'UNIDAD SANITARIA E. MAGUILLANSKY N° 1	CALLE 38 1169 BARRIO SAN FRANCISCO	BUENOS AIRES	AZUL	AZUL',
  122:
      'UNIDAD SANITARIA N° 44 DR RAMON CARRILLO	CALLE 122 BIS	BUENOS AIRES	BERISSO	BERISSO',
  123:
      'CENTRO PERIFERICO N° 4 DE CAMPANA	ZARATE ENTRE S.DELLEPIANE Y UGARTEMENDIA - SAN CAYETANO	BUENOS AIRES	CAMPANA	CAMPANA',
  124:
      'UNIDAD SANITARIA SAGRADO CORAZON DE JESUS MAXIMO PAZ	PERU Y BENAVIDEZ S/Nº Bº SAN CARLOS	BUENOS AIRES	CAÑUELAS	MAXIMO PAZ',
  125:
      'CENTRO DE ATENCION PRIMARIA DR. PASCUAL GUIDICE	ESTADOS UNIDOS Y SAN MARTIN	BUENOS AIRES	ENSENADA	ENSENADA',
  126:
      'UNIDAD SANITARIA 1° DE MAYO DE ENSENADA	ECUADOR Y SAENZ PEÑA BARRIO 1° DE MAYO 17	BUENOS AIRES	ENSENADA	ENSENADA',
  127:
      'UNIDAD SANITARIA N° 5	BELGRANO Y CANALE	BUENOS AIRES	EZEIZA	TRISTAN SUAREZ',
  128:
      'UNIDAD SANITARIA BARRIO 2 DE ABRIL DE MAR DEL PLATA	SOLDADO PACHEOLZUK 850 - BARRIO 2 DE ABRIL	BUENOS AIRES	GENERAL PUEYRREDON	PUNTA MOGOTES',
  129:
      'SUBCENTRO DE SALUD JORGE NEWBERY	MORENO 9375 - BARRIO JORGE NEWBERY	BUENOS AIRES	GENERAL PUEYRREDON	MAR DEL PLATA',
  130:
      'UNIDAD SANITARIA MARENGO	CALLE 51 (REPUBLICA) 10 ESQUINA CALLE 110 (PUEYRREDON)	BUENOS AIRES	GENERAL SAN MARTIN	VILLA BALLESTER',
  131:
      'UNIDAD SANITARIA BARRIO ANGEL	POTOSI Y LEVALLE - BARRIO SAN DAMIAN	BUENOS AIRES	HURLINGHAM	HURLINGHAM',
  132:
      'HOSPITAL DE ATENCION MEDICA PRIMARIA DE ITUZAINGO	BRANDSEN 3859	BUENOS AIRES	ITUZAINGO	ITUZAINGO SUR',
  133:
      'CENTRO DE SALUD SAKAMOTO	NICOLAS DAVILA 2110	BUENOS AIRES	LA MATANZA	RAFAEL CASTILLO',
  134:
      'CENTRO DE SALUD LA LOMA	LOS HELECHOS ESQUINA LOS TULIPANES S/N BARRIO LA LOMA	BUENOS AIRES	LUJAN	LUJAN',
  135:
      'UNIDAD SANITARIA BARRIO LOS LAURELES	LAS ESTRELLAS Y VENUS S/N BARRIO LOS LAURELES	BUENOS AIRES	LUJAN	LUJAN',
  136:
      'UNIDAD SANITARIA N° 11 DE MERLO	AV. SAN MARTIN Y BARILOCHE	BUENOS AIRES	MERLO	MERLO',
  137:
      'UNIDAD SANITARIA N° 4 LA FORTUNA DE MORENO	ENRIQUE LARRETA 10471	BUENOS AIRES	MORENO	TRUJUI',
  138:
      'UNIDAD SANITARIA SAMBRIZZI SANGUINETTI	CORRIENTES 2301 - BARRIO SANGUINETTI	BUENOS AIRES	MORENO	PASO DEL REY',
  139:
      'CENTRO DE SALUD MERCEDES SOSA	EVA PERON ESQUINA BARADERO	BUENOS AIRES	MORON	MORON',
  140:
      'CENTRO DE SALUD SANTA LAURA	GRAL. CORNELIO SAAVEDRA 1265 - BARRIO SANTA LAURA	BUENOS AIRES	MORON	MORON',
  141:
      'UNIDAD SANITARIA PRESIDENTE IBAÑEZ	PRESIDENTE IBAÑEZ 1824 - BARRIO SAN JOSE	BUENOS AIRES	MORON	MORON',
  142:
      'CENTRO DE ATENCION PRIMARIA RAMON CARRILLO DE PERGAMINO	DEAN FUNES Y COSTA RICA BARRIO GUEMES	BUENOS AIRES	PERGAMINO	PERGAMINO',
  143:
      'UNIDAD SANITARIA VILLA ROSA	SERRANO Y PERON	BUENOS AIRES	PILAR	VILLA ROSA'
};
