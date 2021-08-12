// To parse this JSON data, do
//
//     final situacion = situacionFromJson(jsonString);

import 'dart:convert';

List<Situacion> situacionFromJson(String str) =>
    List<Situacion>.from(json.decode(str).map((x) => Situacion.fromJson(x)));

String situacionToJson(List<Situacion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Situacion {
  Situacion({
    this.id,
    this.efector,
    this.personaConsultaFecha,
    this.personaDni,
    this.personaNombre,
    this.personaApellido,
    this.personaNacimientoFecha,
    this.personaIdentidadDeGenero,
    this.personaConDiscapacidad,
    this.personaObraSocial,
    this.partos,
    this.cesareas,
    this.abortos,
    this.consultaSituacion,
    this.semanasGestacion,
    this.consultaCausal,
    this.consultaOrigen,
    this.consultaDerivacion,
    this.derivacionEfector,
    this.derivacionMotivo,
    this.tratamientoFecha,
    this.tratamientoTipo,
    this.tratamientoComprimidos,
    this.tratamientoQuirurgico,
    this.semanasResolucion,
    this.complicaciones,
    this.aipe,
    this.observaciones,
    this.user,
  });

  int id;
  int efector;
  DateTime personaConsultaFecha;
  int personaDni;
  String personaNombre;
  String personaApellido;
  DateTime personaNacimientoFecha;
  String personaIdentidadDeGenero;
  String personaConDiscapacidad;
  String personaObraSocial;
  int partos;
  int cesareas;
  int abortos;
  String consultaSituacion;
  double semanasGestacion;
  String consultaCausal;
  String consultaOrigen;
  String consultaDerivacion;
  int derivacionEfector;
  String derivacionMotivo;
  DateTime tratamientoFecha;
  String tratamientoTipo;
  int tratamientoComprimidos;
  String tratamientoQuirurgico;
  double semanasResolucion;
  String complicaciones;
  String aipe;
  String observaciones;
  String user;

  factory Situacion.fromJson(Map<String, dynamic> json) => Situacion(
        id: json["id"],
        efector: json["efector"],
        personaConsultaFecha: DateTime.parse(json["persona-consulta-fecha"]),
        personaDni: json["persona-dni"],
        personaNombre: json["persona-nombre"],
        personaApellido: json["persona-apellido"],
        personaNacimientoFecha:
            DateTime.parse(json["persona-nacimiento-fecha"]),
        personaIdentidadDeGenero: json["persona-identidad-de-genero"],
        personaConDiscapacidad: json["persona-con-discapacidad"],
        personaObraSocial: json["persona-obra-social"],
        partos: json["partos"],
        cesareas: json["cesareas"],
        abortos: json["abortos"],
        consultaSituacion: json["consulta-situacion"],
        semanasGestacion: json["semanas-gestacion"].toDouble(),
        consultaCausal: json["consulta-causal"],
        consultaOrigen: json["consulta-origen"],
        consultaDerivacion: json["consulta-derivacion"],
        derivacionEfector: json["derivacion-efector"],
        derivacionMotivo: json["derivacion-motivo"],
        tratamientoFecha: DateTime.parse(json["tratamiento-fecha"]),
        tratamientoTipo: json["tratamiento-tipo"],
        tratamientoComprimidos: json["tratamiento-comprimidos"],
        tratamientoQuirurgico: json["tratamiento-quirurgico"],
        semanasResolucion: json["semanas-resolucion"].toDouble(),
        complicaciones: json["complicaciones"],
        aipe: json["aipe"],
        observaciones: json["observaciones"],
        user: json["user"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "efector": efector,
        "persona-consulta-fecha":
            "${personaConsultaFecha.year.toString().padLeft(4, '0')}-${personaConsultaFecha.month.toString().padLeft(2, '0')}-${personaConsultaFecha.day.toString().padLeft(2, '0')}",
        "persona-dni": personaDni,
        "persona-nombre": personaNombre,
        "persona-apellido": personaApellido,
        "persona-nacimiento-fecha":
            "${personaNacimientoFecha.year.toString().padLeft(4, '0')}-${personaNacimientoFecha.month.toString().padLeft(2, '0')}-${personaNacimientoFecha.day.toString().padLeft(2, '0')}",
        "persona-identidad-de-genero": personaIdentidadDeGenero,
        "persona-con-discapacidad": personaConDiscapacidad,
        "persona-obra-social": personaObraSocial,
        "partos": partos,
        "cesareas": cesareas,
        "abortos": abortos,
        "consulta-situacion": consultaSituacion,
        "semanas-gestacion": semanasGestacion,
        "consulta-causal": consultaCausal,
        "consulta-origen": consultaOrigen,
        "consulta-derivacion": consultaDerivacion,
        "derivacion-efector": derivacionEfector,
        "derivacion-motivo": derivacionMotivo,
        "tratamiento-fecha":
            "${tratamientoFecha.year.toString().padLeft(4, '0')}-${tratamientoFecha.month.toString().padLeft(2, '0')}-${tratamientoFecha.day.toString().padLeft(2, '0')}",
        "tratamiento-tipo": tratamientoTipo,
        "tratamiento-comprimidos": tratamientoComprimidos,
        "tratamiento-quirurgico": tratamientoQuirurgico,
        "semanas-resolucion": semanasResolucion,
        "complicaciones": complicaciones,
        "aipe": aipe,
        "observaciones": observaciones,
        "user": user,
      };
}
