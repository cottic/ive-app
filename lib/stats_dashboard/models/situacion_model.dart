import 'dart:convert';

Situacion situacionFromJson(String str) => Situacion.fromJson(json.decode(str));

String situacionToJson(Situacion data) => json.encode(data.toJson());

class Situacion {
  Situacion({
    this.id,
    this.efector,
    this.persona_consulta_fecha,
    this.persona_dni,
    this.persona_nombre,
    this.persona_apellido,
    this.persona_nacimiento_fecha,
    this.persona_identidad_de_genero,
    this.persona_con_discapacidad,
    this.persona_obra_social,
    this.partos,
    this.cesareas,
    this.abortos,
    this.consulta_situacion,
    this.semanas_gestacion,
    this.consulta_causal,
    this.consulta_origen,
    this.consulta_derivacion,
    this.derivacion_efector,
    this.derivacion_motivo,
    this.tratamiento_fecha,
    this.tratamiento_tipo,
    this.tratamiento_comprimidos,
    this.tratamiento_quirurgico,
    this.semanas_resolucion,
    this.complicaciones,
    this.aipe,
    this.observaciones,
    this.user,
  });

  int id;
  int efector;
  DateTime persona_consulta_fecha;
  int persona_dni;
  String persona_nombre;
  String persona_apellido;
  DateTime persona_nacimiento_fecha;
  String persona_identidad_de_genero;
  String persona_con_discapacidad;
  String persona_obra_social;
  int partos;
  int cesareas;
  int abortos;
  String consulta_situacion;
  double semanas_gestacion;
  String consulta_causal;
  String consulta_origen;
  String consulta_derivacion;
  int derivacion_efector;
  String derivacion_motivo;
  DateTime tratamiento_fecha;
  String tratamiento_tipo;
  int tratamiento_comprimidos;
  String tratamiento_quirurgico;
  double semanas_resolucion;
  String complicaciones;
  String aipe;
  String observaciones;
  String user;

  factory Situacion.fromJson(Map<String, dynamic> json) => Situacion(
        id: json['id'],
        efector: json['efector'],
        persona_consulta_fecha: DateTime.parse(json['persona-consulta-fecha']),
        persona_dni: json['persona-dni'],
        persona_nombre: json['persona-nombre'],
        persona_apellido: json['persona-apellido'],
        persona_nacimiento_fecha:
            DateTime.parse(json['persona-nacimiento-fecha']),
        persona_identidad_de_genero: json['persona-identidad-de-genero'],
        persona_con_discapacidad: json['persona-con-discapacidad'],
        persona_obra_social: json['persona-obra-social'],
        partos: json['partos'],
        cesareas: json['cesareas'],
        abortos: json['abortos'],
        consulta_situacion: json['consulta-situacion'],
        semanas_gestacion: json['semanas-gestacion'],
        consulta_causal: json['consulta-causal'],
        consulta_origen: json['consulta-origen'],
        consulta_derivacion: json['consulta-derivacion'],
        derivacion_efector: json['derivacion-efector'],
        derivacion_motivo: json['derivacion-motivo'],
        tratamiento_fecha: DateTime.parse(json['tratamiento-fecha']),
        tratamiento_tipo: json['tratamiento-tipo'],
        tratamiento_comprimidos: json['tratamiento-comprimidos'],
        tratamiento_quirurgico: json['tratamiento-quirurgico'],
        semanas_resolucion: json['semanas-resolucion'],
        complicaciones: json['complicaciones'],
        aipe: json['aipe'],
        observaciones: json['observaciones'],
        user: json['user'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'efector': efector,
        'persona-consulta-fecha': persona_consulta_fecha,
        'persona-dni': persona_dni,
        'persona-nombre': persona_nombre,
        'persona-apellido': persona_apellido,
        'persona-nacimiento-fecha': persona_nacimiento_fecha,
        'persona-identidad-de-genero': persona_identidad_de_genero,
        'persona-con-discapacidad': persona_con_discapacidad,
        'persona-obra-social': persona_obra_social,
        'partos': partos,
        'cesareas': cesareas,
        'abortos': abortos,
        'consulta-situacion': consulta_situacion,
        'semanas-gestacion': semanas_gestacion,
        'consulta-causal': consulta_causal,
        'consulta-origen': consulta_origen,
        'consulta-derivacion': consulta_derivacion,
        'derivacion-efector': derivacion_efector,
        'derivacion-motivo': derivacion_motivo,
        'tratamiento-fecha': tratamiento_fecha,
        'tratamiento-tipo': tratamiento_tipo,
        'tratamiento-comprimidos': tratamiento_comprimidos,
        'tratamiento-quirurgico': tratamiento_quirurgico,
        'semanas-resolucion': semanas_resolucion,
        'complicaciones': complicaciones,
        'aipe': aipe,
        'observaciones': observaciones,
        'user': user,
      };
}
