import 'package:fluffychat/stats_dashboard/models/situacion_model.dart';
import 'package:fluffychat/views/situaciones_list.dart';
import 'package:flutter/material.dart';

import '../components/adaptive_page_layout.dart';
import '../components/dialogs/simple_dialogs.dart';
import '../components/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SituacionFormView extends StatelessWidget {
  const SituacionFormView({this.situacion, this.roomId});

  final Situacion situacion;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: situacion != null
          ? SituacionesList(activeChat: situacion.id)
          : SituacionesList(),
      secondScaffold: SituacionesForm(situacion),
    );
  }
}

class SituacionesForm extends StatefulWidget {
  const SituacionesForm(this.situacion);

  final Situacion situacion;
  @override
  _SituacionesFormState createState() => _SituacionesFormState();
}

class _SituacionesFormState extends State<SituacionesForm> {
  Future<dynamic> profileFuture;
  dynamic profile;
  Future<bool> crossSigningCachedFuture;
  bool crossSigningCached;
  Future<bool> megolmBackupCachedFuture;
  bool megolmBackupCached;
  String bullet = '\u2022';
  double semanasResolucionMin = 5.0;

  bool showTratamiento = true;
  bool isCausalEnabled = true;
  final _formKey = GlobalKey<FormBuilderState>();

  int calculateDifference(DateTime date, DateTime compare) {
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(compare.year, compare.month, compare.day))
        .inDays;
  }

  Future<void> requestSSSSCache(BuildContext context) async {
    final handle = Matrix.of(context).client.encryption.ssss.open();
    final str = await SimpleDialogs(context).enterText(
      titleText: L10n.of(context).askSSSSCache,
      hintText: L10n.of(context).passphraseOrKey,
      password: true,
    );

    if (str != null) {
      SimpleDialogs(context).showLoadingDialog(context);
      // make sure the loading spinner shows before we test the keys
      await Future.delayed(Duration(milliseconds: 100));
      var valid = false;
      try {
        handle.unlock(recoveryKey: str);
        valid = true;
      } catch (_) {
        try {
          handle.unlock(passphrase: str);
          valid = true;
        } catch (_) {
          valid = false;
        }
      }
      await Navigator.of(context)?.pop();
      if (valid) {
        await handle.maybeCacheAll();
        await SimpleDialogs(context).inform(
          contentText: L10n.of(context).cachedKeys,
        );
        setState(() {
          crossSigningCachedFuture = null;
          crossSigningCached = null;
          megolmBackupCachedFuture = null;
          megolmBackupCached = null;
        });
      } else {
        await SimpleDialogs(context).inform(
          contentText: L10n.of(context).incorrectPassphraseOrKey,
        );
      }
    }
  }

  Future<void> sendSituacion(formdata) async {
    var barChartInfoJson = await DashboardService().sendSituacion(formdata);

    return barChartInfoJson;
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final username = client.userID;
    final situacion = widget.situacion;
    var efectorName = '';
    var efector = 1;

    if (username == '@maria.jose.mattioli:matrix.codigoi.com.ar') {
      efectorName = 'Hospital de Clínicas “José de San Martín”';
      efector = 2;
    } else if (username == '@julieta.minasi:matrix.codigoi.com.ar' ||
        username == '@graciela.beatriz.rodriguez:matrix.codigoi.com.ar' ||
        username == '@maria.elida.del.pino:matrix.codigoi.com.ar' ||
        username == '@estefania.cioffi:matrix.codigoi.com.ar') {
      efectorName = 'Hospital Iriarte (Quilmes)”';
      efector = 3;
    } else {
      efectorName = 'Hospital General de Agudos “Dr. Teodoro Álvarez”';
      efector = 1;
    }
    profileFuture ??= client.ownProfile.then((p) {
      if (mounted) setState(() => profile = p);
      return p;
    });
    // var Json = json.decode(  '[{"id":5,"efector":1,"persona-consulta-fecha":"2021-07-28","persona-dni":2538578699,"persona-nombre":"GH","persona-apellido":"hl","persona-nacimiento-fecha":"2001-01-01","persona-identidad-de-genero":"varon-trans","persona-con-discapacidad":"no-consignado","persona-obra-social":"si","partos":2,"cesareas":1,"abortos":2,"consulta-situacion":"ile","semanas-gestacion":14.6,"consulta-causal":"vida","consulta-origen":"ong","consulta-derivacion":"si","derivacion-efector":0,"derivacion-motivo":"contraindicacion","tratamiento-fecha":"2021-07-28","tratamiento-tipo":"quirurgico","tratamiento-comprimidos":0,"tratamiento-quirurgico":"rue-o-legrado","semanas-resolucion":14.6,"complicaciones":"complicaciones-anestesia","aipe":"anticoncepcion-inyectable","observaciones":"Prueba","user":"@juanma:matrix.codigoi.com.ar"}]');
    // var situaciones = Json.map((i) => Situacion.fromJson(i)).toList();

    // TODO derivacion efector listado sin ID y recoleccion desde modelo

    /* var situacionData =  {
      'id': situacion.id,
      'efector': situacion.efector,
      'persona-consulta-fecha': situacion.persona_consulta_fecha,
      'persona-dni': situacion.persona_dni.toString(),
      'persona-nombre': situacion.persona_nombre,
      'persona-apellido': situacion.persona_apellido,
      'persona-nacimiento-fecha': situacion.persona_nacimiento_fecha,
      'persona-identidad-de-genero': situacion.persona_identidad_de_genero,
      'persona-con-discapacidad': situacion.persona_con_discapacidad,
      'persona-obra-social': situacion.persona_obra_social,
      'partos': situacion.partos,
      'cesareas': situacion.cesareas,
      'abortos': situacion.abortos,
      'consulta-situacion': situacion.consulta_situacion,
      'semanas-gestacion': situacion.semanas_gestacion,
      'consulta-causal': situacion.consulta_causal,
      'consulta-origen': situacion.consulta_origen,
      'consulta-derivacion': situacion.consulta_derivacion,
      'derivacion-efector': situacion.derivacion_efector.toString(),
      'derivacion-motivo': situacion.derivacion_motivo,
      'tratamiento-fecha': situacion.tratamiento_fecha,
      'tratamiento-tipo': situacion.tratamiento_tipo,
      'tratamiento-comprimidos': situacion.tratamiento_comprimidos,
      'tratamiento-quirurgico': situacion.tratamiento_quirurgico,
      'semanas-resolucion': situacion.semanas_resolucion,
      'complicaciones': situacion.complicaciones,
      'aipe': situacion.aipe,
      'observaciones': situacion.observaciones,
      'user': username,
    }; */

    /* var initialFromSituacion = {
      'id': situaciones[0].id,
      'efector': situaciones[0].efector,
      'persona-consulta-fecha': situaciones[0].persona_consulta_fecha,
      'persona-dni': situaciones[0].persona_dni.toString(),
      'persona-nombre': situaciones[0].persona_nombre,
      'persona-apellido': situaciones[0].persona_apellido,
      'persona-nacimiento-fecha': situaciones[0].persona_nacimiento_fecha,
      'persona-identidad-de-genero': situaciones[0].persona_identidad_de_genero,
      'persona-con-discapacidad': situaciones[0].persona_con_discapacidad,
      'persona-obra-social': situaciones[0].persona_obra_social,
      'partos': situaciones[0].partos,
      'cesareas': situaciones[0].cesareas,
      'abortos': situaciones[0].abortos,
      'consulta-situacion': situaciones[0].consulta_situacion,
      'semanas-gestacion': situaciones[0].semanas_gestacion,
      'consulta-causal': situaciones[0].consulta_causal,
      'consulta-origen': situaciones[0].consulta_origen,
      'consulta-derivacion': situaciones[0].consulta_derivacion,
      'derivacion-efector': situaciones[0].derivacion_efector.toString(),
      'derivacion-motivo': situaciones[0].derivacion_motivo,
      'tratamiento-fecha': situaciones[0].tratamiento_fecha,
      'tratamiento-tipo': situaciones[0].tratamiento_tipo,
      'tratamiento-comprimidos': situaciones[0].tratamiento_comprimidos,
      'tratamiento-quirurgico': situaciones[0].tratamiento_quirurgico,
      'semanas-resolucion': situaciones[0].semanas_resolucion,
      'complicaciones': situaciones[0].complicaciones,
      'aipe': situaciones[0].aipe,
      'observaciones': situaciones[0].observaciones,
      'user': username,
    }; */

    /*  var initialValuesSituacionEjemplo = Situacion(
      id: 1,
      efector: 1,
      persona_dni: 0,
      persona_consulta_fecha: DateTime.now(),
      persona_nombre: '',
      persona_apellido: '',
      persona_nacimiento_fecha: DateTime(2001),
      persona_identidad_de_genero: '',
      persona_con_discapacidad: '',
      persona_obra_social: '',
      partos: 0,
      cesareas: 0,
      abortos: 0,
      consulta_situacion: '',
      semanas_gestacion: 14.6,
      consulta_causal: '',
      consulta_origen: '',
      consulta_derivacion: '',
      derivacion_efector: 0,
      derivacion_motivo: '',
      tratamiento_fecha: DateTime.now(),
      tratamiento_tipo: '',
      tratamiento_comprimidos: 0,
      tratamiento_quirurgico: '',
      semanas_resolucion: 14.6,
      complicaciones: '',
      aipe: '',
      observaciones: '',
      user: username,
    ); */

    var initialValues = {
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
      'user': username,
    };

    // Con esto verficia si es un formulario nuevo o si esta levantando uno
    if (widget.situacion != null) {
      initialValues = {
        'id': situacion.id,
        'efector': situacion.efector,
        'persona-consulta-fecha': situacion.persona_consulta_fecha,
        'persona-dni': situacion.persona_dni.toString(),
        'persona-nombre': situacion.persona_nombre,
        'persona-apellido': situacion.persona_apellido,
        'persona-nacimiento-fecha': situacion.persona_nacimiento_fecha,
        'persona-identidad-de-genero': situacion.persona_identidad_de_genero,
        'persona-con-discapacidad': situacion.persona_con_discapacidad,
        'persona-obra-social': situacion.persona_obra_social,
        'partos': situacion.partos,
        'cesareas': situacion.cesareas,
        'abortos': situacion.abortos,
        'consulta-situacion': situacion.consulta_situacion,
        'semanas-gestacion': situacion.semanas_gestacion,
        'consulta-causal': situacion.consulta_causal,
        'consulta-origen': situacion.consulta_origen,
        'consulta-derivacion': situacion.consulta_derivacion,
        'derivacion-efector': situacion.derivacion_efector.toString(),
        'derivacion-motivo': situacion.derivacion_motivo,
        'tratamiento-fecha': situacion.tratamiento_fecha,
        'tratamiento-tipo': situacion.tratamiento_tipo,
        'tratamiento-comprimidos': situacion.tratamiento_comprimidos,
        'tratamiento-quirurgico': situacion.tratamiento_quirurgico,
        'semanas-resolucion': situacion.semanas_resolucion,
        'complicaciones': situacion.complicaciones,
        'aipe': situacion.aipe,
        'observaciones': situacion.observaciones,
        'user': username,
      };
      if (situacion.consulta_derivacion == 'si') {
        showTratamiento = false;
      }
    }

    crossSigningCachedFuture ??=
        client.encryption.crossSigning.isCached().then((c) {
      if (mounted) setState(() => crossSigningCached = c);
      return c;
    });
    megolmBackupCachedFuture ??=
        client.encryption.keyManager.isCached().then((c) {
      if (mounted) setState(() => megolmBackupCached = c);
      return c;
    });
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.situacion != null
                    ? 'Situaciones IVE/ILE'
                    : 'Nueva Situacion IVE/ILE',
                style: TextStyle(color: Theme.of(context).backgroundColor),
              ),
            ),
          ),
        ],
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              initialValue: initialValues,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  // Text(situacion.id.toString()),
                  // Text(situacion.efector.toString()),
                  // Text(situacion.persona_dni.toString()),
                  FormBuilderDropdown(
                    name: 'efector',
                    decoration: InputDecoration(
                      labelText: 'Efector:',
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    allowClear: true,
                    initialValue: 1,
                    hint: Text('Efector:'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        context,
                        errorText: '* Requerido',
                      )
                    ]),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(efectorName),
                      )
                    ],
                  ),
                  ListTile(
                    title: Text(
                      'Datos de la persona',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0,
                        height: 4.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(top: 30.0),
                  ),
                  FormBuilderDateTimePicker(
                    name: 'persona-consulta-fecha',
                    format: DateFormat('dd/MM/yyyy'),
                    // onChanged: (value){},
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'Fecha de consulta',
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    valueTransformer: (value) => value.toString(),
                    validator: (val) {
                      if (val == null) {
                        return '* Requerido';
                      } else {
                        var now = DateTime.now();
                        if (calculateDifference(val, now) > 0) {
                          return 'La fecha de consulta no puede ser definida en el futuro';
                        }
                      }
                      return null;
                    },
                    // enabled: true,
                  ),
                  FormBuilderTextField(
                    name: 'persona-dni',
                    maxLengthEnforced: true,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    onChanged: (value) {},
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.numeric(context,
                            errorText: 'Solo se permiten números'),
                        FormBuilderValidators.minLength(context, 8,
                            allowEmpty: true,
                            errorText: 'No es un formato de DNI válido'),
                        FormBuilderValidators.maxLength(context, 8,
                            errorText:
                                'Los DNI solo pueden tener hasta 8 digitos'),
                      ],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  FormBuilderTextField(
                      name: 'persona-nombre',
                      maxLengthEnforced: true,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'Primeras 2 letras del nombre',
                      ),
                      onChanged: (value) {},
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context,
                            errorText: '* Requerido'),
                        FormBuilderValidators.maxLength(context, 2,
                            errorText: 'Solo las 2 primeras letras'),
                        FormBuilderValidators.match(context, '[A-Za-z]',
                            errorText: 'Solo se permiten letras'),
                      ])),
                  FormBuilderTextField(
                      name: 'persona-apellido',
                      maxLengthEnforced: true,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'Primeras 2 letras del apellido',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      onChanged: (value) {},
                      // valueTransformer: (text) => num.tryParse(text),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context,
                            errorText: '* Requerido'),
                        FormBuilderValidators.maxLength(context, 2,
                            errorText: 'Solo las 2 primeras letras'),
                        FormBuilderValidators.match(context, '[A-Za-z]',
                            errorText: 'Solo se permiten letras'),
                      ])),
                  FormBuilderDateTimePicker(
                    name: 'persona-nacimiento-fecha',
                    format: DateFormat('dd/MM/yyyy'),
                    valueTransformer: (value) => value.toString(),
                    // onChanged: (value){},
                    validator: (val) {
                      if (val == null) {
                        return '* Requerido';
                      } else {
                        if (val.year > 2018) {
                          return 'No es posible definir una edad menor a 5 años';
                        }
                      }
                      return null;
                    },
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                    ),

                    // enabled: false,
                  ),
                  FormBuilderChoiceChip(
                    name: 'persona-identidad-de-genero',
                    spacing: 20.0,
                    runSpacing: 5.0,
                    decoration: InputDecoration(
                      labelText: 'Identidad de género',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'mujer', child: Text('Mujer')),
                      FormBuilderFieldOption(
                          value: 'trans', child: Text('Transgenero')),
                      FormBuilderFieldOption(
                          value: 'otra',
                          child: Text('Otra identidad de género no binaria')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  FormBuilderChoiceChip(
                    name: 'persona-con-discapacidad',
                    spacing: 20.0,
                    runSpacing: 5.0,
                    decoration: InputDecoration(
                      labelText: '¿Se trata de una persona con discapacidad?',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(value: 'no', child: Text('No')),
                      FormBuilderFieldOption(
                          value: 'no-consignado',
                          child: Text('No esta consignado')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    name: 'persona-obra-social',
                    spacing: 20.0,
                    runSpacing: 5.0,
                    decoration: InputDecoration(
                      labelText: '¿Tiene obra social?',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(value: 'no', child: Text('No')),
                    ],
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(
                      labelText: 'partos',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    name: 'partos',
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(
                      labelText: 'cesareas',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    name: 'cesareas',
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(
                      labelText: 'abortos',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    name: 'abortos',
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  ListTile(
                    title: Text(
                      'Datos de la situación',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 4.0,
                        fontSize: 26.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(top: 30.0),
                  ),
                  FormBuilderChoiceChip(
                    name: 'consulta-situacion',
                    spacing: 20.0,
                    runSpacing: 5.0,
                    decoration: InputDecoration(
                      labelText: 'La situación se encuadra como',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'ive', child: Text('IVE')),
                      FormBuilderFieldOption(value: 'ile', child: Text('ILE')),
                    ],
                    onChanged: (val) {
                      if (val == 'ive') {
                        _formKey.currentState.fields['consulta-causal']
                            .didChange('no-corresponde');
                        _formKey.currentState.save();
                      }
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  FormBuilderSlider(
                    name: 'semanas-gestacion',
                    validator: (val) {
                      final selected = _formKey
                          .currentState.fields['consulta-situacion']?.value;
                      if (selected == 'ive') {
                        if (val > 14.6) {
                          return 'No es posible definir la semana de gestación despues de las 14 semanas y 6 días si el caso se encuadra como IVE';
                        }
                      }
                      if (val == null) {
                        return '* Requerido';
                      }
                      return null;
                    },
                    displayValues: DisplayValues.current,
                    min: 5.0,
                    max: 32.0,
                    divisions: 270,
                    onChangeEnd: (val) {
                      var decimalVal =
                          int.tryParse(val.toString().split('.')[1]);
                      var integerVal =
                          int.tryParse(val.toString().split('.')[0]);
                      semanasResolucionMin = val;
                      if (decimalVal > 6) {
                        _formKey.currentState.fields['semanas-gestacion']
                            .didChange(integerVal + 0.6);
                        semanasResolucionMin = integerVal + 0.6;
                        _formKey.currentState.save();
                      }
                      /* if (integerVal > 14) {
                        _formKey.currentState.fields['consulta-situacion']
                            .didChange('ile');
                        _formKey.currentState.fields['consulta-situacion'];
                        _formKey.currentState.save();
                      } */
                    },
                    activeColor: Colors.red,
                    inactiveColor: Colors.pink[100],
                    decoration: InputDecoration(
                      labelText:
                          'Semanas de gestación al inicio de la consulta',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FormBuilderChoiceChip(
                      spacing: 20.0,
                      runSpacing: 5.0,
                      name: 'consulta-causal',
                      enabled: isCausalEnabled,
                      decoration: InputDecoration(
                        labelText: 'Causal',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'vida', child: Text('Riesgo para la vida')),
                        FormBuilderFieldOption(
                            value: 'salud',
                            child: Text('Riesgo para la salud')),
                        FormBuilderFieldOption(
                            value: 'violacion', child: Text('Violación')),
                        FormBuilderFieldOption(
                            value: 'no-corresponde',
                            child: Text('No corresponde')),
                      ],
                      /* validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]), */
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-situacion']?.value;
                        if (selected == 'ive') {
                          if (val == 'vida' ||
                              val == 'salud' ||
                              val == 'violacion') {
                            return 'No es posible esta opción si la situación se encuadra como IVE. Debe indicarse "No corresponde"';
                          }
                        }
                        if (selected == 'ile') {
                          if (val == 'no-corresponde') {
                            return 'No es posible esta opción si la situación se encuadra como ILE.';
                          }
                        }
                        if (val == null || val.isEmpty) {
                          return '* Requerido';
                        }
                        return null;
                      }),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    runSpacing: 5.0,
                    name: 'consulta-origen',
                    decoration: InputDecoration(
                      labelText: '¿Cómo llega a la consulta?',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'es-usuario',
                          child: Text('Es usuaria del efector')),
                      FormBuilderFieldOption(
                          value: 'recomendada',
                          child: Text('Recomendada por conocido')),
                      FormBuilderFieldOption(
                          value: 'derivada',
                          child: Text('Derivada de otro efector de salud')),
                      FormBuilderFieldOption(
                          value: 'ong',
                          child: Text('Por una organización de la soc. civil')),
                      FormBuilderFieldOption(
                          value: 'programa',
                          child: Text('Programa SSR / 0800')),
                      FormBuilderFieldOption(
                          value: 'por-decision-propia',
                          child: Text('Por decisión propia')),
                      FormBuilderFieldOption(
                          value: 'otro', child: Text('Otro')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    name: 'consulta-derivacion',
                    decoration: InputDecoration(
                      labelText: 'Derivado a otro efector:',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    onChanged: (val) {
                      if (val == 'no') {
                        _formKey.currentState.fields['derivacion-motivo']
                            .didChange('no-corresponde');
                        _formKey.currentState.save();
                        setState(() {
                          showTratamiento = true;
                        });
                      }
                      if (val == 'si') {
                        setState(() {
                          showTratamiento = false; // SHOW TRATAMIENTO
                        });
                      }
                    },
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(value: 'no', child: Text('No')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  Visibility(
                    visible: !showTratamiento,
                    maintainState: true,
                    child: FormBuilderTypeAhead(
                      decoration: InputDecoration(
                        labelText: 'Seleccione el efector al que fue derivado',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      name: 'derivacion-efector',
                      onChanged: (value) {},
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-derivacion']?.value;
                        if (selected == 'si') {
                          if (val == null || val.isEmpty) {
                            return '* Requerido';
                          }
                        }
                        return null;
                      },
                      itemBuilder: (context, efectores) {
                        return ListTile(
                          title: Text(efectores),
                        );
                      },
                      controller: TextEditingController(text: ''),
                      // initialValue: 'Uganda',
                      suggestionsCallback: (query) {
                        if (query.isNotEmpty) {
                          var lowercaseQuery = query.toLowerCase();
                          return allEfectores.where((efectores) {
                            return efectores
                                .toLowerCase()
                                .contains(lowercaseQuery);
                          }).toList(growable: true)
                            ..sort((a, b) => a
                                .toLowerCase()
                                .indexOf(lowercaseQuery)
                                .compareTo(
                                    b.toLowerCase().indexOf(lowercaseQuery)));
                        } else {
                          return allEfectores;
                        }
                      },
                    ),
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    runSpacing: 5.0,
                    name: 'derivacion-motivo',
                    decoration: InputDecoration(
                      labelText: '¿Porque motivo fue derivado?',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'edad', child: Text('Edad gestacional')),
                      FormBuilderFieldOption(
                          value: 'falla', child: Text('Falla de tratamiento')),
                      FormBuilderFieldOption(
                          value: 'contraindicacion',
                          child: Text('Contraindicacion de Tto ambulatorio')),
                      FormBuilderFieldOption(
                          value: 'preferencia',
                          child: Text('Preferencia de la paciente')),
                      FormBuilderFieldOption(
                          value: 'no-corresponde',
                          child: Text('No corresponde')),
                    ],
                    /* validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]), */
                    validator: (val) {
                      final selected = _formKey
                          .currentState.fields['consulta-derivacion']?.value;
                      if (selected == 'si') {
                        if (val == null || val.isEmpty) {
                          return '* Requerido';
                        }
                      }
                      if (selected == 'no') {
                        if (val == 'edad' ||
                            val == 'falla' ||
                            val == 'contraindicacion' ||
                            val == 'preferencia') {
                          return 'No es posible esta opción si no fue derivado. Debe indicarse "No corresponde"';
                        }
                      }

                      return null;
                    },
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: ListTile(
                      title: Text(
                        'Datos del tratamiento',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          height: 4.0,
                          fontSize: 26.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(top: 30.0),
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderDateTimePicker(
                      name: 'tratamiento-fecha',
                      format: DateFormat('dd/MM/yyyy'),
                      // onChanged: (value){},
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText:
                            'Fecha de provisión de tratamiento farmacológico o quirúrgico',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      valueTransformer: (value) => value.toString(),
                      validator: (val) {
                        if (val == null) {
                          return '* Requerido';
                        } else {
                          final selected = _formKey.currentState
                              .fields['persona-consulta-fecha']?.value;
                          if (calculateDifference(val, selected) < 0) {
                            return 'La fecha de provision del tratamiento no puede ser anterior a la fecha de consulta';
                          }
                        }
                        return null;
                      },
                      // enabled: true,
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderChoiceChip(
                      spacing: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      name: 'tratamiento-tipo',
                      decoration: InputDecoration(
                        labelText: 'Tipo de tratamiento',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'farmacologico',
                            child: Text('Farmacológico')),
                        FormBuilderFieldOption(
                            value: 'quirurgico', child: Text('Quirúrgico')),
                        FormBuilderFieldOption(
                            value: 'farmacologico-y-quirurgico',
                            child: Text('Farmacológico y Quirúrgico')),
                      ],
                      onChanged: (val) {
                        if (val == 'quirurgico') {
                          _formKey
                              .currentState.fields['tratamiento-comprimidos']
                              .didChange(0);
                          _formKey.currentState.save();
                        }
                        if (val == 'farmacologico') {
                          _formKey.currentState.fields['tratamiento-quirurgico']
                              .didChange('no-corresponde');
                          _formKey.currentState.save();
                        }
                      },
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-derivacion']?.value;
                        if (selected == 'no') {
                          if (val == null || val.isEmpty) {
                            return '* Requerido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderTouchSpin(
                      decoration: InputDecoration(
                        labelText: 'Cantidad de comprimidos',
                        labelStyle: TextStyle(
                          fontSize: 20,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      name: 'tratamiento-comprimidos',
                      min: 0,
                      step: 1,
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['tratamiento-tipo']?.value;
                        if (selected == 'quirurgico') {
                          if (val != 0) {
                            return 'Si el tipo de tratamiento es solo quirúrgico, el número de comprimidos debe ser "0"';
                          }
                        }

                        return null;
                      },
                      iconSize: 48.0,
                      addIcon: Icon(Icons.arrow_right),
                      subtractIcon: Icon(Icons.arrow_left),
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderChoiceChip(
                      spacing: 20.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      name: 'tratamiento-quirurgico',
                      decoration: InputDecoration(
                        labelText: 'Tratamiento Quirúrgico',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      options: [
                        FormBuilderFieldOption(
                            value: 'ameu', child: Text('AMEU')),
                        FormBuilderFieldOption(
                            value: 'rue-o-legrado',
                            child: Text('RUE o Legrado')),
                        FormBuilderFieldOption(
                            value: 'ameurue', child: Text('AMEU + RUE')),
                        FormBuilderFieldOption(
                            value: 'dilatacion-evacuacion',
                            child: Text('Dilatación y evacuación')),
                        FormBuilderFieldOption(
                            value: 'otros', child: Text('Otros')),
                        FormBuilderFieldOption(
                            value: 'sin-datos', child: Text('Sin datos')),
                        FormBuilderFieldOption(
                            value: 'no-corresponde',
                            child: Text('No corresponde')),
                      ],
                      /* validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context,
                              errorText: "* Requerido")
                        ]), */
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-derivacion']?.value;
                        if (selected == 'no') {
                          final selected2 = _formKey
                              .currentState.fields['tratamiento-tipo']?.value;
                          if (selected2 == 'farmacologico') {
                            if (val == 'ameu' ||
                                val == 'rue-o-legrado' ||
                                val == 'ameurue' ||
                                val == 'dilatacion-evacuacion' ||
                                val == 'otros' ||
                                val == 'sin-datos') {
                              return 'No es posible esta opción si el tratamiento es solo Farmacológico. Debe indicarse "No corresponde"';
                            }
                          } else {
                            if (val == null || val.isEmpty) {
                              return '* Requerido';
                            }
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderSlider(
                      name: 'semanas-resolucion',
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['semanas-gestacion']?.value;
                        if (val < selected) {
                          return 'No es posible definir el momento de la resolución como anterior al inicio de la consulta';
                        }
                        if (val == null) {
                          return '* Requerido';
                        }
                        return null;
                      },
                      displayValues: DisplayValues.current,
                      onChanged: (value) {},
                      min: 5.0,
                      max: 32.0,
                      divisions: 270,
                      onChangeEnd: (val) {
                        var decimalVal =
                            int.tryParse(val.toString().split('.')[1]);
                        var integerVal =
                            int.tryParse(val.toString().split('.')[0]);
                        if (decimalVal > 6) {
                          _formKey.currentState.fields['semanas-resolucion']
                              .didChange(integerVal + 0.6);
                          _formKey.currentState.save();
                        }
                      },
                      activeColor: Colors.red,
                      inactiveColor: Colors.pink[100],
                      decoration: InputDecoration(
                        labelText:
                            'Semanas de gestación al momento de la resolución',
                        labelStyle: TextStyle(
                          fontSize: 20,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderChoiceChip(
                      spacing: 20.0,
                      runSpacing: 5.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      name: 'complicaciones',
                      decoration: InputDecoration(
                        labelText: 'Hubo complicaciones. ¿Cual?',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      options: [
                        FormBuilderFieldOption(value: 'No', child: Text('no')),
                        FormBuilderFieldOption(
                            value: 'aborto-incompleto',
                            child: Text('Aborto incompleto')),
                        FormBuilderFieldOption(
                            value: 'interrupcion-fallida',
                            child: Text('Interrupción fallida')),
                        FormBuilderFieldOption(
                            value: 'hemorragia', child: Text('Hemorragia')),
                        FormBuilderFieldOption(
                            value: 'infeccion', child: Text('Infección')),
                        FormBuilderFieldOption(
                            value: 'perforacion-uterina',
                            child: Text('Perforación uterina')),
                        FormBuilderFieldOption(
                            value: 'complicaciones-anestesia',
                            child: Text(
                                'Complicaciones relacionadas con la anestesia')),
                      ],
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-derivacion']?.value;
                        if (selected == 'no') {
                          if (val == null || val.isEmpty) {
                            return '* Requerido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderChoiceChip(
                      spacing: 20.0,
                      runSpacing: 5.0,
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      name: 'aipe',
                      decoration: InputDecoration(
                        labelText:
                            'Provisión de Anticoncepción Inmediata Post Aborto ¿Que método?',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          height: 1.0,
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      options: [
                        FormBuilderFieldOption(value: 'No', child: Text('no')),
                        FormBuilderFieldOption(
                            value: 'anticoncepcion-oral',
                            child: Text('Anticoncepción Hormonal Oral')),
                        FormBuilderFieldOption(
                            value: 'anticoncepcion-inyectable',
                            child: Text('Anticoncepción Hormonal Inyectable')),
                        FormBuilderFieldOption(
                            value: 'diu', child: Text('DIU')),
                        FormBuilderFieldOption(
                            value: 'implante',
                            child: Text('Implante subdérmico')),
                        FormBuilderFieldOption(
                            value: 'siu', child: Text('SIU')),
                        FormBuilderFieldOption(
                            value: 'preservativo', child: Text('Preservativo')),
                        FormBuilderFieldOption(
                            value: 'preservativo-hormonal',
                            child:
                                Text('Preservativo + Anticonceptivo Hormonal')),
                        FormBuilderFieldOption(
                            value: 'preservativo-diu',
                            child: Text('Preservativo + DIU, SIU o implante')),
                        FormBuilderFieldOption(
                            value: 'ligadura-tubaria',
                            child: Text('Ligadura tubaria')),
                      ],
                      validator: (val) {
                        final selected = _formKey
                            .currentState.fields['consulta-derivacion']?.value;
                        if (selected == 'no') {
                          if (val == null || val.isEmpty) {
                            return '* Requerido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: showTratamiento,
                    maintainState: true,
                    child: FormBuilderTextField(
                      name: 'observaciones',
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: FormBuilderTextField(
                      name: 'user',
                      decoration: InputDecoration(
                        labelText: 'user',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: FormBuilderTouchSpin(
                      name: 'id',
                      decoration: InputDecoration(
                        labelText: 'id',
                        contentPadding:
                            EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _formKey.currentState.save();
                      if (_formKey.currentState.validate()) {
                        sendSituacion(json.encode(_formKey.currentState.value));

                        print(json.encode(_formKey.currentState.value));
                        final selected =
                            _formKey.currentState.fields['id']?.value;
                        if (selected == 1) {
                          _formKey.currentState.reset();
                        }

                        // FocusScope.of(context).requestFocus(FocusNode());
                        // FocusScope.of(context).unfocus();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              duration: Duration(seconds: 6),
                              backgroundColor: Theme.of(context).primaryColor,
                              content:
                                  Text('El registro se guardo correctamente')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              duration: Duration(seconds: 6),
                              backgroundColor: Colors.redAccent,
                              content: Text('El formulario esta incompleto')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String email;
  final String imageUrl;

  const Contact(this.name, this.email, this.imageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}

const allEfectores = [
  'Otro',
  'HOSPITAL SANITARIO ZONAL DE BELEN DR. ENRIQUE MUÑIZ	AVENIDA CALCHAQUI 61	CATAMARCA	BELÉN	BELEN',
  'MATERNIDAD PROVINCIAL 25 DE MAYO	Hernando de Pedraza 1550	CATAMARCA	CAPITAL	CAPITAL',
  'HOSPITAL 4 DE JUNIO RAMON CARRILLO	Avenida Malvinas Argentinas 1350	CHACO	COMANDANTE FERNÁNDEZ	PRESIDENCIA ROQUE SAENZ PENA',
  'CENTRO DE SALUD BARRIO NOCAAYI	PLANTA URBANA-BARRIO NOCAAYI	CHACO	GENERAL GÜEMES	JUAN JOSE CASTELLI',
  'HOSPITAL DR. JULIO CECILIO PERRANDO	Avenida 9 de Julio 1100	CHACO	SAN FERNANDO	RESISTENCIA',
  'HOSPITAL ZONAL ANDRES ISOLA	Roberto Gómez 383	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD RENE FAVALORO PUERTO MADRYN	ALTO RIO SENGUER Y EL MAITEN	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD RUCA CALIL	ALBARRACIN 3234	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD POZZI  - ESPECIALIZADO EN SALUD INTEGRAL DE ADOLESCENTES	JUAN ACOSTA 350	CHUBUT	BIEDMA	PUERTO MADRYN',
  'HOSPITAL RURAL EL HOYO	AVENIDA ISLAS MALVINAS	CHUBUT	CUSHAMEN	EL HOYO',
  'HOSPITAL RURAL LAGO PUELO	AVENIDA 2 DE ABRIL S/N	CHUBUT	CUSHAMEN	LAGO PUELO',
  'HOSPITAL SUBZONAL EL MAITEN	PATAGONIA 615	CHUBUT	CUSHAMEN	EL MAITEN',
  'HOSPITAL REGIONAL COMODORO RIVADAVIA	Irigoyen 950	CHUBUT	ESCALANTE	COMODORO RIVADAVIA',
  'CENTRO DE SALUD DR.  ROBERTO MIAS	LOS ANDES Y PUCARA	CHUBUT	ESCALANTE	BARRIO CIUDADELA',
  'CENTRO DE SALUD INTEGRAL DEL ADOLESCENTE	SAN MARTIN 854	CHUBUT	ESCALANTE	COMODORO RIVADAVIA',
  'HOSPITAL RURAL TREVELIN	San Martín 955	CHUBUT	FUTALEUFÚ	TREVELIN',
  'CENTRO DE SALUD SARGENTO CABRAL	Malvinas Argentinas 1850	CHUBUT	FUTALEUFÚ	ESQUEL',
  'HOSPITAL ZONAL TRELEW CENTRO MATERNO INFANTIL	San Martín 696	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD AREA 16 - MALVINAS ARGENTINAS	CHACHO PEÑALOZA 214	CHUBUT	RAWSON	RAWSON',
  'CENTRO DE SALUD INTEGRAL DE LA ADOLESCENCIA	MORENO 454	CHUBUT	RAWSON	TRELEW',
  'HOSPITAL REGIONAL EVA PERON DE SANTA ROSA DE CALAMUCHITA	España y Ruta Provincial N° 5	CORDOBA	CALAMUCHITA	SANTA ROSA DE CALAMUCHITA (SANTA ROSA DE CALAMUCHITA)',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD DR. ARTURO ILLIA	CORRIENTES 61	CORDOBA	CALAMUCHITA	VILLA GENERAL BELGRANO',
  'CAPS VILLA CIUDAD PARQUE	Fátima esq. San Luis	CORDOBA	CALAMUCHITA	VILLA CIUDAD PARQUE LOS REARTES (1A.SECC',
  'HOSPITAL RAWSON	BAJADA PUCARA 2025	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL MATERNO PROVINCIAL FELIPE LUCCINI	PASAJE LUIS CAEIRO 1545	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL NACIONAL DE CLINICAS	SANTA ROSA 1564	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL MATERNO NEONATAL	AVENIDA LA CARDEÑOSA 2900	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL DEL SUR PRINCIPE DE ASTURIAS	DEFENSA 1200	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL FLORENCIO DIAZ	AVENIDA 11 DE SEPTIEMBRE 2900	CORDOBA	CAPITAL	CORDOBA',
  'CAPS CIUDAD AMPLIACION FERREYRA	BARRIO AMPLIACION FERREYRA - MANZANA 11	CORDOBA	CAPITAL	CORDOBA',
  'CAPS EL CHINGOLO	MANZANA K LOTE 7 - BARRIO EL CHINGOLO	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 8 - BARRIO LA FLORESTA	Las Orquideas S/N  (al lado del Centro vecinal)	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 56 - BARRIO EMPALME	Ariza 4800 (entre Samaniego y Pichanas)	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 57 - BARRIO ARGUELLO IPV	Mariano Martin s/n esq. Feje	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 32 - BARRIO YAPEYU	LORETO 48	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 6 - BARRIO ESTACION FLORES	Petirossi esq.  Estocolmo	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N°3 - BARRIO VILLA CORNU	Cauque s/n ( al lado del Obrador)	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 28 - BARRIO ITUZAINGO ANEXO	JAMES FRANK 5571	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 10 - BARRIO COLONIA LOLA	LOLA MORA 1340	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL JOSE URRUTIA DE UNQUILLO	3 DE FEBRERO 324	CORDOBA	COLÓN	UNQUILLO',
  'CAPS DR. OSTROVSKY	CORDOBA ESQUINA MAIPU	CORDOBA	COLÓN	SALSIPUEDES (SALSIPUEDES)',
  'CENTRO DE ATENCION PRIMARIA GOBERNADOR PIZARRO	Guaicurues S/N	CORDOBA	COLÓN	UNQUILLO',
  'CENTRO DE SALUD  SAN MIGUEL	Jose Ingenieros esq Alfonsina Storni	CORDOBA	COLÓN	UNQUILLO',
  'CENTRO DE SALUD VILLA FORCHIERI	LOS PINOS 460	CORDOBA	COLÓN	UNQUILLO',
  'CENTRO DE SALUD MUNICIPAL DR. NORCELO CARDOZO	Sarmiento sobre Costanera Kennedy	CORDOBA	COLÓN	RIO CEBALLOS',
  'HOSPITAL AURELIO CRESPO	Félix Cáceres S/N	CORDOBA	CRUZ DEL EJE	CRUZ DEL EJE',
  'HOSPITAL MUNICIPAL VILLA DE SOTO	ONCATIVO 451	CORDOBA	CRUZ DEL EJE	VILLA DE SOTO',
  'HOSPITAL REGIONAL LUIS PASTEUR	MENDOZA 2152	CORDOBA	GENERAL SAN MARTÍN	VILLA MARIA',
  'DISPENSARIO SAN ANTONIO DE ARREDONDO	Avenida Cura Brochero y Camino a las Jarillas	CORDOBA	PUNILLA	SAN ANTONIO DE ARREDONDO',
  'CENTRO DE INTEGRACION COMUNAL EVA PERON	PRESIDENTE PERON 559	CORDOBA	PUNILLA	COSQUIN',
  'DISPENSARIO SANTO DOMINGO SAVIO	9 de julio esquina con la plaza	CORDOBA	PUNILLA	SANTA MARIA DE PUNILLA',
  'HOSPITAL SAN ANTONIO DE PADUA DE RIO CUARTO	ROSARIO DE SANTA FE 495	CORDOBA	RÍO CUARTO	RIO CUARTO',
  'HOSPITAL LUIS MARIA BELLODI MINA CLAVERO	Bv. Rosell esq. Alta Gracia	CORDOBA	SAN ALBERTO	MINA CLAVERO',
  'PUESTO SANITARIO LAS CALLES	CALLE PUBLICA S/N°	CORDOBA	SAN ALBERTO	LAS CALLES',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD COMUNAL JOSE GABRIEL BROCHERO	UNQUILLO ESQ. LAS MORAS	CORDOBA	SAN ALBERTO	MINA CLAVERO',
  'HOSPITAL REGIONAL VILLA DOLORES	AVENIDA BELGRANO 1800	CORDOBA	SAN JAVIER	VILLA DOLORES',
  'DISPENSARIO CURA BROCHERO	Ruta 14 y Calle Bonnier	CORDOBA	SAN JAVIER	LOS HORNILLOS',
  'CENTRO DE INTEGRACION COMUNITARIA DE VILLA DOLORES	Cerrito esquina Marambio	CORDOBA	SAN JAVIER	VILLA DOLORES',
  'HOSPITAL REGIONAL JOSE BERNARDO ITURRASPE	DOMINGO CULLEN 450	CORDOBA	SAN JUSTO	SAN FRANCISCO',
  'HOSPITAL DR. ARTURO ILLIA DE ALTA GRACIA	AVENIDA DEL LIBERTADOR 1450	CORDOBA	SANTA MARÍA	ALTA GRACIA',
  'CS LA SERRANITA	GRAL ROCA S/N E/ BELGRANO Y SAN AGUSTIN	CORDOBA	SANTA MARIA	´9999',
  'DISPENSARIO MUNICIPAL Nº 1 BARRIO VILLA OVIEDO	URQUIZA 358	CORDOBA	SANTA MARÍA	ALTA GRACIA',
  'HOSPITAL ZONAL OLIVA	Hipólito Yrigoyen y Monseñor Gallardo	CORDOBA	TERCERO ARRIBA	OLIVA',
  'HOSPITAL PROVINCIAL DE  RIO TERCERO	12 DE OCTUBRE 500	CORDOBA	TERCERO ARRIBA	RIO TERCERO',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD DR. SALVADOR SCAVUZZO	CASTELLI 417	CORDOBA	TERCERO ARRIBA	ALMAFUERTE',
  'CENTRO ASISTENCIAL Nº 4 BARRIO SARMIENTO	Río Pilcomayo y Río Gallegos	CORDOBA	TERCERO ARRIBA	RIO TERCERO',
  'CENTRO ASISTENCIAL Nº 6 BARRIO CERINO	CORNELIO SAAVEDRA 174	CORDOBA	TERCERO ARRIBA	RIO TERCERO',
  'HOSPITAL SAN BENJAMIN	Esteva Berga 270	ENTRE RIOS	COLÓN	COLON',
  'C.A.P.S.  LA BIANCA	HIPOLITO YRIGOYEN Y CABO GONZALEZ	ENTRE RIOS	CONCORDIA	CONCORDIA',
  'C.A.P.S  MARIA MARTINA B. DE CAMINAL	CARLOS PELLEGRINI 780	ENTRE RIOS	CONCORDIA	CONCORDIA',
  'HOSPITAL NUESTRA SEÑORA DE LUJAN	COLÓN Nº132	ENTRE RIOS	DIAMANTE	GENERAL RAMIREZ',
  'HOSPITAL SAN JOSE	Presbítero Dangelo  Nº35	ENTRE RIOS	FEDERACIÓN	FEDERACION',
  'HOSPITAL CENTENARIO	PASTEUR 50	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD Nº 2 - SUBURBIO SUR	GALEANO 2231	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD Nº 4 - SAN FRANCISCO	CALLE JUJUY S/N°	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD Nº 6 - MUNILLA	MONSEÑOR CHALUP Y BUENOS AIRES	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CIC N° 7 NESTOR KIRCHNER	PEDRO PERIGAN 2300	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'LA CUCHILLA	JAURECHE 803	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'HOSPITAL DE LA BAXADA DRA. TERESA RATTO (PAMI)	General Alvarado 2250	ENTRE RIOS	PARANÁ	PARANA',
  'CENTRO REGIONAL DE REFERENCIA HOSPITAL DR. GERARDO DOMAGK	JUAN MANUEL ESTRADA Nº 3701	ENTRE RIOS	PARANÁ	PARANA',
  'C.A.P.S. COLONIA AVELLANEDA	TENIENTE GIMENEZ Y LOPEZ JORDAN (colonia avellaneda)	ENTRE RIOS	PARANÁ	PARANA',
  'C.A.P.S.  MANUEL BELGRANO	PRONUNCIAMIENTO 751 - BARRIO BELGRANO	ENTRE RIOS	PARANÁ	PARANA',
  'HOSPITAL  DR. JOSEPH LISTER	MARIANO MORENO  Nº 444	ENTRE RIOS	PARANÁ	SEGUI',
  'CA.P.S.  BARTOLOME GIACOMOTTI	URQUIZA S/N° Y VIEJO HOYO	ENTRE RIOS	URUGUAY	CONCEPCION DEL URUGUAY',
  'HOSPITAL DR. FERMIN SALABERRY	María Oberti de Basualdo Nº 349	ENTRE RIOS	VICTORIA	VICTORIA',
  'HOSPITAL DE LA MADRE Y EL NIÑO	CORDOBA 1450	FORMOSA	FORMOSA	FORMOSA',
  'CENTRO DE SALUD DR. MARIO JORGE KRIMER	AVENIDA NAPOLEON URIBURU Y AVENIDA NUEVA AVELLANEDA	FORMOSA	FORMOSA	FORMOSA',
  'HOSPITAL NUESTRA SEÑORA DEL ROSARIO (20)	AVELLANEDA ESQ. MACEDONIO GRAZ  N°185	JUJUY	COCHINOCA	ABRA PAMPA',
  'CIC ABRA PAMPA (20)	Avda. Jujuy entre Sgto. Gomez y Avda. Casabindo	JUJUY	COCHINOCA	COCHINOCA',
  'HOSPITAL MATERNO INFANTIL DR HECTOR QUINTANA	José Hernández 624	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'HOSPITAL PABLO SORIA	GENERAL GÜEMES 1345	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS SANTA RITA (1)	PABLO ARROYO 2846 LOCAL 10 - BARRIO SANTA RITA 560 VIVIENDAS	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS CAMPO VERDE (1)	CALLE 65 ESQUINA 64 - S/N	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CIC COPACABANA (2)	AVENIDA MARINA VILTE ESQUINA CHORCAN - BARRIO ALTO COMEDERO	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS FONAVI (2)	SOLDADO SEVILLA ESQUINA CAPITAN KRAUSSE - BARRIO ALTO COMEDERO (50 VIVIENDAS)	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS LA VIÑA (1)	PENSAMIENTO N°688	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS DRA. VICTORIA CRUZ (EX 18 HECTAREAS) (2)	18 HECTAREAS	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'HOSPITAL ING. CARLOS SNOPEK (2)	AVENIDA SNOPEK ESQUINA FORESTAL S/N°	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CENTRO SANITARIO DR. CARLOS ALVARADO (3)- CENTRO DE ESPECIALIDADES NORTE	Independencia 41	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'HOSPITAL SAN ISIDRO LABRADOR -MONTERRICO (22)	CALLES LAS MARAVILLAS S/N° - BARRIO SAN CAYETANO	JUJUY	EL CARMEN	MONTERRICO  (MONTERRICO)',
  'HOSPITAL GENERAL M. BELGRANO (19)	SANTA FE 34	JUJUY	HUMAHUACA	HUMAHUACA',
  'HOSPITAL DR. OSCAR ORIAS (11)	AVENIDA REYMUNDO KEYNER 891 B°LEDESMA	JUJUY	LEDESMA	LIBERTADOR GENERAL SAN MARTIN',
  'CAPS DR. FERNANDO CAMPERO (11)	Belgrano 471	JUJUY	LEDESMA	LIBERTADOR GENERAL SAN MARTIN',
  'CAPS MADRE TERESA DE CALCUTA (10)	MANZANA 110 - BARRIO BELGRANO	JUJUY	LEDESMA	LIBERTADOR GENERAL SAN MARTIN',
  'CAPS SANTA ROSA (11)	M.160  L.29 B° SANTA ROSA	JUJUY	LEDESMA	LIBERTADOR GENERAL SAN MARTIN',
  'HOSPITAL WENCESLAO GALLARDO (4)	AVDA. RÍO DE LA PLATA  350	JUJUY	PALPALÁ 	PALPALA',
  'HOSPITAL DR. GUILLERMO C. PATERSON (7)	Avenida Siria 44	JUJUY	SAN PEDRO	SAN PEDRO',
  'CAPS BELGRANO (7)	AVENIDA FORMOSA ENTRE NEUQUEN Y CATAMARCA	JUJUY	SAN PEDRO	SAN PEDRO',
  'CAPS BERNACCHI (7)	CLAVERIE ESQUINA FEDERIK (AL LADO ESC DOMINGUEZ)	JUJUY	SAN PEDRO	SAN PEDRO',
  'CAPS LA MERCED (7)	AVDA LIBERTADOR ESQ. MUÑECAS	JUJUY	SAN PEDRO	SAN PEDRO',
  'CAPS PATRICIOS (7)	PUERTO ARGENTINO S/N°	JUJUY	SAN PEDRO	SAN PEDRO',
  'HOSPITAL NUESTRA SEÑORA DEL PILAR (14)	GÜEMES ESQUINA DORREGO	JUJUY	SANTA BÁRBARA	EL TALAR',
  'CAPS SANTA CLARA (7)	SALTA Y TUCUMAN RUTA PROVINCIAL Nº 6	JUJUY	SANTA BÁRBARA	SANTA CLARA',
  'HOSPITAL DR. SALVADOR MAZZA (18)	Lavalle 552	JUJUY	TILCARA	TILCARA',
  'HOSPITAL MAIMARA (16)	BELGRANO Nº 906	JUJUY	TILCARA	MAIMARA',
  'HOSPITAL DR. JORGE URO (21)	PATRICIAS ARGENTINAS 185	JUJUY	YAVI	LA QUIACA',
  'ESTABLECIMIENTO ASISTENCIAL DR. HERACLIO LUNA	JUJUY 310	LA PAMPA	ATREUCÓ	MACACHIN',
  'ESTABLECIMIENTO ASISTENCIAL DR. LUCIO MOLAS	RAUL B. DIAZ Y PILCOMAYO	LA PAMPA	CAPITAL	SANTA ROSA',
  'CENTRO RECONVERSION BARRIO ESCONDIDO	ENRIQUETA SCHMIDT y GAICH	LA PAMPA	CAPITAL	SANTA ROSA',
  'ALEJANDRO MIRANDA	MAESTROS PUNTANOS Y PAYNE NORTE	LA PAMPA	CAPITAL	SANTA ROSA',
  'JOSE CURSI	BELGRANO Nº 313	LA PAMPA	CAPITAL	ANGUIL',
  'VILLA GERMINAL	Antártida Argentina	LA PAMPA	CAPITAL	SANTA ROSA',
  'FONAVI 42 NELIDA MALDONADO	PESTALOZZI Y UNANUE	LA PAMPA	CAPITAL	SANTA ROSA',
  'MATADEROS	CALLES OLGUIN Y SEQUEIDA	LA PAMPA	CAPITAL	SANTA ROSA',
  'ESTABLECIMIENTO ASISTENCIAL DR. PABLO F. LACOSTE	AV. INDEPENDENCIA 1534	LA PAMPA	CONHELO	EDUARDO CASTEX',
  'SRTA. MECHA EDO CASTEX	AVENIDA INDEPENDENCIA S/Nº	LA PAMPA	CONHELO	EDUARDO CASTEX',
  'ESTABLECIMIENTO ASISTENCIAL DR. ENRIQUE FERRETTI	URQUIZA  715	LA PAMPA	GUATRACHÉ	ALPACHIRI',
  'ESTABLECIMIENTO ASISTENCIAL DR. MANUEL FREIRE	1º JUNTA 158	LA PAMPA	GUATRACHÉ	GUATRACHE',
  'ESTABLECIMIENTO ASISTENCIAL LUISA PEDEMONTE DE PISTARINI	CALLE Nº 15 1358	LA PAMPA	LOVENTUÉ	VICTORICA',
  'ESTABLECIMIENTO ASISTENCIAL GOBERNADOR CENTENO	CALLE 17 ESQUINA 110	LA PAMPA	MARACÓ	GENERAL PICO',
  'ESTABLECIMIENTO ASISTENCIAL DR. JORGE A. AHUAD	VICTORICA 76	LA PAMPA	PUELÉN	25 DE MAYO',
  'ESTABLECIMIENTO ASISTENCIAL VIRGILIO TEDIN URIBURU	ESPAÑA 1357	LA PAMPA	REALICÓ	REALICO',
  'ESTABLECIMIENTO ASISTENCIAL SEGUNDO TALADRIZ	San Luis 1150	LA PAMPA	TOAY	TOAY',
  'ESTABLECIMIENTO ASISTENCIAL PADRE ANGEL BUODO	Las Cautivas	LA PAMPA	UTRACÁN	GENERAL ACHA',
  'ANTARTIDA ARGENTINA	BASE MARGARITA Y ESTACION CIENTIFICA - BARRIO ANT IV	LA RIOJA	CAPITAL	LA RIOJA',
  'HOSPITAL DE ARISTOBULO DEL VALLE - NIVEL II	CORRIENTES 2001	MISIONES	CAINGUÁS	ARISTOBULO DEL VALLE',
  'HOSPITAL MATERNO NEONATAL	Av. Marconi 3464	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'HOSPITAL NIVEL II NUESTRA SEÑORA DE FATIMA	BARRIO FATIMA CALLE 3 y 13	MISIONES	CAPITAL	GARUPA',
  'HOSPITAL NIVEL IIIDR. RENE FAVALORO	AV.TAMBOR DE TACUARI 7300	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'C.A.P.S. Nº 7 SESQUICENTENARIO	Calle 166 e/ex Ruta 12 y la ruta Nacional 12 km.5 y 1/2. B° San Francisco	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'C.A.P.S. Nº 19 DON SANTIAGO	Barrio Don Santiago- calle irigoyen esquina castelli	MISIONES	CAPITAL	GARUPA',
  'C.A.P.S. Nº 5 YACYRETA	Av. Blas Parera 4799 -Ch 103	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'HOSPITAL SAMIC DE ELDORADO - NIVEL III	Km 10 y calle Dr. Prietto S/N	MISIONES	ELDORADO	ELDORADO',
  'HOSPITAL DE EL SOBERBIO - NIVEL I	CHIVILCOY S/N	MISIONES	GUARANÍ	EL SOBERBIO',
  'HOSPITAL DE SAN VICENTE - NIVEL III	TUPAC AMARU Y RUTA N° 12  al 1800	MISIONES	GUARANÍ	SAN VICENTE',
  'HOSPITAL SAMIC NIVEL II - DE L. N. ALEM DR. JUAN FERNANDO ALEGRE	RIVADAVIA 710	MISIONES	LEANDRO N. ALEM	LEANDRO N. ALEM',
  'C.A.P.S. CENTRO RUIZ DE MONTOYA	AVENIDA DE LOS INMIGRANTES S/N	MISIONES	LIBERTADOR GRL. SAN MARTÍN	RUIZ DE MONTOYA',
  'C.I.C. PUERTO RICO	San Lorenzo 756	MISIONES	LIBERTADOR GRL. SAN MARTÍN	PUERTO RICO',
  'HOSPITAL ALUMINE	4 DE CABALLERIA 547	NEUQUEN	ALUMINÉ	ALUMINE',
  'CENTRO DE SALUD VILLA PEHUENIA	RUTA 13	NEUQUEN	ALUMINÉ	VILLA PEHUENIA',
  'HOSPITAL DE AÑELO	calle 19 y calle 1, Añelo, Neuquen	NEUQUEN	AÑELO	AÑELO',
  'HOSPITAL SAN PATRICIO DEL CHAÑAR	GASPARRI 10	NEUQUEN	AÑELO	SAN PATRICIO DEL CHAÑAR',
  'HOSPITAL LAS COLORADAS - DR. CARLOS POTENTE	AV. SAN MARTÍN 250	NEUQUEN	CATÁN LIL	LAS COLORADAS',
  'HOSPITAL PLOTTIER	PARAGUAY Y SARGENTO CABRAL	NEUQUEN	CONFLUENCIA	PLOTTIER',
  'HOSPITAL DR. HORACIO HELLER	GODOY Y LIHUÉN QUIMEY S/N	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'HOSPITAL CUTRAL CO - PLAZA HUINCUL - DR. ALDO V. MAULU	SCHREIBER  S/N	NEUQUEN	CONFLUENCIA	CUTRAL CO',
  'HOSPITAL BOUQUET ROLDAN	TEODORO PLANAS 1555	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD BARRIO UNION - CAPS -	ISLAS MALVINAS 266, cutral co	NEUQUEN	CONFLUENCIA	CUTRAL CO',
  'CENTRO DE SALUD SAN LORENZO SUR	LOS ZORZALES 200	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD ALMAFUERTE	Gervasoni s/n, Lote 1, Manzana 6, Toma Esfuerzo	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'HOSPITAL SENILLOSA - DR. ADOLFO DEL VALLE	NEUQUÉN Y AV. BELGRANO	NEUQUEN	CONFLUENCIA	SENILLOSA',
  'CENTRO DE SALUD BARRIO OTAÑO - CAPS -	SALTA Y FORMOSA	NEUQUEN	CONFLUENCIA	PLAZA HUINCUL',
  'CENTRO DE SALUD BARRIO PAMPA - CAPS -	TUCUMAN Y SANTA TERESITA	NEUQUEN	CONFLUENCIA	PLAZA HUINCUL',
  'CENTRO DE SALUD BARRIO PEÑI TRAPUN - CAPS -	MOSCONI 701	NEUQUEN	CONFLUENCIA	CUTRAL CO',
  'CENTRO DE SALUD NUEVA ESPERANZA	PASAJE EMMA Y REPUBLICA DE ITALIA	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD PARQUE INDUSTRIAL	CALLE 6 ESQUINA 9 PARQUE INDUSTRIAL	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD PROGRESO	OSCAR ARABARCO 571	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD SAN LORENZO NORTE	CAYASTA Y CASTELLI	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD VALENTINA SUR	EL DORADO Y CONCEPCION	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD VILLA FARREL	INDEPENDENCIA 1234	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD VILLA MARIA	Dorrego	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD LA COLONIA RURAL NUEVA ESPERANZA	MANZANA 12 LOTE B , BARRIO COLONIA NUEVA ESPERANZA	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'HOSPITAL JUNIN DE LOS ANDES	AVENIDA ANTARTIDA ARGENTINA 155	NEUQUEN	HUILICHES	JUNIN DE LOS ANDES',
  'CENTRO DE SALUD BARRIO LANIN	Río Negro 360	NEUQUEN	HUILICHES	JUNIN DE LOS ANDES',
  'HOSPITAL SAN MARTIN DE LOS ANDES - DR. RAMON CARRILLO	AV. SAN MARTÍN 381	NEUQUEN	LÁCAR	SAN MARTIN DE LOS ANDES',
  'CENTRO DE SALUD EL ARENAL	LOS CEREZOS Y LOS PIÑONES	NEUQUEN	LÁCAR	SAN MARTIN DE LOS ANDES',
  'CENTRO DE SALUD CHACRA 30	SAN MARTIN DE LOS ANDES	NEUQUEN	LÁCAR	SAN MARTIN DE LOS ANDES',
  'CENTRO DE SALUD TIRO FEDERAL	WEBER Y PEREZ	NEUQUEN	LÁCAR	SAN MARTIN DE LOS ANDES',
  'HOSPITAL LONCOPUE DR. JOSE CUEVAS	AV. SAN MARTÍN S/N	NEUQUEN	LONCOPUÉ	LONCOPUE',
  'HOSPITAL VILLA LA ANGOSTURA - DR. OSCAR ARRAIZ	NAHUEL HUAPI 1107	NEUQUEN	LOS LAGOS	VILLA LA ANGOSTURA',
  'CENTRO DE SALUD LAS MARGARITAS	CATALANES Y PRIMEROS POBLADORES	NEUQUEN	LOS LAGOS	VILLA LA ANGOSTURA',
  'CENTRO DE SALUD BARRIO NORTE	Comahue	NEUQUEN	LOS LAGOS	VILLA LA ANGOSTURA',
  'CENTRO DE SALUD CAVIAHUE	MAPUCHE Y PUESTA DE SOL	NEUQUEN	ÑORQUÍN	CAVIAHUE',
  'HOSPITAL RINCON DE LOS SAUCES	JUJUY 47	NEUQUEN	PEHUENCHES	RINCON DE LOS SAUCES',
  'HOSPITAL PICUN LEUFU - DRA. NANCY FERRARI DE DIBY	ENTRE RÍOS S/N	NEUQUEN	PICÚN LEUFÚ	PICUN LEUFU',
  'HOSPITAL DR. JOSE VENIER LAS LAJAS	AV. ROCA 269	NEUQUEN	PICUNCHES	LAS LAJAS',
  'HOSPITAL ZAPALA	LUIS MONTI 155	NEUQUEN	ZAPALA 	ZAPALA',
  'CENTRO DE SALUD NUEVA ESPERANZA (ZAPALA)	BENIGAR Y RICARDEZ	NEUQUEN	ZAPALA 	ZAPALA',
  'HOSPITAL MARIANO MORENO - DR. CARLOS BURDES	BELGRANO Y LAVALLE S/N	NEUQUEN	ZAPALA 	MARIANO MORENO  (MARIANO MORENO)',
  'CENTRO DE SALUD ALBORADA	AVENIDA JANSSEN Y SARMIENTO	NEUQUEN	ZAPALA 	ZAPALA',
  'CENTRO DE SALUD AMPLIACION	DIPUTADO BARONE Y CORDOBA	NEUQUEN	ZAPALA 	ZAPALA',
  'CENTRO DE SALUD BARRIO 582 VIVIENDAS	AVENIDA 12 DE JULIO Y LONCOLUAN	NEUQUEN	ZAPALA 	ZAPALA',
  'CENTRO DE SALUD BARRIO CGT	CHUBUT Y PODESTA	NEUQUEN	ZAPALA 	ZAPALA',
  'HOSPITAL AREA PROGRAMA INGENIERO JACOBACCI - DR. ROGELIO CORTIZO	Julio a. Roca 475	RIO NEGRO	25 DE MAYO	INGENIERO JACOBACCI',
  'HOSPITAL AREA PROGRAMA MAQUINCHAO	Sarmiento 873	RIO NEGRO	25 DE MAYO	MAQUINCHAO',
  'HOSPITAL AREA PROGRAMA SIERRA COLORADA DR. ADOLFO FENTUCH	Hipólito Yrigoyen 149	RIO NEGRO	9 DE JULIO	SIERRA COLORADA',
  'HOSPITAL AREA PROGRAMA VIEDMA ARTEMIDES  ZATTI	Rivadavia 391	RIO NEGRO	ADOLFO ALSINA	VIEDMA',
  'CENTRO DE SALUD BARRIO GUIDO	Avenida Antártida Argentina y Cardenal Cagliero	RIO NEGRO	ADOLFO ALSINA	VIEDMA',
  'CENTRO DE SALUD MI BANDERA - DR. GUSTAVO H. ANDREANI	CALLE 15 Y ESQUINA 24	RIO NEGRO	ADOLFO ALSINA	VIEDMA',
  'HOSPITAL AREA PROGRAMA LUIS BELTRAN DR. FERNANDO ROCHA	V. López y Planes 773 y Chacabuco	RIO NEGRO	AVELLANEDA	LUIS BELTRAN',
  'HOSPITAL AREA PROGRAMA EL BOLSON	Francisco Perito Moreno 2645	RIO NEGRO	BARILOCHE	EL BOLSON',
  'HOSPITAL AREA PROGRAMA SAN CARLOS DE BARILOCHE DR. RAMON CARRILLO	Moreno 601	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD EL FRUTILLAR	Cacique Chocori	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD LA CUMBRE	LOS ANDES 1707	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD SAN FRANCISCO III	SAN JOSE DE COSTA RICA 1150	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD CASA DE LA SALUD	RUTA NACIONAL 40 Y BESCHET	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD LAS QUINTAS	ONELLI 1578	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD LERA	LOS COLIHUES 1460	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD 34 HECTAREAS	CENTRO COMUNITARIO BARRIO 2 DE ABRIL	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'HOSPITAL AREA PROGRAMA GENERAL CONESA DR. HECTOR AGUSTIN MONTEOLIVA	Sarmiento 285	RIO NEGRO	CONESA	GENERAL CONESA',
  'HOSPITAL AREA PROGRAMA CAMPO GRANDE	CIPOLLETTI 043	RIO NEGRO	GENERAL ROCA	VILLA MANZANO',
  'HOSPITAL AREA PROGRAMA INGENIERO HUERGO	Río Negro 616	RIO NEGRO	GENERAL ROCA	INGENIERO LUIS A. HUERGO',
  'HOSPITAL FRANCISCO LOPEZ LIMA DE GENERAL ROCA	Gelonch 721	RIO NEGRO	GENERAL ROCA	GENERAL ROCA',
  'HOSPITAL AREA PROGRAMA ALLEN	Ingeniero P. Quesnel S/N	RIO NEGRO	GENERAL ROCA	ALLEN',
  'HOSPITAL AREA PROGRAMA CATRIEL	España 50	RIO NEGRO	GENERAL ROCA	CATRIEL',
  'HOSPITAL AREA PROGRAMA CERVANTES	25 de Mayo 611	RIO NEGRO	GENERAL ROCA	CERVANTES',
  'HOSPITAL AREA PROGRAMA FERNANDEZ ORO	Avenida Cipolletti y Pueyrredón	RIO NEGRO	GENERAL ROCA	GENERAL FERNANDEZ ORO',
  'HOSPITAL AREA PROGRAMA VILLA REGINA	Fray Luis Beltrán 496	RIO NEGRO	GENERAL ROCA	VILLA REGINA',
  'CENTRO DE SALUD DEL BARRIO MARINI	Córdoba y Acceso Sur	RIO NEGRO	GENERAL ROCA	CATRIEL',
  'CENTRO DE SALUD ANAI MAPU	SAN ANTONIO OESTE ENTRE BOWLER Y RIO NEGRO	RIO NEGRO	GENERAL ROCA	CIPOLLETTI',
  'HOSPITAL AREA PROGRAMA RIO COLORADO	República Española 551	RIO NEGRO	PICHI MAHUIDA	RIO COLORADO',
  'HOSPITAL AREA PROGRAMA PILCANIYEU	Los Choiques y Aimoe Paine S/N	RIO NEGRO	PILCANIYEU	PILCANIYEU',
  'HOSPITAL AREA PROGRAMA SAN ANTONIO OESTE DR. ANIBAL SERRA	Avenida Belgrano 1799 y Roque Sáenz Peña	RIO NEGRO	SAN ANTONIO	SAN ANTONIO OESTE',
  'HOSPITAL DR. ARNE HOYGAARD	BENJAMIN ZORRILLA S/Nº	SALTA	CACHI	CACHI',
  'HOSPITAL NUESTRA SEÑORA DEL ROSARIO	12 de Octubre esq. Gral. Paz	SALTA	CAFAYATE	CAFAYATE',
  'HOSPITAL SEÑOR DEL MILAGRO	AVENIDA SARMIENTO 557	SALTA	CAPITAL	SALTA',
  'HOSPITAL PAPA FRANCISCO	Calle s/n  B° Solidaridad	SALTA	CAPITAL	SALTA',
  'HOSPITAL PUBLICO MATERNO INFANTIL	AV SARMIENTO Y GRAL ARENALES	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 50 CO.FRU.THOS	AVENIDA PARAGUAY S/Nº	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 61 - BARRIO SOLIDARIDAD	MANZANA 450 D LOTE 1 Y 2 II ETAPA - BARRIO SOLIDARIDAD	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 7 - VILLA 20 DE JUNIO	Ricardo Lavene	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 8 BARRIO EL TRIBUNO	DIARIO LOS ANDES S/Nº	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 12 - BARRIO SANTA LUCIA	CALLE 6 ENTRE CALLE 7 Y CALLE 9	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 25 - FCA. SAN LUIS	KM 9 - CAMINO A QUIJANO	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 27 - BARRIO INTERSINDICAL	MED. 3500 - RADIO SPLENDID Y R. ROMERO	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 29 GRAL. SAN MARTIN - FCA. INDEPENDENCIA	AVENIDA FLORENCIO VARELA S/N°	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 45 - BARRIO PROVIPO	FELIPE VARELA  y CESAR PERDIGUERO	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 57 SANTA ANA II	CALLE 13 y CALLE 5 - BARRIO SANTA ANA II	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 21 VILLA PALACIOS	Av. Jose Contrera s/n  - Salta Capital	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 65 BARRIO 17 DE MAYO	Manzana 3 911 (entre calle Portaaviones y Rivadavia)	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 23 - SAN RAFAEL	San Rafael	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 55 - BARRIO 17 DE OCTUBRE	Av. Jaime Durán s/n°	SALTA	CAPITAL	SALTA',
  'HOSPITAL SANTA TERESITA	Libertad 352	SALTA	CERRILLOS 	CERRILLOS',
  'HOSPITAL DR. RAFAEL VILLAGRAN	EL CARMEN Nº 360	SALTA	CHICOANA	CHICOANA',
  'HOSPITAL DR. JOAQUIN CASTELLANOS	CABRED S/Nº	SALTA	GENERAL GÜEMES	GENERAL GUEMES',
  'HOSPITAL PRESIDENTE JUAN DOMINGO PERON DE TARTAGAL	Alberdi 855	SALTA	GRL. JOSÉ DE SAN MARTÍN	TARTAGAL (TARTAGAL)',
  'HOSPITAL DEL CARMEN	José Ignacio Sierra 610	SALTA	METÁN	SAN JOSE DE METAN',
  'HOSPITAL DR. VICENTE ARROYABE	RIVADAVIA 747 - PICHANAL - ORAN	SALTA	ORÁN	PICHANAL',
  'HOSPITAL DR. ELIAS ANNA	INDEPENDENCIA 524 - COLONIA SANTA ROSA	SALTA	ORÁN	COLONIA SANTA ROSA',
  'HOSPITAL SAN CARLOS	GRAL. SAN MARTÍN S/Nº	SALTA	SAN CARLOS	SAN CARLOS',
  'HOSPITAL DR. FEDERICO CANTONI	AV. JOAQUIN UÑAC ENTRE CALLE 10 Y 11. POCITO.	SAN JUAN	POCITO	VILLA ABERASTAIN',
  'CAPS ALDO HERMOSILLA	ABERASTAIN ENTRE CALLES 14 y 15	SAN JUAN	POCITO	LA RINCONADA',
  'CAPS CARMEN IBONE SILVA	CALLE RIVEROS Y BALCARCE - Bº BALCARCE	SAN JUAN	SANTA LUCÍA	SANTA LUCIA',
  'HOSPITAL JUAN KLIPSONS DE LUJAN	MITRE S/N Y PRINGLES	SAN LUIS	AYACUCHO	LUJAN',
  'HOSPITAL QUINES	SARMIENTO S/N Y SAN JOSE	SAN LUIS	AYACUCHO	QUINES',
  'CAPS VILLA DE LA QUEBRADA	25 DE MAYO Y 9 DE JULIO	SAN LUIS	BELGRANO	VILLA DE LA QUEBRADA',
  'HOSPITAL JUAN D. PERON	MAIPU 450	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'CAPS LAS MIRANDAS	GENERAL PAUNERO 683	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'CAPS RENE FAVALORO (EX PIMPOLLO)	DOCTOR MESTRE 1453	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'CAPS TRES ESQUINAS (ATE II)	BARRIO ATE II - MANZANA 5	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'HOSPITAL DE DIA JUSTO SUAREZ ROCHA	MANZANA 6031 BARRIO JARDIN DEL SUR	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'HOSPITAL DR. BRAULIO MOYANO	PRINCIPAL S/N° - MANZANA 7090 - BARRIO LA RIBERA	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'HOSPITAL DE REFERENCIA EVA PERON	TORRES FERRARIS 1289	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'CAPS SAN ANTONIO	ALMAFUERTE 384	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'CAPS SAN JOSE	URUGUAY 804	SAN LUIS	GENERAL PEDERNERA	VILLA MERCEDES',
  'HOSPITAL DEL SUR	J. ZABALA 126 - BARRIO MANUEL LEZCANO	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CAPS CERRO DE ORO	Calle Principal s/n - A 18 KM DEL HOSP. POR TIERRA	SAN LUIS	JUNÍN	CERRO DE ORO',
  'HOSPITAL MERLO	JUANA AZURDUY S/N  E/ PTE. PERON Y BAJADA DEL SOL	SAN LUIS	JUNÍN	MERLO',
  'HOSPITAL MARIA J. BECKER DE LA PUNTA	LOTE 5 - CALLE 5 ENTRE CALLE 8 Y AVENIDA SERRANIA PUNTANA	SAN LUIS	LA CAPITAL	LA PUNTA',
  'CAPS BALDE	26 DE JULIO S/N°	SAN LUIS	LA CAPITAL	BALDE',
  'CAPS BEAZLEY	RODRIGUEZ JURADO 596	SAN LUIS	LA CAPITAL	BEAZLEY',
  'CAPS EL VOLCAN	PRINGLES 2020	SAN LUIS	LA CAPITAL	EL VOLCAN',
  'CAPS MALVINAS ARGENTINAS	AVENIDA LAFINUR Y JUNIN	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CAPS BARRIO 1° DE MAYO	AVENIDA 5º CENTENARIO 4620 (MANZANA S Lote 7 - BARRIO 1º DE MAYO)	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CAPS JULIO BONA Nº 12	Manzana A - CASA 6 Bº Pucará	SAN LUIS	LA CAPITAL	SAN LUIS',
  'HOSPITAL CERRO DE LA CRUZ	BARRIO CERRO DE LA CRUZ 142 VIVIENDAS MANZANA 314	SAN LUIS	LA CAPITAL	SAN LUIS',
  'HOSPITAL DEL OESTE DR. ATILIO LUCHINI	CALLE HUMBERTO BALLADORES MANZANA 161 BARRIO INTENDENTE JUAN CARNEVALLE	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CENTRO DE SALUD NRO 1 RAMON CARRILLO	12 DE OCTUBRE Y VENEZUELA	SANTA CRUZ	DESEADO	PUERTO DESEADO',
  'HOSPITAL ZONAL DE CALETA OLIVIA PADRE JOSE TARDIVO	EVA PERÓN  S/N Y VELEZ SARSFIELD	SANTA CRUZ	DESEADO	CALETA OLIVIA',
  'HOSPITAL DISTRITAL DR. JOSE FORMENTI	JULIO ARGENTINO ROCA 1487	SANTA CRUZ	LAGO ARGENTINO	EL CALAFATE',
  'PUESTO SANITARIO EL CHALTEN	De Agostini  Nº 70	SANTA CRUZ	LAGO ARGENTINO	EL CHALTEN',
  'HOSPITAL DE ALTA COMPLEJIDAD EL CALAFATE - SAMIC	Avenida Jorge Newbery 453	SANTA CRUZ	LAGO ARGENTINO	EL CALAFATE',
  'HOSPITAL REGIONAL NUESTRA SEÑORA DE LA CANDELARIA.	FLORENTINO AMEGHINO 709	TIERRA DEL FUEGO	RÍO GRANDE	RIO GRANDE',
  'CAPS NRO 7 SOLER DE LA LAGUNA	Facundo Quiroga 2142	TIERRA DEL FUEGO	RÍO GRANDE	RIO GRANDE',
  'HOSPITAL REGIONAL USHUAIA GOBERNADOR ERNESTO M. CAMPOS	12 de Octubre 65	TIERRA DEL FUEGO	USHUAIA	USHUAIA',
  'HOSPITAL GARMENDIA	ZONA URBANA 9 DE JULIO S/N°	TUCUMAN	BURRUYACÚ	GARMENDIA',
  'HOSPITAL DE CLINICAS PRESIDENTE DR. NICOLAS AVELLANEDA	CATAMARCA 2000	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'INSTITUTO DE MATERNIDAD Y GINECOLOGIA NUESTRA SEÑORA DE LAS MERCEDES	AVENIDA MATE DE LUNA 1550	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'HOSPITAL ANGEL CRUZ PADILLA	Alberdi 550	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'HOSPITAL CENTRO DE SALUD ZENON J. SANTILLAN	Avenida Avellaneda 750	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'CAPS VILLA 9 DE JULIO	AVENIDA JUAN B. JUSTO 1577	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'HOSPITAL REGIONAL CONCEPCION DR. MIGUEL BELASCUAIN	San Luis 150	TUCUMAN	CHICLIGASTA	CONCEPCION',
  'HOSPITAL DEL ESTE EVA PERON	Ruta N° 9 y Camino del Carmen	TUCUMAN	CRUZ ALTA	BANDA DEL RIO SALI',
  'CAPS ESTACION COLOMBRES	AV. SAN MARTÍN S/N	TUCUMAN	CRUZ ALTA	COLOMBRES',
  'HOSPITAL GRAL. LAMADRID MONTEROS	SARMIENTO 453	TUCUMAN	MONTEROS	MONTEROS',
  'CAPS COLALAO DEL VALLE	RUTA NACIONAL 40 KM 4308 FRENTE A ESCUELA Nº 32	TUCUMAN	TAFÍ DEL VALLE	COLALAO DEL VALLE',
  'CAPS EL MOLLAR (TAFI DEL VALLE)	Avenida Los Menhires	TUCUMAN	TAFÍ DEL VALLE	EL MOLLAR',
  'POLICLINICA DR. ADRIAN TUMA (AMAICHA DEL VALLE)	AVENIDA SAN MARTIN FRENTE A LA PLAZA DE AMAICHA	TUCUMAN	TAFÍ DEL VALLE	AMAICHA DEL VALLE',
  'POLICLINICA DR. PEDRO SOLORZANO	EVA PERÓN Y CATAMARCA	TUCUMAN	TAFÍ VIEJO	TAFI VIEJO',
  'POLICLINICA ASISTENCIA PUBLICA  TAFI VIEJO	Av. Leandro N. Alem 487	TUCUMAN	TAFÍ VIEJO	TAFI VIEJO',
  'HOSPITAL ZONAL GENERAL AGUDOS DR. LUCIO V. MELENDEZ	Presidente Juan Domingo Perón 859	BUENOS AIRES	ALMIRANTE BROWN	ADROGUE',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD LOS PINOS	Cobian 215	BUENOS AIRES	ALMIRANTE BROWN	MINISTRO RIVADAVIA',
  'CAPS N°25 2 DE ABRIL	SANTA ANA Y MURATURE	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  'Nº 22 LOMA VERDE	PORTUGAL 1802	BUENOS AIRES	ALMIRANTE BROWN	MALVINAS ARGENTINAS',
  'UNIDAD SANITARIA GLEW II	DE NAVAZIO Y DI CARLO S/N BO. ALMAFUERTE - GLEW	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  'UNIDAD SANITARIA N° 10 28 DE DICIEMBRE DE RAFAEL CALZADA	GORRION ENTRE JORGE Y ARROYO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  'UNIDAD SANITARIA N° 11 LA GLORIA DE SAN JOSE	LA CALANDRIA ENTRE BYNON Y MITRE S/N LA TABLADA SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  'UNIDAD SANITARIA N° 12 DON ORIONE DE CLAYPOLE	Calle 11 y Av. Eva Perón - Barrio Don Orione	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  'UNIDAD SANITARIA N° 13 DE BURZACO	Alsina y Martín Fierro	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'UNIDAD SANITARIA N° 16 DE RAFAEL CALZADA	AV. SAN MARTIN 4900 Y SAN CARLOS BARRIO SAN GERONIMO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  'UNIDAD SANITARIA N° 4 SAN JOSE DE ALMIRANTE BROWN	SAN LUIS 166 SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  'UNIDAD SANITARIA N° 6 LOS ALAMOS DE GLEW	JULIAN AGUIRRE Y SANTACLARA S/N BARRIO LOS ALAMOS GLEW	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  'UNIDAD SANITARIA N° 7 13 DE JULIO DE CLAYPOLE	Anemonas 6545 entre Clavel y Camelia	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  'UNIDAD SANITARIA Nº 23 RAMON CARRILLO	Zufriategui 3550	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  'UNIDAD DE SALUD AMBIENTAL	Constitucion 972	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD SAKURA	Massey 3212	BUENOS AIRES	ALMIRANTE BROWN	LONGCHAMPS',
  'HOSPITAL SUBZONAL ESPECIALIZADO MATERNO INFANTIL ANA GOITIA	Vicente López 1737	BUENOS AIRES	AVELLANEDA	AVELLANEDA',
  'UNIDAD SANITARIA N° 1 VILLA CORINA DE AVELLANEDA	PIERRES Y CASACUBERTA	BUENOS AIRES	AVELLANEDA	SARANDI',
  'UNIDAD SANITARIA N° 2 DE AVELLANEDA	MAZZINI 1325	BUENOS AIRES	AVELLANEDA	DOCK SUD',
  'HOSPITAL ZONAL ESPECIALIZADO EN PEDIATRIA ARGENTINA DIEGO	Alfredo Prat 511	BUENOS AIRES	AZUL	AZUL',
  'HOSPITAL MUNICIPAL DR. ANGEL PINTOS	Amado Diab 270	BUENOS AIRES	AZUL	AZUL',
  'UNIDAD SANITARIA E. MAGUILLANSKY N° 1	CALLE 38 1169 BARRIO SAN FRANCISCO	BUENOS AIRES	AZUL	AZUL',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS DR. JOSE PENNA	Avenida Lainez 2401	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA SAN DIONISIO	Pacífico 152	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA BARRIO COLON	O Higgins 1641 - Barrio Colón	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA BARRIO MIRAMAR	Laudelino Cruz 1892 - Barrio Miramar	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA GENERAL CERRI	25 DE MAYO 396	BUENOS AIRES	BAHÍA BLANCA	GENERAL DANIEL CERRI',
  'SALA MEDICA GRUNBEIN	La Rioja 5700 - Barrio Grunbein	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA LOMA PARAGUAYA	Félix Farías 850 - Barrio Loma Paraguaya	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA VILLA SERRA	Tarija 1350 - Barrio Villa Serra	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA INGENIERO WHITE	PAUL HARRIS Y LAUTARO - INGENIERO WHITE	BUENOS AIRES	BAHÍA BLANCA	INGENIERO WHITE',
  'UNIDAD SANITARIA NUEVA BELGRANO	Witcomb 3900 - Barrio Belgrano	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA TIRO FEDERAL	Pellegrini 638 - Barrio Tiro Federal	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA VILLA FLORESTA	José Ingenieros 2235	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA VILLA GLORIA	Rojas 4898 - Barrio Villa Gloria	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA VILLA MUÑIZ	PILCANIYEU 259 - BO. VILLA MUÑIZ	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'CENTRO INTEGRADOR COMUNITARIO	Esmeralda 1405	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'CENTRO INTEGRADOR COMUNITARIO II	116 BIS Y 15	BUENOS AIRES	BALCARCE	BALCARCE',
  'HOSPITAL ZONAL GENERAL AGUDOS DESCENTRALIZADO EVITA PUEBLO	Calle 136 2905	BUENOS AIRES	BERAZATEGUI	BERAZATEGUI',
  'UNIDAD SANITARIA N° 18 DE BERAZATEGUI	CALLE 20 ENTRE 161 Y 162 BARRIO GENERAL BELGRANO	BUENOS AIRES	BERAZATEGUI	BERAZATEGUI',
  'UNIDAD SANITARIA N° 44 DR RAMON CARRILLO	Calle 122 Bis	BUENOS AIRES	BERISSO	BERISSO',
  'CENTRO PERIFERICO N° 4 DE CAMPANA	ZARATE ENTRE  S.DELLEPIANE Y UGARTEMENDIA - SAN CAYETANO	BUENOS AIRES	CAMPANA	CAMPANA',
  'CAPS N° 5	Aguiar N° 162	BUENOS AIRES	CAMPANA	CAMPANA',
  'UNIDAD SANITARIA SAGRADO CORAZON DE JESUS MAXIMO PAZ	PERU Y BENAVIDEZ S/Nº Bº SAN CARLOS	BUENOS AIRES	CAÑUELAS	MAXIMO PAZ',
  'UNIDAD SANITARIA BARRIO EL PORTEÑO DE CHASCOMUS	LUCIO V. MANSILLA Y CALLE 3	BUENOS AIRES	CHASCOMÚS	CHASCOMUS',
  'HOSPITAL MUNICIPAL DE COLON	CALLE 50 ENTRE 12 Y 13	BUENOS AIRES	COLÓN	COLON',
  'HOSPITAL LOCAL GENERAL EVA PERON	URIBURU 650	BUENOS AIRES	CORONEL DE MARINA L. ROSALES	PUNTA ALTA',
  'HOSPITAL MUNICIPAL MARIA EVA DUARTE DE PERON	El Indio 350	BUENOS AIRES	CORONEL DORREGO	CORONEL DORREGO',
  'CENTRO DE ATENCION PRIMARIA DR. PASCUAL GUIDICE	ESTADOS UNIDOS Y SAN MARTIN	BUENOS AIRES	ENSENADA	ENSENADA',
  'UNIDAD SANITARIA 1° DE MAYO DE ENSENADA	ECUADOR Y SAENZ PEÑA BARRIO 1° DE MAYO 17	BUENOS AIRES	ENSENADA	ENSENADA',
  'CENTRO DE ATENCION PRIMARIA DR PASCUAL GIUDICE	LA PAZ Y SAN MARTIN	BUENOS AIRES	ENSENADA	ENSENADA',
  'HOSPITAL ZONAL GENERAL AGUDOS DR. ERILL	Eugenia Tapia de Cruz	BUENOS AIRES	ESCOBAR	MAQUINISTA F. SAVIO ESTE',
  'SALA DE PRIMEROS AUXILIOS PAVON	RUTA 39 KM. 1	BUENOS AIRES	EXALTACIÓN DE LA CRUZ	PAVON',
  'UNIDAD SANITARIA N° 5	Belgrano y Canale	BUENOS AIRES	EZEIZA	TRISTAN SUAREZ',
  'HOSPITAL DE ALTA COMPLEJIDAD EL CRUCE	Avenida Calchaquí 5401	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'HOSPITAL GENERAL MI PUEBLO	Doctor Juan Carlos Mainini 240	BUENOS AIRES	FLORENCIO VARELA	VILLA VATTEONE',
  'UNIDAD SANITARIA DR. EVARISTO RODRIGUEZ - VILLA HUDSON	IBERIA 359 ENTRE PICO TRUNCADO Y BROCHERO - BARRIO VILLA HUDSON	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS DR. OSCAR ALENDE DE MAR DEL PLATA	Av. Juan B. Justo y 164	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'HOSPITAL INTERZONAL ESPECIALIZADO MATERNO INFANTIL DR. VICTORIO TETAMANTI	Castelli 2450	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. ANTARTIDA ARGENTINA	479 Y ANTARTIDA ARGENTINA	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. FELIX U. CAMET	CALLE 18 ENTRE 13 Y 15 CAMET	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. BELGRANO	Soler (33) 1109	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. LIBERTAD	Leguizamón Onésimo 552	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. BATAN	Calle Parra Violeta e/ 134 y 132	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. AEROPARQUE	Pelayo 1780	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'CAPS ALTO CAMET	Cura Brochero 7100	BUENOS AIRES	GENERAL PUEYRREDÓN	CAMET',
  'UNIDAD SANITARIA BARRIO 2 DE ABRIL DE MAR DEL PLATA	SOLDADO PACHEOLZUK 850 - BARRIO 2 DE ABRIL	BUENOS AIRES	GENERAL PUEYRREDON	PUNTA MOGOTES',
  'C.A.P.S. AMEGHINO	Avenida Luro 10056	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. FARO NORTE	Sánchez de Bustamante 3460 - Barrio Faro	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. JORGE NEWBERY	Moreno 9375	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'UNIDAD SANITARIA LAS HERAS DE MAR DEL PLATA	Heguilor 2750	BUENOS AIRES	GENERAL PUEYRREDÓN	PUNTA MOGOTES',
  'C.A.P.S. PARQUE HERMOSO	Vignolo (206) e/ Ocampo (3) y  Yemehuech (1) - B° Parque Hermoso	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. SANTA RITA	Guanahani 7751	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'CAPS ING. NANDO MICONI- PARQUE INDEPENDENCIA	Av. Newberry 3575	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. BELISARIO ROLDAN	Rauch bis 3131	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'HOSPITAL ZONAL GENERAL AGUDOS MANUEL BELGRANO	Avenida de los Constituyentes 3120	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA ZAGALA',
  'HOSPITAL MUNICIPAL DR. DIEGO E. THOMPSON	Avellaneda N° 33 e/ Matheu y Mitre	BUENOS AIRES	GENERAL SAN MARTÍN	CIUDAD DEL LIBERTADOR GENERAL SAN MARTIN',
  'CAPS N° 22 "DR. JUAN NAAB"	DEBENEDETTI 8555, VILLA LANZONE OESTE	BUENOS AIRES	GENERAL SAN MARTIN	VILLA JOSE LEON SUAREZ',
  'UNIDAD SANITARIA N° 8 HEROES DE MALVINAS DE SAN ANDRES	J. M. CAMPOS Y CATAMARCA 2152	BUENOS AIRES	GENERAL SAN MARTÍN	SAN ANDRÉS',
  'CENTRO DE SALUD DR. LUIS AGOTE	Av. San Martin  1655	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'CENTRO DE SALUD N° 6 BARRIO LIBERTADOR DE LOMA HERMOSA	Pensamiento 5321 entre Hortensias y Eva Perón	BUENOS AIRES	GENERAL SAN MARTÍN	LOMA HERMOSA',
  'CENTRO DE SALUD NTRA. SRA. DEL ROSARIO	PASO DE LA PATRIA S/Nº	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'CENTRO DE SALUD RAMON CARRILLO DE GENERAL SAN MARTIN	OCAMPOS ESQUINA MAIPU 5023	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA MAIPU',
  'CENTRO DE SALUD VILLA CONCEPCION	CALLE 88 INDEPENDENCIA 866	BUENOS AIRES	GENERAL SAN MARTÍN	GENERAL SAN MARTÍN',
  'UNIDAD SANITARIA MARENGO	CALLE 51 (REPUBLICA) 10 ESQUINA CALLE 110 (PUEYRREDON)	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA BALLESTER',
  'UNIDAD SANITARIA N° 10 VILLA ESPERANZA DE JOSE LEON SUAREZ	GARIBALDI 1897	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'UNIDAD SANITARIA N° 14 BARRIO UTA DE LOMA HERMOSA	CALLE 139 (MARTOLOME MITRE) N° 1253	BUENOS AIRES	GENERAL SAN MARTÍN	LOMA HERMOSA',
  'UNIDAD SANITARIA N° 16 SALVADOR MAZZA DE VILLA ZAGALA	Pasaje A entre 66 y 68 (Almirante Brown Nº 2850)	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA ZAGALA',
  'UNIDAD SANITARIA N° 17 BARRIO NECOCHEA DE JOSE LEON SUAREZ	OBLIGADO 1610	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'UNIDAD SANITARIA N° 7 JOSE PEREYRA DE JOSE LEON SUAREZ	Malvinas Argentinas 3699	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'UNIDAD SANITARIA N° 9 DE VILLA BILLINGHURST	PRIMERA JUNTA 5745	BUENOS AIRES	GENERAL SAN MARTÍN	BILLINGHURST',
  'UNIDAD SANITARIA VILLA LANZONE	Iberá 7456 - Barrio 9 de Julio	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA LANZONE',
  'CAPS N° 19 VILLA LIBERTAD	La Crujia 5815	BUENOS AIRES	GENERAL SAN MARTÍN	BARRIO PARQUE GENERAL SAN MARTIN',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD (CAPS) Nº 21	Guemes Nº 2018	BUENOS AIRES	GENERAL SAN MARTÍN	CIUDAD DEL LIBERTADOR GENERAL SAN MARTIN',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD N° 11 SANTA ANA	3 de Febrero 2590	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA SAN ANDRES',
  'HOSPITAL MUNICIPAL SAN BERNARDINO DE SIENA	German Argerich 1650	BUENOS AIRES	HURLINGHAM	WILLIAM C. MORRIS',
  'UNIDAD SANITARIA 2 DE ABRIL DE HURLINGHAM	LA TRILLA Y CIUDADELA - BARRIO 2 DE ABRIL	BUENOS AIRES	HURLINGHAM	HURLINGHAM',
  'UNIDAD SANITARIA BARRIO ANGEL	POTOSI Y LEVALLE - BARRIO SAN DAMIAN	BUENOS AIRES	HURLINGHAM	HURLINGHAM',
  'HOSPITAL DEL BICENTENARIO -ITUZAINGO-	Coronel Brandsen 2898-2768 e/ Pedro Zanini y Cnel. Pringles	BUENOS AIRES	ITUZAINGÓ	ITUZAINGO SUR',
  'CENTRO MEDICO DE LA FAMILIA BARRIO JUAN XXIII	AVENIDA 1 Y CALLE 10	BUENOS AIRES	LA COSTA	SAN CLEMENTE DEL TUYU',
  'HOSPITAL ZONAL GENERAL AGUDOS DR. PAROISSIEN	Brigadier General Juan Manuel de Rosas 5975	BUENOS AIRES	LA MATANZA	ISIDRO CASANOVA',
  'HOSPITAL ZONAL GENERAL DE AGUDOS GONZALEZ CATAN KM. 32 SIMPLEMENTE EVITA	Av José Equiza 6463	BUENOS AIRES	LA MATANZA	GONZALEZ CATAN',
  'HOSPITAL ZONAL GENERAL DE AGUDOS DR. ALBERTO EDGARDO BALESTRINI	Camino de Cintura y Ruta N° 21	BUENOS AIRES	LA MATANZA	CIUDAD EVITA',
  'HOSPITAL MATERNO INFANTIL DRA. TERESA LUISA GERMANI	AVENIDA LURO 6561	BUENOS AIRES	LA MATANZA	GREGORIO DE LAFERRERE',
  'UNIDAD SANITARIA SAN CARLOS DE LA MATANZA	LAVALLOL Y EDISON 1095	BUENOS AIRES	LA MATANZA	ISIDRO CASANOVA',
  'UNIDAD SANITARIA  MARIA ELENA	RISSO PATRON Y ORTEGA RUTA NAC Nº 3 KM 27	BUENOS AIRES	LA MATANZA	GREGORIO DE LAFERRERE',
  'UNIDAD SANITARIA IGNACIO EZCURRA DE VILLA DORREGO	MONSEÑOR LOPEZ MAY 6560	BUENOS AIRES	LA MATANZA	GONZALEZ CATAN',
  'UNIDAD SANITARIA LAFERRERE	ESTANISLAO DEL CAMPO 3067	BUENOS AIRES	LA MATANZA	GREGORIO DE LAFERRERE',
  'CENTRO DE SALUD RAMON CARRILLO DE LA MATANZA	AV. CENTRAL Y DOSCIENTOS	BUENOS AIRES	LA MATANZA	CIUDAD EVITA',
  'CENTRO DE SALUD SAKAMOTO	Nicolás Davila 2110	BUENOS AIRES	LA MATANZA	RAFAEL CASTILLO',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS GENERAL SAN MARTIN	CALLE 1 ESQUINA 70	BUENOS AIRES	LA PLATA	LA PLATA',
  'HOSPITAL ZONAL GENERAL DE AGUDOS DR. RICARDO GUTIERREZ	DIAGONAL 114 ENTRE 39 Y 40	BUENOS AIRES	LA PLATA	LA PLATA',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS SAN ROQUE	CALLE 508  ENTRE 18 Y 19	BUENOS AIRES	LA PLATA	MANUEL B. GONNET',
  'HOSPITAL SUBZONAL ESPECIALIZADO DR. JOSE INGENIEROS	CALLE 161 Y 514	BUENOS AIRES	LA PLATA	MELCHOR ROMERO',
  'HOSPITAL INTERZONAL DE AGUDOS Y CRONICOS DR. ALEJANDRO KORN	CALLE 520 Y 175	BUENOS AIRES	LA PLATA	JOSE MELCHOR ROMERO',
  'CENTRO DE SALUD INTEGRAL	CALLE 1 1505 E/63 Y 64	BUENOS AIRES	LA PLATA	LA PLATA',
  'CENTRO DE SALUD N° 41 DE LA PLATA	CALLE 84 ENTRE 131 Y 132	BUENOS AIRES	LA PLATA	LA PLATA',
  'CENTRO N° 42 DE LA PLATA	CALLE 149 ENTRE 35 Y 36	BUENOS AIRES	LA PLATA	LA PLATA',
  'HOSPITAL INTERZONAL GENERAL AGUDOS EVITA	Río de Janeiro 1910	BUENOS AIRES	LANÚS	VALENTIN ALSINA',
  'HOSPITAL LOCAL GENERAL AGUDOS DR. ARTURO MELO	Av. Villa de Luján 3050	BUENOS AIRES	LANÚS	LANUS ESTE',
  'UNIDAD SANITARIA 1° DE MAYO DE LANUS	SANCHEZ DE BUSTAMANTE 2355	BUENOS AIRES	LANÚS	LANUS ESTE',
  'HOSPITAL SUBZONAL GENERAL LAS FLORES	ABEL GUARESTI S/N	BUENOS AIRES	LAS FLORES	LAS FLORES',
  'HOSPITAL ZONAL GENERAL LOBOS	Dr. F. Mastropietro s/nº entre Chacabuco y Salgado	BUENOS AIRES	LOBOS	LOBOS',
  'UNIDAD SANITARIA DR. RAMON CARRILLO DE LOMAS DE ZAMORA	DARWIN 1835	BUENOS AIRES	LOMAS DE ZAMORA	VILLA FIORITO',
  'UNIDAD SANITARIA LA SALUD COMO DERECHO	PASAJE EVA PERON 2420	BUENOS AIRES	LOMAS DE ZAMORA	VILLA FIORITO',
  'UNIDAD SANITARIA NUEVO FIORITO	LARRAZABAL 2669	BUENOS AIRES	LOMAS DE ZAMORA	VILLA FIORITO',
  'UNIDAD SANITARIA VILLA GENERAL SAN MARTIN	ANCHORIS 3338	BUENOS AIRES	LOMAS DE ZAMORA	TEMPERLEY',
  'UNIDAD SANITARIA V° INDEPENDENCIA	BUSTOS 775	BUENOS AIRES	LOMAS DE ZAMORA	VILLA FIORITO',
  'UNIDAD SANITARIA SANTA MARIA DE JOSE MARIA JAUREGUI	TROPERO MOREIRA Y ESTRADA	BUENOS AIRES	LUJÁN	VILLA FLANDRIA SUR (EST. JAUREGUI)',
  'UNIDAD SANITARIA SANTO CRISTO	Gral Mosconi y Avda Muñiz	BUENOS AIRES	LUJÁN	CORTINES',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD OPEN DOOR	CORRIENTES ESQUINA SANTIAGO DEL ESTERO	BUENOS AIRES	LUJÁN	OPEN DOOR (EST. DR. DOMINGO CABRED) (OPEN DOOR)',
  'CENTRO DE MEDICINA PREVENTIVA Y SOCIAL EVA PERON	LAS HERAS 475	BUENOS AIRES	LUJAN	LUJAN',
  'CENTRO DE SALUD LA LOMA	LOS HELECHOS ESQUINA LOS TULIPANES S/N BARRIO LA LOMA	BUENOS AIRES	LUJÁN	LUJAN',
  'CENTRO PERIFERICO AMEGHINO	José Ingenieros y Ameghino	BUENOS AIRES	LUJÁN	LUJAN',
  'CENTRO PERIFERICO DE SALUD SANTA ELENA	SAN LORENZO Y CHAMPAGNAT S/N BARRIO SANTA ELENA	BUENOS AIRES	LUJÁN	LUJAN',
  'CIC SAN FERMIN	LOS ROSALES ENTRE LAS MADRESELVAS Y LOS LOTOS	BUENOS AIRES	LUJÁN	LUJAN',
  'UNIDAD SANITARIA BARRIO LOS LAURELES	LAS ESTRELLAS Y VENUS S/N BARRIO LOS LAURELES	BUENOS AIRES	LUJÁN	LUJAN',
  'UNIDAD SANITARIA LANUSSE	DR. LUPPI Y LA PLATA S/N BARRIO LANUSSE	BUENOS AIRES	LUJÁN	LUJAN',
  'UNIDAD SANITARIA LOS GALLITOS	33 Orientales y Pascual Simoni	BUENOS AIRES	LUJÁN	LUJAN',
  'HOSPITAL MUNICIPAL DE TRAUMA Y EMERGENCIAS DR. FEDERICO ALBERTO ABETE	MIRAFLORES 126	BUENOS AIRES	MALVINAS ARGENTINAS	PABLO NOGUES',
  'HOSPITAL ZONAL GENERAL DE AGUDOS HEROES DE MALVINAS	Avenida Doctor Ricardo Balbín 1910	BUENOS AIRES	MERLO	SAN ANTONIO DE PADUA',
  'UNIDAD SANITARIA N° 11 DE MERLO	AV. SAN MARTIN Y BARILOCHE	BUENOS AIRES	MERLO	MERLO',
  'HOSPITAL MARIANO Y LUCIANO DE LA VEGA	Avenida del Libertador 710	BUENOS AIRES	MORENO	PASO DEL REY',
  'MATERNIDAD DE MORENO ESTELA B. DE CARLOTTO	ALBATROS Nº7225 E/ BOULOGNE SUR MER Y M. V. MAZA	BUENOS AIRES	MORENO	MORENO',
  'CENTRO ASISTENCIAL JURAMENTO	JURAMENTO 1719 VILLA SALAS	BUENOS AIRES	MORENO	MORENO',
  'SALA CORTEZ	DEL CARRIL N° 4051 VILLA ZAPIOLA	BUENOS AIRES	MORENO	PASO DEL REY',
  'UNIDAD SANITARIA FLORENCIO MOLINA CAMPOS	JUANA DE IBARBOROU 9547	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA LAS FLORES DE MORENO	FEDERICO LACROZE 3376 BARRIO LAS FLORES	BUENOS AIRES	MORENO	TRUJUI',
  'UNIDAD SANITARIA LOMAS DE CASASCO	San Pablo 2286/74	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA MARTIN FIERRO DE MORENO	NAHUEL HUAPI 90 BARRIO AMPLIACION LA LOMITA	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA N° 4 LA FORTUNA DE MORENO	ENRIQUE LARRETA 10471	BUENOS AIRES	MORENO	TRUJUI',
  'UNIDAD SANITARIA SAMBRIZZI SANGUINETTI	CORRIENTES 2301 - BARRIO SANGUINETTI	BUENOS AIRES	MORENO	PASO DEL REY',
  'HOSPITAL NACIONAL PROFESOR DR. ALEJANDRO POSADAS	PTE. A ILLIA Y MARCONI	BUENOS AIRES	MORÓN	VILLA SARMIENTO',
  'HOSPITAL MUNICIPAL OSTACIANA B. DE LAVIGNOLE	Doctor Rodolfo Monte 848	BUENOS AIRES	MORÓN	VILLA SARMIENTO',
  'CENTRO DE SALUD MERCEDES SOSA	Eva Peron Esquina Baradero	BUENOS AIRES	MORÓN	MORON',
  'CENTRO DE SALUD SANTA LAURA	Gral. Cornelio Saavedra 1265 - Barrio Santa Laura	BUENOS AIRES	MORÓN	MORON',
  'UNIDAD SANITARIA DR. GELPI - BARRIO SAN JUAN	MIRÓ Y BETBEDER - CASTELAR SUR	BUENOS AIRES	MORÓN	CASTELAR',
  'UNIDAD SANITARIA DR. MONTE	GRITO DE ALCORTA 3500 - BARRIO BELGRANO	BUENOS AIRES	MORÓN	MORON',
  'UNIDAD SANITARIA MALVINAS ARGENTINAS DE HAEDO	MONOBLOCK 29 BARRIO CARLOS GARDEL	BUENOS AIRES	MORÓN	HAEDO',
  'UNIDAD SANITARIA PRESIDENTE IBAÑEZ	PRESIDENTE IBAÑEZ 1824 - BARRIO SAN JOSE	BUENOS AIRES	MORÓN	MORON',
  'CENTRO DE SALUD BARRIO 9 DE JULIO	CALLE 77 N° 4866 BARRIO NUEVE DE JULIO	BUENOS AIRES	NECOCHEA	NECOCHEA',
  'CENTRO DE SALUD PLAYA DR. CARLOS FUCILE	CALLE 8 N° 3863 - BARRIO PLAYA	BUENOS AIRES	NECOCHEA	NECOCHEA',
  'CENTRO DE SALUD BARRIO SUR	CALLE 77 N° 1865 e/ 42 y 44	BUENOS AIRES	NECOCHEA	NECOCHEA',
  'UNIDAD SANITARIA BARRIO SUDOESTE SR. DANIEL DIEZ	CALLE 81 Y 58 BARRIO SUDOESTE	BUENOS AIRES	NECOCHEA	NECOCHEA',
  'HOSPITAL MUNICIPAL DR. HECTOR M. CURA	RIVADAVIA 4057	BUENOS AIRES	OLAVARRIA	OLAVARRIA',
  'UNIDAD SANITARIA N° 21 DE LOMA NEGRA	1° DE MAYO 1458	BUENOS AIRES	OLAVARRÍA	LOMA NEGRA',
  'UNIDAD SANITARIA N° 22 VILLA MAILIN DE OLAVARRIA	LAS HERAS  VILLA MAILIN N° 4840	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 26 LOURDES DE OLAVARRIA	GRIMALDI LOURDES Nº 894	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 6 12 DE OCTUBRE	HIPOLITO YRIGOYEN 610 Y CALLE 13 - BARRIO 12 DE OCTUBRE	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 7 INDEPENDENCIA DE OLAVARRIA	PUYRREDON 1704	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS SAN JOSE DE PERGAMINO	Liniers 950	BUENOS AIRES	PERGAMINO	PERGAMINO',
  'CENTRO DE ATENCION PRIMARIA RAMON CARRILLO DE PERGAMINO	DEAN FUNES Y COSTA RICA BARRIO GUEMES	BUENOS AIRES	PERGAMINO	PERGAMINO',
  'UNIDAD SANITARIA VILLA ROSA	Serrano y Perón	BUENOS AIRES	PILAR	VILLA ROSA',
  'UNIDAD SANITARIA VILLA VERDE	Fragata Sarmiento 1349	BUENOS AIRES	PILAR	PILAR',
  'HOSPITAL DRA. CECILIA GRIERSON	Juan Bautista Alberdi 38	BUENOS AIRES	PRESIDENTE PERÓN	GUERNICA',
  'HOSPITAL ZONAL GENERAL AGUDOS DR. ISIDORO IRIARTE	Allison Bell 770	BUENOS AIRES	QUILMES	VILLA LA FLORIDA',
  'UNIDAD SANITARIA EVA PERON DE QUILMES OESTE	BLAS PARERA 2800	BUENOS AIRES	QUILMES	QUILMES OESTE',
  'HOSPITAL SUBZONAL ESPECIALIZADO MATERNO INFANTIL SAN FRANCISCO SOLANO	JOSE ANDRES LOPEZ 2100	BUENOS AIRES	QUILMES	SAN FRANCISCO SOLANO',
  'UNIDAD SANITARIA LA LOMA	MISIONES E/178 Y 179	BUENOS AIRES	QUILMES	BERNAL OESTE',
  'CIC MARIA EVA	Pampa 4326 E/ 172 Y 173	BUENOS AIRES	QUILMES	BERNAL OESTE',
  'UNIDAD SANITARIA LA RIVERA (N° 7 DE QUILMES)	De la Merced entre 19 Bis y 18 Bis	BUENOS AIRES	QUILMES	QUILMES',
  'UNIDAD SANITARIA SAN MARTIN DE QUILMES	CALLE 826 ENTRE 895 Y 896	BUENOS AIRES	QUILMES	SAN FRANCISCO SOLANO',
  'HOSPITAL MUNICIPAL SATURNINO UNZUE	Avenida 25 de Mayo 717	BUENOS AIRES	ROJAS	ROJAS',
  'CAPS BARRIO PROGRESO	V. Ceballos	BUENOS AIRES	ROJAS	ROJAS',
  'CENTRO DE SALUD N° 27 DE SAN FERNANDO - (1)	25 DE MAYO 2290 - SAN RAFAEL	BUENOS AIRES	SAN FERNANDO	SAN FERNANDO',
  'HOSPITAL SUBZONAL GENERAL DR. EMILIO RUFFA	25 de Mayo 1901	BUENOS AIRES	SAN PEDRO	SAN PEDRO',
  'HOSPITAL MUNICIPAL RAMON SANTAMARINA	General Paz 1400	BUENOS AIRES	TANDIL	TANDIL',
  'CENTRO DE SALUD BARRIO GENERAL BELGRANO	CHEVERRIER 347	BUENOS AIRES	TANDIL	TANDIL',
  'CENTRO DE SALUD COMUNITARIA SANTA RITA MAGGIORI	Calle las Animas 1848	BUENOS AIRES	TANDIL	TANDIL',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD E. OLIVERO	MISIONES Y LA PASTORA	BUENOS AIRES	TANDIL	TANDIL',
  'CENTRO DE SALUD COMUNITARIA LAS TUNITAS   (   TANDIL)	GRANADEROS 196	BUENOS AIRES	TANDIL	TANDIL',
  'CENTRO DE SALUD SAN CAYETANO	SAN FRANCISCO 2044	BUENOS AIRES	TANDIL	TANDIL',
  'UNIDAD SANITARIA N° 2 VILLA AGUIRRE DE TANDIL	DARRAGUEIRA 1722	BUENOS AIRES	TANDIL	TANDIL',
  'HOSPITAL ZONAL GENERAL AGUDOS MAGDALENA V. DE MARTINEZ	Avenida Constituyentes 395	BUENOS AIRES	TIGRE	GENERAL PACHECO',
  'CENTRO DE SALUD GENERAL PACHECO	Salta 550	BUENOS AIRES	TIGRE	GENERAL PACHECO',
  'CENTRO DE SALUD BENAVIDEZ	Alvear y Marabotto	BUENOS AIRES	TIGRE	BENAVIDEZ',
  'CAPS CANAL	Italia 105	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE SALUD LAS TUNAS Y A. DEL TALAR	SACRISTI Y MOSCONI	BUENOS AIRES	TIGRE	GENERAL PACHECO',
  'CENTRO DE SALUD N° 9 DIQUE LUJAN DE TIGRE	9 de Julio	BUENOS AIRES	TIGRE	BENAVIDEZ',
  'CENTRO DE SALUD RINCON DE MILBERG	Santa María N° 3000 esq.  Irala	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE SALUD RIO CARAPACHAY	RIO CARAPACHAY Y CANAL ORTIZ - ISLAS DEL DELTA	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE SALUD RIO CAPITAN	RIO CAPITAN 198 Y ARROYO TORO - ISLAS DEL DELTA	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD BELGRANO	General Belgrano 1661	BUENOS AIRES	TIGRE	DON TORCUATO ESTE',
  'CAPS TRONCOS DEL TALAR	Coronel Escalada 598	BUENOS AIRES	TIGRE	LOS TRONCOS DEL TALAR',
  'CENTRO DE ATENCION FAMILIAR Y DE SALUD JUANA MANSO	Avenida Agustin M. García 5960  - (Ex ruta provinc. 27)	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO MUNICIPAL DE SALUD DEL PARTIDO DE TRES ARROYOS (EX HOGAR DR. IGNACIO PIROVANO)	Primera Junta 400	BUENOS AIRES	TRES ARROYOS	TRES ARROYOS',
  'HOSPITAL ZONAL GENERAL DE AGUDOS DR. CARLOS BOCALANDRO	RUTA 8 KM 20.5 9100	BUENOS AIRES	TRES DE FEBRERO	CASEROS',
  'HOSPITAL MUNICIPAL PROFESOR DR. BERNARDO HOUSSAY	Hipólito Yrigoyen 1750/57	BUENOS AIRES	VICENTE LÓPEZ	FLORIDA',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD UAP RAVAZZOLI	Moldes 4900	BUENOS AIRES	VICENTE LÓPEZ	VILLA MARTELLI',
  'UNIDAD DE ATENCION PRIMARIA DR. B. AGUIRRE	STO. BAIGORRIA 2461	BUENOS AIRES	VICENTE LÓPEZ	MUNRO',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD URI DR. JOSE BURMAN	Ituzaingó 5725	BUENOS AIRES	VICENTE LÓPEZ	CARAPACHAY',
  'UNIDAD SANITARIA DR. ARTURO ILLIA DE OLIVOS	Cnel. Uzal 3244	BUENOS AIRES	VICENTE LÓPEZ	OLIVOS',
  'HOSPITAL GENERAL DE AGUDOS JOSE MARIA RAMOS MEJIA	GENERAL URQUIZA 609	CABA	COMUNA 3	BALVANERA',
  'HOSPITAL GENERAL DE AGUDOS P. PIÑERO	Avenida Varela 1301	CABA	COMUNA 7	FLORES',
  'HOSPITAL GENERAL DE AGUDOS BERNARDINO RIVADAVIA	AV. GENERAL LAS HERAS 2670	CABA	COMUNA 2	RECOLETA',
  'HOSPITAL GENERAL DE AGUDOS DALMACIO VELEZ SARSFIELD	PEDRO CALDERON DE LA BARCA 1550	CABA	COMUNA 10	MONTE CASTRO',
  'HOSPITAL GENERAL DE AGUDOS DONACION FRANCISCO SANTOJANNI	PILAR 950	CABA	COMUNA 9	LINIERS',
  'HOSPITAL GENERAL DE AGUDOS DR. COSME ARGERICH	CORBETA PI Y MARGAL 750	CABA	COMUNA 4	BOCA',
  'HOSPITAL GENERAL DE AGUDOS DR. CARLOS G. DURAND	AMBROSETTI 743	CABA	COMUNA 6	CABALLITO',
  'HOSPITAL GENERAL DE AGUDOS DR. IGNACIO PIROVANO	Monroe 3555	CABA	COMUNA 12	COGHLAN',
  'HOSPITAL GENERAL DE AGUDOS DR. TEODORO ALVAREZ	Aranguren 2701	CABA	COMUNA 7	FLORES',
  'HOSPITAL GENERAL DE AGUDOS DR. ABEL ZUBIZARRETA	NUEVA YORK 3952	CABA	COMUNA 11	VILLA DEVOTO',
  'HOSPITAL GENERAL DE AGUDOS DR. JUAN A. FERNANDEZ	Cerviño 3356	CABA	COMUNA 14	PALERMO',
  'HOSPITAL GENERAL DE AGUDOS JOSE A. PENNA	Doctor Profesor Pedro Chutro 3380	CABA	COMUNA 4	PARQUE PATRICIOS',
  'HOSPITAL GENERAL DE NIÑOS DR. RICARDO GUTIERREZ	Gallo 1330	CABA	COMUNA 2	RECOLETA',
  'HOSPITAL GENERAL DE NIÑOS PEDRO DE ELIZALDE	MANUEL A. MONTES DE OCA 40	CABA	COMUNA 4	BARRACAS',
  'CESAC 47	villa 31	CABA	COMUNA 1	RETIRO',
  'CESAC Nº 1	VELEZ SARSFIELD 1271	CABA	COMUNA 4	BARRACAS',
  'CESAC Nº 10	AMANCIO ALCORTA 1402	CABA	COMUNA 4	BARRACAS',
  'CESAC Nº 11	AGÜERO 940	CABA	COMUNA 3	BALVANERA',
  'CESAC Nº 12	OLAZABAL 3960	CABA	COMUNA 12	VILLA URQUIZA',
  'CESAC Nº 13	DIRECTORIO 4210	CABA	COMUNA 9	PARQUE AVELLANEDA',
  'CESAC Nº 14	HORACIO CASCO 4446	CABA	COMUNA 9	PARQUE AVELLANEDA',
  'CESAC Nº 15	HUMBERTO PRIMO 470	CABA	COMUNA 1	SAN TELMO',
  'CESAC Nº 16	OSVALDO CRUZ 2055	CABA	COMUNA 4	BARRACAS',
  'CESAC Nº 18	MIRALLA Y BATLE ORDOÑEZ	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 2	TERRADA 5850	CABA	COMUNA 12	VILLA PUEYRREDON',
  'CESAC Nº 21	AV, PREFECTURA NAVAL ARGENTINA 80 (DENTRO DE LA VILLA 31)	CABA	COMUNA 1	RETIRO',
  'CESAC Nº 22	Fragata Pte. Sarmiento 2152	CABA	COMUNA 15	CHACARITA',
  'CESAC Nº 24	CALLE L S/N° ENTRE M. CASTROY LAGUNA (VILLA FATIMA Y BARRIO CARRILLO)	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 27	ARIAS 3783	CABA	COMUNA 12	SAAVEDRA',
  'CESAC Nº 28	Santander 5955	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 3	SOLDADO DE LA FRONTERA 5144	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 30	AMANCIO ALCORTA E IGUAZU	CABA	COMUNA 4	NUEVA POMPEYA',
  'CESAC Nº 32	CHARRUA 2900	CABA	COMUNA 4	NUEVA POMPEYA',
  'CESAC Nº 33	CORDOBA 5741	CABA	COMUNA 14	PALERMO',
  'CESAC Nº 34	GENERAL JOSE G. ARTIGAS 2262	CABA	COMUNA 11	VILLA DEL PARQUE',
  'CESAC Nº 36	MERCEDES 1371/79	CABA	COMUNA 10	FLORESTA',
  'CESAC Nº 38	MEDRANO 350	CABA	COMUNA 5	ALMAGRO',
  'CESAC Nº 39	24 DE NOVIEMBRE 1679	CABA	COMUNA 4	PARQUE PATRICIOS',
  'CESAC Nº 4	ALBERDI Y PILAR - PLAZA ZALABERRY	CABA	COMUNA 9	MATADEROS',
  'CESAC Nº 40	ESTEBAN BONORINO 1729	CABA	COMUNA 7	FLORES',
  'CESAC Nº 41	MINISTRO BRIN 843	CABA	COMUNA 4	BOCA',
  'CESAC Nº 5	PIEDRABUENA 3140	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 6	MARIANO ACOSTA Y PRESIDENTE ROCA	CABA	COMUNA 8	VILLA SOLDATI',
  'CESAC Nº 7	2 DE ABRIL 1982 6850	CABA	COMUNA 8	VILLA LUGANO',
  'CESAC Nº 8	OSVALDO CRUZ 3485	CABA	COMUNA 4	BARRACAS',
  'CESAC Nº 9	IRALA 1254	CABA	COMUNA 4	BOCA',
  'CESAC Nº 25	MANZANA 33 BARRIO 31	CABA	COMUNA 1	RETIRO',
  'CESAC Nº 45	Cochabamba 2622	CABA	COMUNA 3	SAN CRISTOBAL',
  'CESAC Nº 35	Osvaldo Cruz 3600	CABA	COMUNA 4	BARRACAS',
  'CESAC Nº 44	SARAZA 4202 - Bº NAGERA	CABA	COMUNA 8	VILLA LUGANO',
  'HOSPITAL CECILIA GRIERSON - CENTRO DE SALUD INTEGRAL	Avenida General Fernández de la Cruz 4402	CABA	COMUNA 8	VILLA SOLDATI',
  'CESAC N°43	Fonrouge 4377	CABA	COMUNA 8	VILLA LUGANO',
  'HOSPITAL DEL BICENTENARIO GENERAL GUEMES	Avenida Güemes prolongación norte	CHACO	GENERAL GÜEMES	JUAN JOSE CASTELLI',
  'HOSPITAL MISION NUEVA POMPEYA	Avenida San Marcelino Champagnat	CHACO	GENERAL GÜEMES	NUEVA POMPEYA',
  'CENTRO DE SALUD BARRIO CURISHI	BARRIO CURISHI-CASTELLI	CHACO	GENERAL GÜEMES	JUAN JOSE CASTELLI',
  'HOSPITAL DR. SALVADOR MAZZA	STA JOSEFA ROSSELLO  356	CHACO	MAYOR LUIS J. FONTANA	VILLA ANGELA',
  'HOSPITAL DR. EMILIO FEDERICO RODRIGUEZ	ALMIRANTE BROWN 551	CHACO	QUITILIPI	QUITILIPI',
  'CENTRO DE SALUD VILLA RIO NEGRO	AVENIDA SABIN 75	CHACO	SAN FERNANDO	RESISTENCIA',
  'CENTRO DE SALUD RAMON CARRILLO PUERTO MADRYN	MARCOS DE AZAR N° 2250	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD PRIMITIVA AZCARATE	MARTIN RIVADAVIA S/N ACCESO ESCUELA 49	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CAPS ROQUE GONZALEZ DE PUERTO MADRYN	ESTIVARIZ N° 2484	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD INTEGRAL DE LA ADOLESCENCIA	Fontana y Don Bosco	CHUBUT	FUTALEUFÚ	ESQUEL',
  'HOSPITAL SUB ZONAL RAWSON - SANTA TERESITA	Roberto Jones 340	CHUBUT	RAWSON	RAWSON',
  'HOSPITAL ZONAL TRELEW DR. ADOLFO MARGARA	CALLE 28 DE JULIO 160	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD  LA LOMA	Ramón y Cajal N°160	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD PLANTA DE GAS	calle Jose Berreta S/N°	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD SARMIENTO	BEGHIN S/N ENTRE URUGUAY Y BUENOS AIRES	CHUBUT	RAWSON	TRELEW',
  'HOSPITAL NACIONAL EN RED ESPECIALIZADO EN SALUD MENTAL Y ADICCIONES - LICENCIADA LAURA BONAPARTE	Combate de los Pozos 2133	CABA	COMUNA 4	PARQUE PATRICIOS',
  'CAPS EBERTO TORRES (EX DISPENSARIO PUBLICO V° YACANTO)	AVENIDA JOSE MARRERO S/N° - RUTA PROVINCIAL 228 S/N° A 100 METROS DEL DESTACAMENTO POLICIAL	CORDOBA	CALAMUCHITA	VILLA YACANTO',
  'HOSPITAL UNIVERSITARIO DE MATERNIDAD Y NEONATOLOGIA (H.U.M.N.)	RODRIGUEZ PEÑA 285	CORDOBA	CAPITAL	CORDOBA',
  'CAPS CIUDAD DE LOS CUARTETOS	BARRIO CIUDAD DE LOS CUARTETOS LOTE 16 MANZANA 34	CORDOBA	CAPITAL	CORDOBA',
  'CAPS CIUDAD VILLA RETIRO	BARRIO CIUDAD VILLA RETIRO - MANZANA 14	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 4 - BARRIO NUEVA ITALIA	José de Quevedo s/n esq. Dos Barrios	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 13 - BARRIO HIPOLITO YRIGOYEN	AVELLANEDA 3571	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 25 - BARRIO SAN MARTIN	USPALLATA 991	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 32 - BARRIO PARQUE LICEO III SECC.	Juan Luis Orrego esq. Constancio Vigil	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 63 - BARRIO PARQUE REPUBLICA	Namuncurá esq. Rosas	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 62 - VILLA CORNU	LLANQUEN 9400	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 7 - BARRIO PUEYRREDON	Pje. Urtybey esq. faray Bracco	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 8 - BARRIO ACOSTA	Corrientes 4309 esq. Río Paraná	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 21 - BARRIO BAJO GRANDE	CAMINO CHACRA DE LA MERCED KM 6.5	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 5 - BARRIO GRAL. ARENALES	la Pirincha esq. El Crispin - B° General Arenales	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 27 - BARRIO VILLA RIVADAVIA	CAMINO A SAN ANTONIO KM 8.5	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 40 - BARRIO LAS FLORES	AVENIDA ARMADA ARGENTINA 105	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 31 - BARRIO LA SALLE	CURAQUEN 6500	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N°60 - BARRIO MARQUEZ ANEXO	Del Molino esq. Del Precursor	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 18 - BARRIO VILLA ALLENDE PARQUE	Calle 15 entre 18 y 19	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 53 - BARRIO INAUDI	Pasaje Teniente Nivoli (al lado del precinto)	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 15 - BARRIO ALBERT SABIN	CAMINO SAN ANTONIO KM 7.5	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 33 - BARRIO ARGUELLO	AVENIDA DONATO ALVAREZ 7375	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 16 - BARRIO ZUMARAN	SEBASTIAN GABOTO 2356	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 61 - BARRIO EL CERRITO	MARIO SESSEREGO ESQ DOMINGO MARIMAN	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 52 - BARRIO VILLA URQUIZA	HUMBERTO PRIMO 4884	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 46 - BARRIO SANTA ISABEL	Altos del Tala s/n	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 36 - BARRIO CABILDO	Av. Colorado esq. macachín	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 41 - BARRIO VILLA EL LIBERTADOR	CHICLAYO 150	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 34 LOS NOGALES - BARRIO 9 DE JULIO	COQUENA 7892 ESQ HUARPES	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 26 - BARRIO LA MADRID	GURRUCHAGA 785	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 1 - BARRIO SAN ROQUE	Av. Kingsley  esq.Tappia	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 2 - BARRIO 16 DE NOVIEMBRE	José María Rosa 8500 esq. Onofre Marimon	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 23 - BARRIO VILLA EL LIBERTADOR	BARRANQUILLAS 5700	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 30 - BARRIO LOS CORTADEROS	De los Polacos 7500 y Canal Norte	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 59 - BARRIO CONGRESO	Av. curazao esq. Ralico	CORDOBA	CAPITAL	CORDOBA',
  'UPAS N° 12 - BARRIO VILLA UNION	Atilio Cataneo y Tres Cruces s/n	CORDOBA	CAPITAL	CORDOBA',
  'CENTRO DE SALUD N° 14 - GENERAL BUSTOS	DIAGONAL ICA 990	CORDOBA	CAPITAL	CORDOBA',
  'DISPENSARIO MUNICIPAL AGUA DE ORO	SAN MARTIN  s/n	CORDOBA	COLÓN	AGUA DE ORO',
  'CENTRO DE SALUD RAMON CARRILLO MI GRANJA	20 DE JUNIO LOTE 3 MANZANA D	CORDOBA	COLÓN	MI GRANJA',
  'CENTRO DE ATENCION PRIMARIA DE SALUD CABANA	Avenida 5 de Octubre S/N	CORDOBA	COLÓN	UNQUILLO',
  'CENTRO DE INTEGRACION COMUNAL DE VILLA DE SOTO	AVENIDA 25 DE MAYO 220	CORDOBA	CRUZ DEL EJE	VILLA DE SOTO',
  'DISPENSARIO COLINAS DE MALLIN	PRESIDENTE PERON 559	CORDOBA	PUNILLA	COSQUIN',
  'CENTRO DE SALUD BARRIO COLINAS	LINIERS 50	CORDOBA	PUNILLA	VILLA CARLOS PAZ',
  'DISPENSARIO NESTOR MACHADO	RUTA PROVINCIAL 56 S/N°	CORDOBA	SANTA MARÍA	VILLA SAN ISIDRO  (VILLA SAN ISIDRO )',
  'HOSPITAL ANGELA IGLESIA DE LLANO	AYACUCHO 3288	CORRIENTES	CAPITAL	CORRIENTES',
  'HOSPITAL JOSE RAMON VIDAL (CAPITAL)	Necochea 1050	CORRIENTES	CAPITAL	CORRIENTES',
  'SALA JUAN XXIII	Cabo Gómez y Marambio	CORRIENTES	GOYA	GOYA',
  'HOSPITAL REGIONAL DE GOYA PROF. DR. CAMILO MUNIAGURRIA	AV. TOMAS MAZZANTI 550	CORRIENTES	GOYA	GOYA',
  'CAPS VILLA VITAL	PUEYRREDON 182	CORRIENTES	GOYA	GOYA',
  'C.A.P.S.   MEDALLA MILAGROSA	GONZALEZ 306	ENTRE RIOS	COLÓN	COLON',
  'CENTRO DE SALUD Nº 5 - MEDANOS	MARTINEZ PAIVA 2360	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD Nº 3 - VILLA MARIA	MARTIN GÜEMES 1160 (Y FLEMIN)	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD SAN ISIDRO	CORDOBA 860	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'DISPENSARIO Nº 1 - PUEBLO NUEVO	BELISARIO ROLDAN 830	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'HOSPITAL MATERNO INFANTIL SAN ROQUE	La Paz 435	ENTRE RIOS	PARANÁ	PARANA',
  'CASA DE PIEDRA	CALLE GUEMES FRENTE A HOSPITAL PABLO SORIA	JUJUY	DOCTOR MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS BELGRANO (1)	JUANITA MORO 560 - BARRIO BELGRANO	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS LOS HUAICOS (1)	LUCIA RUEDA 55 - BARRIO LOS HUAICOS	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'HOSPITAL NUESTRA SEÑORA DEL CARMEN (5)	MITRE 686 B° Centro	JUJUY	EL CARMEN	EL CARMEN',
  'PUESTO SAN VICENTE (22)	RUTA N° 42 (ESCUELA N° 54)	JUJUY	EL CARMEN	MONTERRICO  (MONTERRICO)',
  'HOSPITAL PRESBITERO ESCOLASTICO ZEGADA (10)	BELGRANO Y SENADOR PEREZ S/N	JUJUY	LEDESMA	FRAILE PINTADO',
  'CAPS EJERCITO DEL NORTE (7)	AVENIDA 7 DE NOVIEMBRE ESQUINA EXODO JUJEÑO	JUJUY	SAN PEDRO	SAN PEDRO',
  'CIC NUEVA CIUDAD (7)	av. jerico s/n barrio fellner	JUJUY	SAN PEDRO	SAN PEDRO',
  'CIC MAIMARA (EX CAPS SAN PEDRITO) (16)	SOBRE EX RUTA 9 B° SAN PEDRITO	JUJUY	TILCARA	MAIMARA',
  'CAPS TUMBAYA (16)	ALVAREZ PRADO S/N°	JUJUY	TUMBAYA	TUMBAYA',
  'RIO ATUEL	VIVAS 2431	LA PAMPA	CAPITAL	SANTA ROSA',
  'HOSPITAL COMUNITARIO EVITA	FERRANDO 2295	LA PAMPA	CAPITAL	SANTA ROSA',
  'VILLA PARQUE	QUEMU QUEMU 1942	LA PAMPA	CAPITAL	SANTA ROSA',
  'ESTABLECIMIENTO ASISTENCIAL AMADA GATICA	BELGRANO 318	LA PAMPA	CATRILÓ	CATRILO',
  'ESTABLECIMIENTO ASISTENCIAL DR. PABLO LECUMBERRY	Nuñez 447	LA PAMPA	CATRILÓ	LONQUIMAY',
  'ESTABLECIMIENTO ASISTENCIAL DRA. CECILIA GRIERSON	AV. SAN MARTIN 766	LA PAMPA	LOVENTUÉ	TELEN',
  'FRANK ALAN	CALLE 34 ENTRE 1 Y 101	LA PAMPA	MARACÓ	GENERAL PICO',
  'GUILLERMO BROWN	CALLE 9 814 OESTE	LA PAMPA	MARACÓ	GENERAL PICO',
  'ESTABLECIMIENTO ASISTENCIAL WILFRID BARON	DON BOSCO 994	LA PAMPA	QUEMÚ QUEMÚ	COLONIA BARON',
  'HOSPITAL REGIONAL ENRIQUE VERA BARROS - CAPITAL	Olta y Madre Teresa de Calcuta	LA RIOJA	CAPITAL	LA RIOJA',
  'HOSPITAL DE LA MADRE Y EL NIÑO (LA RIOJA) - CAPITAL	CALLE 1 DE MARZO	LA RIOJA	CAPITAL	LA RIOJA',
  'CAPS BENJAMIN RINCON	Chile e Independencia	LA RIOJA	CAPITAL	LA RIOJA',
  'SAN VICENTE	AVENIDA OYOLA Y PAMPLONA	LA RIOJA	CAPITAL	LA RIOJA',
  'CAPS VIRGEN DE LOS CERROS	CALLE 8 Y COSTANERA NORTE	LA RIOJA	CAPITAL	LA RIOJA',
  'CAPS OFELIA BAZAN DE LOZADA (NUEVO ARGENTINO)	La Pampa y Viedma, B° Nuevo Argentino	LA RIOJA	CAPITAL	LA RIOJA',
  'CAPS SAN MARTIN	CALLE DEL CARMEN Y SAN JUAN S/N	LA RIOJA	CAPITAL	LA RIOJA',
  'HOSPITAL LUIS C. LAGOMAGGIORE.-	TIMOTEO GORDILLO S/N	MENDOZA	CAPITAL	7A. SECCION',
  'HOSPITAL ENFERMEROS ARGENTINOS.-	EMILIO CIVIT 400	MENDOZA	GENERAL ALVEAR	GENERAL ALVEAR',
  'HOSPITAL LUIS CHRABALOWSKI.-	CERRO ACONCAGUA Y CERRO TUPUNGATO	MENDOZA	LAS HERAS	USPALLATA',
  'HOSPITAL HECTOR E. GAILHAC.-	ARISTOBULO DEL VALLE 1359	MENDOZA	LAS HERAS	EL ALGARROBAL',
  'HOSPITAL RAMON CARRILLO.-	MARTÍN FIERRO 1724	MENDOZA	LAS HERAS	EL RESGUARDO',
  'HOSPITAL DIEGO PAROISSIEN.-	GODOY CRUZ T. 475	MENDOZA	MAIPÚ	MAIPU',
  'HOSPITAL REGIONAL MALARGUE.-	AVENIDA GENERAL ROCA Y ESQUIVEL ALDAO	MENDOZA	MALARGÜE	MALARGUE',
  'HOSPITAL VICTORINO TAGARELLI.-	CONSTITUCIÓN S/N	MENDOZA	SAN CARLOS	EUGENIO BUSTOS',
  'HOSPITAL ALFREDO I. PERRUPATO.-	RUTA PROVINCIAL 50 Y ABDALA	MENDOZA	SAN MARTÍN	CIUDAD DE SAN MARTIN',
  'HOSPITAL TEODORO J. SCHESTAKOW.-	COMANDANTE TORRES 150	MENDOZA	SAN RAFAEL	SAN RAFAEL  (CIUDAD DE SAN RAFAEL)',
  'HOSPITAL ANTONIO J. SCARAVELLI.-	MARTIN MIGUEL DE GUEMES 1441	MENDOZA	TUNUYÁN	TUNUYAN',
  'HOSPITAL GREGORIO LAS HERAS.-	LAS HERAS Y MONSEÑOR FERNÁNDEZ	MENDOZA	TUPUNGATO	TUPUNGATO',
  'HOSPITAL DE CAMPO GRANDE - NIVEL I	PASTEUR Y REPUBLICA ARGENTINA	MISIONES	CAINGUÁS	CAMPO GRANDE',
  'C.A.P.S. Nº 23 SAN LORENZO - LA NUEVA ESPERANZA - EBY A4	Barrio Nueva Esperanza- diagonal 59 y avenida fangio	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'HOSPITAL CHOS MALAL - DR. GREGORIO ALVAREZ	AVENIDA ESTANISLAO FLORES 650	NEUQUEN	CHOS MALAL	CHOS MALAL',
  'CENTRO DE SALUD TIRO FEDERAL	JORGE NEWBERY S/Nº Y BELGRANO	NEUQUEN	CHOS MALAL	CHOS MALAL',
  'HOSPITAL TRICAO MALAL	VOLCAN TROMEN S/N	NEUQUEN	CHOS MALAL	TRICAO MALAL',
  'HOSPITAL CENTENARIO - DR. NATALIO BURD	AV. LIBERTADOR 700	NEUQUEN	CONFLUENCIA	CENTENARIO',
  'HOSPITAL PROVINCIAL NEUQUEN - DR. EDUARDO CASTRO RENDON	BUENOS AIRES 450	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD MARIANO MORENO	VERZEGNASSI  226	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD BOUQUET ROLDAN	MINISTRO AMANCIO ALCORTA 1000	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD CONFLUENCIA	TANDIL 598	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD SAPERE	PRINCIPAL	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD VILLA FLORENCIA	Intendente Mango 934	NEUQUEN	CONFLUENCIA	NEUQUEN',
  'CENTRO DE SALUD PRIMEROS POBLADORES	MENDOZA 336, Junín de los Andes	NEUQUEN	HUILICHES	JUNIN DE LOS ANDES',
  'CENTRO DE SALUD VEGA MAIPU	Hugo Berbel entre Koessler y Alvarez	NEUQUEN	LÁCAR	SAN MARTIN DE LOS ANDES',
  'CENTRO DE SALUD VILLA TRAFUL	RUTA PROVINCIAL 65 KM 35 ESQUINA LAFITTE	NEUQUEN	LOS LAGOS	VILLA TRAFUL',
  'CENTRO DE SALUD LAS PIEDRITAS	Las Fucsias 431	NEUQUEN	LOS LAGOS	VILLA LA ANGOSTURA',
  'HOSPITAL ANDACOLLO - DR. ANTONIO GORGNI	GOBERNADOR FELIPE SAPAG S/N	NEUQUEN	MINAS	ANDACOLLO',
  'HOSPITAL LAS OVEJAS	GORNI S/N	NEUQUEN	MINAS	LAS OVEJAS',
  'HOSPITAL EL CHOLAR	AVENIDA GÜEMES S/N	NEUQUEN	ÑORQUÍN	EL CHOLAR',
  'CENTRO DE SALUD BARRIO LA COSTA	RITA GUZMAN S/Nº	NEUQUEN	PEHUENCHES	RINCON DE LOS SAUCES',
  'HOSPITAL BAJADA DEL AGRIO	AV. 25 DE MAYO S/N	NEUQUEN	PICUNCHES	BAJADA DEL AGRIO',
  'CENTRO DE SALUD CIC CALEUCHE	Perito Moreno y Libertad, Zapala	NEUQUEN	ZAPALA 	ZAPALA',
  'HOSPITAL AREA PROGRAMA LOS MENUCOS	Avenida San Martín 456	RIO NEGRO	25 DE MAYO	LOS MENUCOS',
  'CAPS BARRIO SAN JOSE	JACOBACCI S/N°	RIO NEGRO	25 DE MAYO	INGENIERO JACOBACCI',
  'HOSPITAL AREA PROGRAMATICA RAMOS MEXIA	Belgrano y 25 de Mayo  S/N	RIO NEGRO	9 DE JULIO	MINISTRO RAMOS MEXIA',
  'HOSPITAL AREA PROGRAMA CHIMPAY	Don Bosco S/N	RIO NEGRO	AVELLANEDA	CHIMPAY',
  'HOSPITAL AREA PROGRAMA CHOELE CHOEL	Avenida Gral San Martín 1326	RIO NEGRO	AVELLANEDA	CHOELE CHOEL',
  'HOSPITAL AREA PROGRAMA CORONEL BELISLE	Avenida Pablo Belisle S/N	RIO NEGRO	AVELLANEDA	CORONEL BELISLE',
  'CENTRO DE SALUD BARRIO ESPERANZA	BARRIO ESPERANZA	RIO NEGRO	BARILOCHE	EL BOLSON',
  'CENTRO DE SALUD BARRIO LUJAN	CALLE PRINCIPAL DEL BARRIO S/N°	RIO NEGRO	BARILOCHE	EL BOLSON',
  'CENTRO DE SALUD BARRIO USINA	AVENIDA DEL LIBERTADOR	RIO NEGRO	BARILOCHE	EL BOLSON',
  'CENTRO DE SALUD COSTA DEL RIO AZUL	MALLIN AHOGADO	RIO NEGRO	BARILOCHE	EL BOLSON',
  'CENTRO DE SALUD DR. DANIEL BARABINO - EX DINA HUAPI	LAS AMAPOLAS S/N° Y ROSAS	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD LOS ARRAYANES	MAITENES 845	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD MADRE TERESA DE CALCUTA	AVENIDA BUSTILLO KM 20	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD SAN FRANCISCO (DE BARRIO IPPV)	AVENIDA SAN MARTIN 750	RIO NEGRO	BARILOCHE	EL BOLSON',
  'CENTRO DE SALUD VIRGEN MISIONERA	TEJADA GOMEZ 7120	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD HABANA	Barrio Habana	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE SALUD PILAR II	Barrio Pilar II	RIO NEGRO	BARILOCHE	SAN CARLOS DE BARILOCHE',
  'CENTRO DE INTEGRACION COMUNITARIA	Los Cipreses y Primavera	RIO NEGRO	BARILOCHE	EL BOLSON',
  'HOSPITAL AREA PROGRAMA CINCO SALTOS	Martín Fierro 845 cinco saltos	RIO NEGRO	GENERAL ROCA	CINCO SALTOS',
  'CENTRO DE SALUD BARRIO DON BOSCO (VILLA REGINA)	PRIMEROS POBLADORES Y C. SALESIANOS	RIO NEGRO	GENERAL ROCA	VILLA REGINA',
  'CENTRO DE SALUD CONTRAALMIRANTE CORDERO - CINCO SALTOS	AUCA MAHUIDA 100	RIO NEGRO	GENERAL ROCA	CINCO SALTOS',
  'CENTRO DE SALUD J. J. GOMEZ	TUCUMAN 5500 E IRENE NEYRA	RIO NEGRO	GENERAL ROCA	GENERAL ROCA',
  'CENTRO DE SALUD LA ARMONIA	LAGO PELLEGRINI	RIO NEGRO	GENERAL ROCA	CINCO SALTOS',
  'CENTRO DE SALUD LA RIVERA	PRIMEROS POBLADORES S/N°	RIO NEGRO	GENERAL ROCA	GENERAL ROCA',
  'CENTRO DE SALUD PUENTE 83	RUTA 151 (RUTA CHICA) S/N°	RIO NEGRO	GENERAL ROCA	CIPOLLETTI',
  'CENTRO DE SALUD VILLA CATALINA	RIO SALADO S/N°	RIO NEGRO	GENERAL ROCA	CINCO SALTOS',
  'CENTRO DE SALUD 250 VIVIENDAS	PARANA 2481	RIO NEGRO	GENERAL ROCA	GENERAL ROCA',
  'HOSPITAL AREA PROGRAMA CHICHINALES	EL FORTIN Y PROCERES ARGENTINOS	RIO NEGRO	GENERAL ROCA	CHICHINALES',
  'PUESTO SANITARIO CHACRA MONTE	ISMAEL BASSE ENTRE LAS JARILLAS Y LAS RETAMAS	RIO NEGRO	GENERAL ROCA	GENERAL ROCA',
  'HOSPITAL AREA PROGRAMA CIPOLLETTI DR. PEDRO MOGUILLANSKY	Naciones Unidas 1550	RIO NEGRO	GENERAL ROCA	CIPOLLETTI',
  'HOSPITAL AREA PROGRAMA ÑORQUINCO	Ex Ruta 40 S/N - Manzana 525 S/N - Lote 1	RIO NEGRO	ÑORQUINCÓ	ÑORQUINCO',
  'HOSPITAL AREA PROGRAMA COMALLO	Libertad y Carlos Nehin S/N	RIO NEGRO	PILCANIYEU	COMALLO',
  'HOSPITAL AREA PROGRAMA LAS GRUTAS	RIO NEGRO 697	RIO NEGRO	SAN ANTONIO	LAS GRUTAS',
  'HOSPITAL AREA PROGRAMA SIERRA GRANDE	Av. Antártida Argentina y Av. Los Mineros S/N	RIO NEGRO	SAN ANTONIO	SIERRA GRANDE',
  'HOSPITAL AREA PROGRAMA VALCHETA	Leandro N. Alem S/N	RIO NEGRO	VALCHETA	VALCHETA',
  'CENTRO DE SALUD Nº 59 DR. ADOLFO TROYANO - PALMERITAS	EL CHAÑAR S/N° MANZANA A 109 - VILLA PALMERITAS	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 24 VILLA SAN LORENZO	AVENIDA SAN MARTIN ESQUINA AVENIDA J. C. DAVALOS	SALTA	CAPITAL	VILLA SAN LORENZO',
  'CENTRO DE SALUD Nº 31 - VILLA COSTANERA	CORONEL MOLDES Y ABRAHAM CORNEJO	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 39 - VILLA LUJAN	DIEGO DIEZ GOMEZ 1100 ESQUINA 12 DE OCTUBRE - VILLA LUJAN	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 42 - BARRIO EL AUTODROMO	Avenida Asunción 1800	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 56 - BARRIO PALERMO	MANZANA 436 - BARRIO PALERMO I	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 6 - BARRIO EL MANJON	AVENIDA ARTIGAS 900 - ESQUINA ITALIA	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 60 - BARRIO EL MIRADOR	AMADO MORON GIMENEZ 400	SALTA	CAPITAL	SALTA',
  'CENTRO DE SALUD Nº 63 - LA MADRE Y EL NIÑO	AVENIDA SARMIENTO 655	SALTA	CAPITAL	SALTA',
  'HOSPITAL DR. A. FERNANDEZ	AV. BELGRANO Y ALBERDI S/Nº	SALTA	MOLINOS	MOLINOS',
  'HOSPITAL EVA PERON	SAN MARTÍN ESQ. 20 DE FEBRERO	SALTA	ORÁN	HIPOLITO YRIGOYEN',
  'HOSPITAL PUBLICO DE GESTION DESCENTRALIZADA DR. GUILLERMO RAWSON	AVENIDA RAWSON SUR 494	SAN JUAN	CAPITAL	SAN JUAN',
  'CAPS BARRIO ARAMBURU	PLUMERILLO Y BAZAN AGRAS - PAULA ALBARRACIN OESTE - BARRIO ARAMBURU	SAN JUAN	RIVADAVIA	RIVADAVIA',
  'CAPS JUAN JORBA	PRINGLES s/n	SAN LUIS	GENERAL PEDERNERA	JUAN JORBA',
  'MATERNIDAD PROVINCIAL DOCTORA TERESITA BAIGORRIA	Intersección de las Rutas del Potezuelo y Ruta Provincial Nº 3	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CAPS JUANA KOSLAY	AV. DEL VIENTO CHORRILLERO S/N - RUTA 20 Y 24 DE SEPTIEMBRE - JUANA KOSLAY	SAN LUIS	LA CAPITAL	CRUZ DE PIEDRA',
  'HOSPITAL DISTRITAL PUERTO DESEADO	España 991	SANTA CRUZ	DESEADO	PUERTO DESEADO',
  'HOSPITAL DISTRITAL DR. BENIGNO FERNANDEZ	28 de Noviembre y Azcuenaga	SANTA CRUZ	DESEADO	LAS HERAS',
  'HOSPITAL REGIONAL RIO GALLEGOS	JOSÉ INGENIEROS 98	SANTA CRUZ	GÜER AIKE	RIO GALLEGOS',
  'CENTRO DE SALUD Nº 1	Pasteur y Perito Moreno	SANTA CRUZ	GÜER AIKE	RIO GALLEGOS',
  'CENTRO INTEGRADOR COMUNITARIO PADRE CARLOS MUGICA	Avenida Gendarmería Nacional 1105	SANTA CRUZ	GÜER AIKE	YACIMIENTOS RIO TURBIO',
  'CENTRO DE SALUD BARRIO CERRO CALAFATE	MAESTRO LANG Y SONIA SIMUNOVICH	SANTA CRUZ	LAGO ARGENTINO	EL CALAFATE',
  'UNIDAD COMUNITARIA DE SALUD FAMILIAR DR. JOSE FORMENTI	Julio A. Roca 1487	SANTA CRUZ	LAGO ARGENTINO	EL CALAFATE',
  'SAMCO DR. JAIME FERRE	Lisandro de la Torre 737	SANTA FE	CASTELLANOS	RAFAELA',
  'SAMCO DR AMILCAR GOROSITO	Avenida Belgrano 332	SANTA FE	CASTELLANOS	SUNCHALES',
  'CENTRO DE SALUD BARRIO FRANCUCCI	CALLE 54 Nº 270	SANTA FE	CASTELLANOS	FRONTERA',
  'CENTRO DE SALUD BARRIO VILLANI	CALLE 100 7	SANTA FE	CASTELLANOS	FRONTERA',
  'CENTRO DE SALUD N° 1 - RAFAELA	FRANCIA S/N° ENTRE S.T ZAFFETTI Y PETERLIN	SANTA FE	CASTELLANOS	RAFAELA',
  'SAMCO CAYASTA	Alvaro Gil S/N	SANTA FE	GARAY	CAYASTA',
  'SAMCO SANTA ROSA DE CALCHINES	Córdoba 420	SANTA FE	GARAY	SANTA ROSA DE CALCHINES',
  'CENTRO DE SALUD LOS ZAPALLOS	ZONA RURAL - LOS ZAPALLOS	SANTA FE	GARAY	LOS ZAPALLOS',
  'HOSPITAL  DR. ALEJANDRO GUTIERREZ DE VENADO TUERTO	Santa Fe 1311	SANTA FE	GENERAL LÓPEZ	VENADO TUERTO',
  'CENTRO DE SALUD POSTA SANITARIA DON CARLOS	CALLE 127 ESQUINA CALLE 72 BARRIO DON CARLOS	SANTA FE	GENERAL OBLIGADO	RECONQUISTA',
  'CENTRO DE SALUD BARRIO CHAPERO	ROCA 2023	SANTA FE	GENERAL OBLIGADO	RECONQUISTA',
  'CENTRO DE SALUD BARRIO EL OMBUSAL - EMA BEATRIZ CABRAL	Brown y Chacabuco	SANTA FE	GENERAL OBLIGADO	RECONQUISTA',
  'CENTRO DE SALUD GUADALUPE NORTE	Zona Urbana	SANTA FE	GENERAL OBLIGADO	GUADALUPE NORTE',
  'CENTRO DE SALUD BARRIO LA CORTADA	Constituyente y Patricio Diez - Manzana A	SANTA FE	GENERAL OBLIGADO	RECONQUISTA',
  'CENTRO DE SALUD BARRIO LA LOMA	CALLE 105	SANTA FE	GENERAL OBLIGADO	RECONQUISTA',
  'CENTRO DE SALUD PUERTO RECONQUISTA	RN A0009	SANTA FE	GENERAL OBLIGADO	PUERTO RECONQUISTA',
  'SAMCO DR. NANZER	Azcuégana (3500)	SANTA FE	LA CAPITAL	SANTO TOME',
  'HOSPITAL PROTOMEDICO MANUEL RODRIGUEZ	Ruta Provincial 5 KM 2.5	SANTA FE	LA CAPITAL	CAMPO CRESPO',
  'HOSPITAL DR. JOSE BERNARDO ITURRASPE	Beruti 5650	SANTA FE	LA CAPITAL	SANTA FE',
  'HOSPITAL GENERAL POLIVALENTE DR. MIRA Y LOPEZ	Blas Parera 8430	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD BARRIO VILLA HIPODROMO	Blas Parera 6110	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD FONAVI BARRIO CENTENARIO	LIBERTAD 3730	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD N° 9 BARRIO NUEVA POMPEYA	AVENIDA VERA PEÑALOZA 8280	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD PADRE COBO	PEDRO DE VEGA 3800	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD CONSTITUYENTES (EX VILLA LAURA)	CALLE 6 S/N°	SANTA FE	LA CAPITAL	VILLA LAURA',
  'CIC ROCA 29 DE ABRIL	REPUBLICA DE SIRIA Y CALLEJON ROCA	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD POLICLINICO VECINAL	SALVADOR DEL CARRIL 2240	SANTA FE	LA CAPITAL	SANTA FE',
  'CS CORONEL DORREGO	French y Sarmiento	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD ABASTO	Calle Abipones 10200	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD ALTOS DE NOGUERAS	LAMADRID 10590 (esquina Pasaje Malaver)	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD ANGEL GALLARDO	Dr ANGEL GALLARDO 1700 (entre calles  Los Inmigrantes y Pte. Perón)	SANTA FE	LA CAPITAL	ANGEL GALLARDO',
  'CENTRO DE SALUD ARROYO AGUIAR	AVENIDA SAN MARTIN 46	SANTA FE	LA CAPITAL	ARROYO AGUIAR',
  'CENTRO DE SALUD BARRIO ACERIA	MATHEU 6250 (entre Beck Bernard y Jacinto Viñas al 8100)	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD BARRIO CABAL	PASAJE LEIVA 6750 (CRUZANDO AVENIDA BLAS PARERA HACIA EL OESTE)	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD BARRIO CANDIOTI	BOULEVARD GALVEZ 1563	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD POLICLINICO BARRIO CENTENARIO	Pietranera  3164	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD BARRIO CHALET	Roberto Arl 3941	SANTA FE	LA CAPITAL	SANTA FE',
  'SAMCO BARRIO EL POZO	ALEJANDRO GRECA 1117 (MANZANA 19) AL LADO DE LA COMISARIA	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD BARRIO MENDOZA OESTE	MENDOZA 4519	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD DRA. GRISELDA MERATTI - BARRIO SUDOESTE	INDEPENDENCIA 2641	SANTA FE	LA CAPITAL	LAGUNA PAIVA',
  'CENTRO DE SALUD BARRIO YAPEYU	12 DE OCTUBRE 9740	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD CANDIOTI	Belgrano 1055 -- Candioti	SANTA FE	LA CAPITAL	CANDIOTI',
  'CENTRO DE SALUD COLASTINE SUR	Colastine Sur S/N	SANTA FE	LA CAPITAL	COLASTINE SUR',
  'CENTRO DE SALUD CRISTO OBRERO	PADRE CATENA 4389 - VILLA DEL PARQUE	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD DEMETRIO GOMEZ	Demetrio Gomez -Manz.7 - Alto Verde (entre Angel Martinez e Ignacio Monzón)	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD EMAUS - SANTA FE	ZAVALIA 342	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD EVA DUARTE DE PERON - SANTO TOME	CORDOBA Y NECOCHEA - BARRIO EL CHAPARRAL	SANTA FE	LA CAPITAL	SANTO TOME',
  'CENTRO DE SALUD EVITA BARRIO LA FLORIDA	ROQUE SAENZ PEÑA 2022	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD FONAVI BARRIO LAS FLORES II	LAMADRID 7689	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD GUADALUPE CENTRAL PADRE TRUCCO	JAVIER DE LA ROSA 1055	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD GUTIERREZ ESTE	AVELLANEDA 4800	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD LA BOCA - RAMON RIVERO	RAMON RIVERO- MANZANA 9 - ALTO VERDE	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD MONTE VERA	GENERAL LOPEZ 5718	SANTA FE	LA CAPITAL	MONTE VERA',
  'CENTRO DE SALUD QUILMES	FRANCIA 4020	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD RECREO	Caferata 907 (esquina Av. Mitre)	SANTA FE	LA CAPITAL	RECREO',
  'CENTRO DE SALUD SAN AGUSTIN - LA CAPITAL	CCORONEL LOZA 7100	SANTA FE	LA CAPITAL	SANTA FE',
  'SAMCO SAN JOSE DEL RINCON	BUSANICHE Y SAN MARTIN	SANTA FE	LA CAPITAL	SAN JOSE DEL RINCON',
  'CENTRO DE SALUD SETUBAL	RIOBAMBA Y FRENCH	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD LAS LOMAS	Camino Viejo a Esperanza 7000	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD PRESIDENTE RAUL RICARDO ALFONSIN	ROVERANO Y BATALLA DE SAN LORENZO	SANTA FE	LA CAPITAL	SANTO TOME',
  'CENTRO DE SALUD BARRIO PAPROKY	Ruta 2 Km 18	SANTA FE	LA CAPITAL	MONTE VERA',
  'CENTRO DE SALUD NUEVO HORIZONTE	CARRANZA Y MONSEÑOR RODRIGUEZ	SANTA FE	LA CAPITAL	SANTA FE',
  'CENTRO DE SALUD ADELINA ESTE	DIAGONAL 12 Y 71	SANTA FE	LA CAPITAL	VILLA ADELINA',
  'SAMCO ESPERANZA	Rdo. P. A.  Jansen 2693	SANTA FE	LAS COLONIAS	ESPERANZA',
  'CENTRO DE SALUD VECINAL BARRIO NORTE	SARMIENTO 3446	SANTA FE	LAS COLONIAS	ESPERANZA',
  'CENTRO DE SALUD BARRIO UNIDOS	PERU 709	SANTA FE	LAS COLONIAS	ESPERANZA',
  'CENTRO DE SALUD CEFERINO NAMUNCARA - ESPERANZA	SANTIAGO DEL ESTERO 216	SANTA FE	LAS COLONIAS	ESPERANZA',
  'CENTRO DE SALUD DR. ESTEBAN MARADONA - ESPERANZA	Simón de Iriondo 5888	SANTA FE	LAS COLONIAS	ESPERANZA',
  'HOSPITAL PROVINCIAL	Leandro Alem 1450	SANTA FE	ROSARIO	ROSARIO',
  'HOSPITAL PROVINCIAL DEL CENTENARIO - URQUIZA 3101	Urquiza 3101	SANTA FE	ROSARIO	ROSARIO',
  'SAMCO ACEBAL - HOSPITAL MARIA SAA PEREYRA	Aristóbulo del Valle 303 (esquina Mitre)	SANTA FE	ROSARIO	ACEBAL',
  'HOSPITAL DR. ROQUE SAENZ PEÑA	LAPRIDA FRANCISCO NARCISO 5381	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE ESPECIALIDADES MEDICAS AMBULATORIAS (CEMAR)	SAN LUIS 2020	SANTA FE	ROSARIO	ROSARIO',
  'SAMCO GENERAL SAN MARTIN - ARROYO SECO	J. Salk y Ruta 21	SANTA FE	ROSARIO	ARROYO SECO',
  'CENTRO DE SALUD ASISTENCIAL A LA COMUNIDAD-CEAC	ESMERALDA 2363	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD ITATI - VILLA GOBERNADOR GALVEZ	MARCOS PAZ Y GARCIA GONZALEZ	SANTA FE	ROSARIO	VILLA GOBERNADOR GALVEZ',
  'CENTRO DE SALUD N° 10 VILLA MANUELITA	RICARDO GUIRALDES 298 BIS	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 11 VILLA CORRIENTES	AMENABAR 1329	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 12 DR. GARCIA PIATTI	BALCARCE 3850	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 13 FONAVI	ALFREDO ROUILLON 3671	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 14 AVELLANEDA OESTE	Amenabar 4122	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 17 CARITAS GUADALUPE	DOMINGO FRENCH 5496	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 2 FONAVI SUPER CEMENTO	DONADO BIS	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 21 CABIN 9	AGUARIBAY Y HUDSON	SANTA FE	ROSARIO	PEREZ',
  'CENTRO DE SALUD N° 22 GONZALEZ LOZA	BOLONIA 4787	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 25 FONAVI	CALLE 1110 2877	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 29 ARAOZ DE LA MADRID	LAFERRERE 4629	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 47 BARRIO TOBA	JUAN JOSE PASO 5132	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 5 PEDRO FIORINA	AVENIDA FRANCIA 3104	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 8 INDEPENDENCIA	CASIANO CASAS 1801	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 9 SAN FRANCISQUITO	GALVEZ 3501	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD PUEBLO ESTHER	J.D Perón 1835	SANTA FE	ROSARIO	PUEBLO ESTHER',
  'CENTRO DE SALUD LIBERTAD	Calle 1816 4496	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD N° 7 12 DE OCTUBRE	Maestro Massa 470	SANTA FE	ROSARIO	ROSARIO',
  'CS RAMON CARRILLO	TUCUMAN 5627	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD ALFONSINA STORNI	Bermudez 6390	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD CEFERINO NAMUNCURA - ROSARIO	JOSE INGENIEROS 8590	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD JUANA AZURDUY	FRAGA 1093 BIS	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD JOSE RAUL UGARTE	SUINDA 980 (MENDOZA 9500)	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD VECINAL BARRIO PLATA	LAMADRID 3307	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD CASIANO CASAS	CASIANO CASAS 970	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD DR. DAVID STAFFIERI	PRESIDENTE JUAN DOMINGO PERON 4540	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD DR. SALVADOR MAZZA	Caracas 3903	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD EL GAUCHO	NICOLAS AVELLANEDA 5625	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD EL MANGRULLO	Ctda. Mangrullo 4898	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD ELENA BAZET (EX SAN FRANCISCO SOLANO)	MADRE CABRINI 2717	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD EMAUS - ROSARIO	URDINARRAIN 7900	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD EVA DUARTE	ALFREDO ROVILLON 2095	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD JEAN HENRY DUNNANT	TENIENTE AGNETA 1535	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD JUAN B. JUSTO	JUAN B. JUSTO 2083	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD JULIO MAIZTEGUI (EX SAN ROQUE)	5 DE AGOSTO DE 1523	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD LA FLORIDA	LUIS BRAILLE 1205	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD LAS FLORES	FLOR DE NACAR 6976	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD LUCHEMOS POR LA VIDA	JUAN FRANCISCO SEGUI 6552	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD LUIS PASTEUR	AYOLAS 270	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD MARCELINO CHAMPAGNAT	CASTELLANOS 3935	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD MARTIN	MARIANO MORENO 950	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD MAURICIO CASALS	JUAN FRANCISCO SEGUI 5305	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD POCHO LEPRATTI	CAÑA DE AMBAR 1667	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD ROQUE COULIN	HUMBERTO PRIMO 2033	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD RUBEN NARANJO (EX LAS HERAS)	SANCHEZ DE THOMPSON 9 BIS	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SAN MARTIN - ROSARIO	CHUBUT 7145	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SAN VICENTE DE PAUL	PUNTA DEL INDIO 7760	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SANTA LUCIA - ROSARIO	Riobamba 7691	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SANTA MARIA JOSEFA ROSELLO	AVENIDA RIVAROLA 7100	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SANTA TERESITA	Francia 4035	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD SUR - ROSARIO	AYACUCHO 6309	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD TIO ROLO	NICOLAS AVELLANEDA 6935	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD VECINAL DOMINGO MATHEU	CORRIENTES 3880	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD ALICIA MOREAU DE JUSTO	CALLE 1333 3040	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD VECINAL SAN MARTIN A	Piedras 1469	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD PRIMERO DE MAYO	JUAN DE DIOS MENA 2221	SANTA FE	ROSARIO	ROSARIO',
  'CENTRO DE SALUD DR. ESTEBAN MARADONA - ROSARIO	Cochabamba 5103	SANTA FE	ROSARIO	ROSARIO',
  'HOSPITAL DE  SAN CRISTOBAL DON JULIO CESAR VILLANUEVA	Cochabamba 1456	SANTA FE	SAN CRISTÓBAL	SAN CRISTOBAL',
  'CENTRO DE SALUD BARRIO SAN MIGUEL	Dr. Fernadez 148	SANTA FE	SAN CRISTÓBAL	SUARDI',
  'SAMCO SUARDI DR RUBEN LUIS GIMENEZ	DOCTOR FERNANDEZ 365	SANTA FE	SAN CRISTÓBAL	SUARDI',
  'SAMCO SAN GUILLERMO	Sarmiento 744	SANTA FE	SAN CRISTÓBAL	SAN GUILLERMO',
  'CENTRO DE SALUD DR. ISAAC WARCHAVSKY	CENTENARIO S/N° BARRIO PUEBLO NUEVO	SANTA FE	SAN CRISTÓBAL	SAN GUILLERMO',
  'CENTRO DE SALUD BARRIO EL TRIANGULO DR. MARIO BARONI	BARRIO EL TRIANGULO	SANTA FE	SAN JAVIER	SAN JAVIER',
  'SAMCO CORONDA	España 2307	SANTA FE	SAN JERÓNIMO	CORONDA',
  'SAMCO GALVEZ	Bartolome Mitre 1551	SANTA FE	SAN JERÓNIMO	GALVEZ',
  'SAMCO SAN JUSTO	ITALIA 2865	SANTA FE	SAN JUSTO	SAN JUSTO',
  'SAMCO GOBERNADOR CRESPO	Combate de San  Lorenzo 453	SANTA FE	SAN JUSTO	GOBERNADOR CRESPO',
  'CENTRO DE SALUD BARRIO REYES	9 DE JULIO 2518	SANTA FE	SAN JUSTO	SAN JUSTO',
  'CENTRO DE SALUD 24 DE SETIEMBRE	BOULEVARD PELLEGRINI Y RECONQUISTA	SANTA FE	SAN JUSTO	SAN JUSTO',
  'SAMCO GRANADEROS A CABALLO	RICCHIERI 347	SANTA FE	SAN LORENZO	SAN LORENZO',
  'SAMCO SAN JORGE	URQUIZA 1648	SANTA FE	SAN MARTÍN	SAN JORGE',
  'CENTRO DE SALUD SANTA ROSA DE LIMA	JUANA AZURDUY 3490	SANTA FE	VERA	VERA',
  'CENTRO INTEGRAL DE SALUD BANDA DR RICARDO ABDALA (CIS BANDA)	Avenida San Martín 449	SANTIAGO DEL ESTERO	BANDA	LA BANDA',
  'CENTRO DE INTEGRACION COMUNITARIA (CIC) BARRIO SAN CARLOS - LA BANDA	Bº SAN CARLOS - LA BANDA	SANTIAGO DEL ESTERO	BANDA	LA BANDA',
  'UPA Nº 4 Bº EJERCITO ARGENTINO	CALLE 59 Y 4 N°141   Bº EJERCITO ARGENTINO	SANTIAGO DEL ESTERO	CAPITAL	SANTIAGO DEL ESTERO',
  'UPA Nº 5 BARRIO AUTONOMIA	R. HELLMAN N°158 B°AUTONOMIA	SANTIAGO DEL ESTERO	CAPITAL	SANTIAGO DEL ESTERO',
  'UPA Nº 2 BARRIO CACERES	PEDRO PABLO OLAECHEA 1117 Y ALSINA	SANTIAGO DEL ESTERO	CAPITAL	SANTIAGO DEL ESTERO',
  'UPA Nº 20 Bº VILLA ESTHER	SOLÍS 1407	SANTIAGO DEL ESTERO	CAPITAL	SANTIAGO DEL ESTERO',
  'CAPS LOS LAGOS - NUESTRA SEÑORA DE GUADALUPE	PJE 487 Y AV. MADRE DE CIUDADES	SANTIAGO DEL ESTERO	CAPITAL	SANTIAGO DEL ESTERO',
  'CAPS N° 8  EVA PERON	De la Estancia y Rio Claro	TIERRA DEL FUEGO	USHUAIA	USHUAIA',
  'HOSPITAL SAN JOSE DE MEDINAS	AVENIDA MITRE S/N° FRENTE A LA PLAZA DE LA COMUNA DE MEDINA	TUCUMAN	CHICLIGASTA	MEDINA',
  'HOSPITAL DR. ELIAS L. MEDICI TAFI DEL VALLE	AVENIDA SAN MARTIN S/N°	TUCUMAN	TAFÍ DEL VALLE	TAFI DEL VALLE',
  'HOSPITAL TRANSITO CACERES DE ALLENDE	BUCHARDO 1250	CORDOBA	CAPITAL	CORDOBA',
  'HOSPITAL RURAL EPUYEN	EL AMANCAY 12	CHUBUT	CUSHAMEN	EPUYEN',
  'HOSPITAL ZONAL ESQUEL	25 de Mayo 150	CHUBUT	FUTALEUFÚ	ESQUEL',
  'HOSPITAL SAN ANTONIO	AV. DE LA SOBERANIA S/N	ENTRE RIOS	GUALEGUAY	GUALEGUAY',
  'HOSPITAL SAN FRANCISCO DE ASIS	AMÉRICA Nº 1650	NEUQUEN	PARANÁ	CRESPO',
  'HOSPITAL SAN ROQUE	Dr. E. ROZADOS Nº 475	ENTRE RIOS	TALA	ROSARIO DEL TALA',
  'HOSPITAL DR. ARTURO ZABALA (6)	LEANDRO ALEM S/N	JUJUY	EL CARMEN	PERICO',
  'HOSPITAL PIEDRA DEL AGUILA	LOS LONCOS Y FERNANDEZ ORO	NEUQUEN	COLLÓN CURÁ	PIEDRA DEL AGUILA',
  'HOSPITAL AREA PROGRAMA LAMARQUE DR. JORGE REBOK	RIVADAVIA 250	RIO NEGRO	AVELLANEDA	LAMARQUE',
  'HOSPITAL SAN VICENTE DE PAUL DE ORAN	Pueyrredón 701	SALTA	ORÁN	SAN RAMON DE LA NUEVA ORAN',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD SAN JAVIER Y YACANTO	MIGUEL MALDONADO S/N	CORDOBA	SAN JAVIER	SAN JAVIER Y YACANTO',
  'CENTRO DE SALUD GOBERNADOR FONTANA	La Rioja 703	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD GUEMES	FERROCARRIL PATAGONICO 1500	CHUBUT	BIEDMA	PUERTO MADRYN',
  'CENTRO DE SALUD AGUA POTABLE	Patagonia 615	CHUBUT	CUSHAMEN	EL MAITEN',
  'CENTRO DE SALUD ETCHEPARE TRELEW	CAMBRIN  N° 1600	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD JORGE MORADO	Estados Arabes y Av La Plata	CHUBUT	RAWSON	TRELEW',
  'CENTRO DE SALUD RAMON CARRILLO - TRELEW	GASTRE N° 216	CHUBUT	RAWSON	TRELEW',
  'DR.LUIS PATICO DANERI (EX LACTANTE)	SAN MARTIN 685	ENTRE RIOS	GUALEGUAYCHÚ	GUALEGUAYCHU',
  'CENTRO DE SALUD NUEVA ESPERANZA	TRATADO DEL PILAR Y SUPREMO ENTRERRIANO	ENTRE RIOS	LA PAZ	SANTA ELENA',
  'CAPS CIUDAD DE NIEVA (1)	PEDRO DEL PORTAL 425	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS HIGUERILLAS (3)	O HIGGINS S/N°	JUJUY	DR. MANUEL BELGRANO	SAN SALVADOR DE JUJUY',
  'CAPS FLORIDA (4)	VILTIPICO Y ZARATE S/N°	JUJUY	PALPALÁ 	PALPALA',
  'CAPS PROVIDENCIA (7)	RINCONADA 484	JUJUY	SAN PEDRO	SAN PEDRO',
  'C.A.P.S. Nº 25 BARRIO SUR ARGENTINO	Península de Valdés y Estrecho de Magallanes - Barrio Sur Argentino	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'C.A.P.S. Nº 15 ALTA GRACIA	tomas guido y Avenida Cmte. Andresito	MISIONES	CAPITAL	POSADAS (MUNICIPIO DE POSADAS)',
  'CENTRO DE SALUD ENRIQUE VIGLIONE DE SANTA CLARA	Neuquén 351	RIO NEGRO	ADOLFO ALSINA	VIEDMA',
  'CIC EVA PERON 3RA ROTONDA	Av. del Peregrino 3º Rotonda	SAN LUIS	LA CAPITAL	SAN LUIS',
  'CAPS NRO. 5 DR. RAMON CARRILLO	AVENIDA SAN MARTIN 2480	TIERRA DEL FUEGO	RÍO GRANDE	RIO GRANDE',
  'HOSPITAL LOCAL GENERAL ANITA ELICAGARAY	Doctor J. R. Torchiari 200	BUENOS AIRES	ADOLFO GONZALES CHAVES	ADOLFO GONZALES CHAVES',
  'SALA MEDICA VILLA ROSARIO SUR	Venezuela 296	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'UNIDAD SANITARIA BARRIO LUJAN DE BAHIA BLANCA	Enrique Julio 806	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'CENTRO DE SALUD VILLA NOCITO	PACIFICO 1990	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA BELLA VISTA	Charcas 906 - Barrio Bella Vista	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'SALA MEDICA BARRIO AVELLANEDA	Nicaragua 2953	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'CENTRO DE SALUD LEANDRO PIÑEIRO	Santa Cruz 2224 - Barrio Vista Alegre	BUENOS AIRES	BAHÍA BLANCA	BAHIA BLANCA',
  'HOSPITAL MUNICIPAL DE CORONEL SUAREZ DR. RAUL CACCAVO	Garibaldi 599	BUENOS AIRES	CORONEL SUÁREZ	CORONEL SUAREZ',
  'HOSPITAL MUNICIPAL DR. JULIO RAMOS	Julio Ramos 254	BUENOS AIRES	CARLOS CASARES	CARLOS CASARES',
  'HOSPITAL MUNICIPAL GARRE	Garre 950	BUENOS AIRES	CARLOS TEJEDOR	CARLOS TEJEDOR',
  'HOSPITAL M. JUSTINO HORACIO RESANO	Segundo Miguez	BUENOS AIRES	CARLOS TEJEDOR	TRES ALGARROBOS (EST. CUENCA)',
  'HOSPITAL MUNICIPAL DR. P. ROMANAZZI	Pellegrini 1136 - Daireaux	BUENOS AIRES	DAIREAUX	DAIREAUX',
  'HOSPITAL MUNICIPAL NUESTRA SEÑORA DEL CARMEN (VILLEGAS)	R. Isturiz 846	BUENOS AIRES	GENERAL VILLEGAS	GENERAL VILLEGAS (EST. VILLEGAS)',
  'HOSPITAL MUNICIPAL DR. SAVERIO GALVAGNI	Urquiza 502	BUENOS AIRES	HIPÓLITO YRIGOYEN	HENDERSON',
  'HOSPITAL SUBZONAL GENERAL DE AGUDOS JULIO DE VEDIA	Tomás Cosentino 1223	BUENOS AIRES	9 DE JULIO	9 DE JULIO',
  'CIC MARTIN CALLEGARO	Domingo French 702	BUENOS AIRES	9 DE JULIO	9 DE JULIO',
  'HOSPITAL MUNICIPAL DR. JUAN C. ARAMBURU	DEAN FUNES N° 56	BUENOS AIRES	PEHUAJÓ	PEHUAJO',
  'HOSPITAL MUNICIPAL DR. GUILLERMO DEL SOLDATO	Avenida Ugarte	BUENOS AIRES	PELLEGRINI	PELLEGRINI',
  'HOSPITAL MUNICIPAL SALLIQUELO	Avenida 9 de Julio 651	BUENOS AIRES	SALLIQUELÓ	SALLIQUELO',
  'HOSPITAL MUNICIPAL 30 DE AGOSTO	DR. EGUIGUREN 52	BUENOS AIRES	TRENQUE LAUQUEN	30 DE AGOSTO',
  'CENTRO DE SALUD BARRIO DEL ESTE	Presidente Uriburu 1350	BUENOS AIRES	TRENQUE LAUQUEN	TRENQUE LAUQUEN',
  'UNIDAD SANITARIA AMEGHINO BARRIO NOROESTE	AMEGHINO 439	BUENOS AIRES	TRENQUE LAUQUEN	TRENQUE LAUQUEN',
  'HOSPITAL MUNICIPAL DR. PEDRO ORELLANA	Castelli 150	BUENOS AIRES	TRENQUE LAUQUEN	TRENQUE LAUQUEN',
  'HOSPITAL MUNICIPAL NUESTRA SEÑORA DEL CARMEN	Avenida Garay 216	BUENOS AIRES	CHACABUCO	CHACABUCO',
  'HOSPITAL LOCAL MUNICIPAL DR. FELIPE A. PELAEZ	Avenida San Martin nº 281	BUENOS AIRES	FLORENTINO AMEGHINO	FLORENTINO AMEGHINO',
  'HOSPITAL LOCAL MUNICIPAL DR. ALBERTO VIDELA	Videla y Purini S/N	BUENOS AIRES	GENERAL PINTO	GENERAL PINTO',
  'HOSPITAL SUBZONAL DE GENERAL VIAMONTE	6 DE AGOSTO Y PASSO	BUENOS AIRES	GENERAL VIAMONTE	GENERAL VIAMONTE',
  'HOSPITAL ZONAL GENERAL AGUDOS ABRAHAM PIÑEYRO - AREA B	Lavalle 1084	BUENOS AIRES	JUNÍN	JUNIN',
  'HOSPITAL MUNICIPAL LEANDRO N. ALEM	Belgrano entre San Juan y Mendoza	BUENOS AIRES	LEANDRO N. ALEM	VEDIA',
  'HOSPITAL MUNICIPAL DR. MIRAVALLE	Avenida San Lorenzo 2000	BUENOS AIRES	LINCOLN	LINCOLN',
  'HOSPITAL MUNICIPAL JOSE MARIA GOMENDIO	JOSE MARIA GOMENDIO 1374	BUENOS AIRES	RAMALLO	RAMALLO',
  'UNIDAD SANITARIA DR. ANGLARILL BARRIO EL MOLINO	MIRITA DE LAVALLE ENTRE BOLIVAR Y VIAMONTE	BUENOS AIRES	SALTO	SALTO',
  'HOSPITAL LOCAL GENERAL DE SALTO	Libertad 520	BUENOS AIRES	SALTO	SALTO',
  'CIC SALUD	ALBERDI 768	BUENOS AIRES	SAN ANTONIO DE ARECO	SAN ANTONIO DE ARECO',
  'CAPS DR TEODORO DOMINGUEZ	EMILIO BARLETTI y AMELIA DE ZEOLI	BUENOS AIRES	SAN ANTONIO DE ARECO	SAN ANTONIO DE ARECO',
  'CAPS N° 6	San Lorenzo 982	BUENOS AIRES	CAMPANA	CAMPANA',
  'CENTRO DE SALUD AURORA PEÑALBA	RIO TURBIO Nº 35 - Bº STONE	BUENOS AIRES	ESCOBAR	BELEN DE ESCOBAR',
  'UNIDAD SANITARIA PERIFERICA RAMON CARILLO DE GARIN	MISIONES SALESIANAS Y PIEDRABUENA BO. SAN JAVIER - GARIN	BUENOS AIRES	ESCOBAR	GARIN',
  'SALA DE PRIMEROS AUXILIOS CRUZ PARADA ROBLES	RUTA 39 KM. 1	BUENOS AIRES	EXALTACIÓN DE LA CRUZ	PARADA ROBLES',
  'UNIDAD SANITARIA N° 20 POSTA CARCOVA	1° de Mayo y Paseo de  la Patria	BUENOS AIRES	GENERAL SAN MARTÍN	CIUDAD DEL LIBERTADOR GENERAL SAN MARTIN',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS EVA PERON	Avenida Doctor Ricardo Balbín 3200	BUENOS AIRES	GENERAL SAN MARTÍN	GENERAL SAN MARTÍN',
  'POSTA 13 DE JULIO	Eva Duarte (San Martín bis sin/nro)	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA JOSE LEON SUAREZ',
  'CENTRO DE SALUD N° 22 DR JUAN NAAB	Debenedetti 8555	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA JOSE LEON SUAREZ',
  'CENTRO DE SALUD DR. ALEXANDER FLEMING	AVENIDA MARQUEZ Y 9 DE JULIO 4200	BUENOS AIRES	GENERAL SAN MARTÍN	JOSÉ LEÓN SUAREZ',
  'UNIDAD SANITARIA N° 13 DE VILLA LYNCH	CALLE 8 (AZCUENAGA) 226 ENTRE 95 y 97	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA LYNCH',
  'UNIDAD SANITARIA N° 12 DE VILLA PIAGGIO	CALLE 81 PARRAVICINI 965 (ENTRE 24 y 26)	BUENOS AIRES	GENERAL SAN MARTÍN	VILLA PIAGGIO',
  'HOSPITAL ZONAL GENERAL DE AGUDOS GOBERNADOR DOMINGO MERCANTE	Coronel Arias 880	BUENOS AIRES	JOSÉ C. PAZ	TORTUGUITAS',
  'TRAILLER I	Avenida Hipólito Irigoyen 2945 entre Casacuberta y Martel	BUENOS AIRES	JOSÉ C. PAZ	JOSE C. PAZ',
  'CENTRO DE DIABETES Y ENFERMEDADES METABOLICAS DR. ALBERTO MAGGIO	San Martín N° 1675	BUENOS AIRES	MALVINAS ARGENTINAS	LOS POLVORINES',
  'CENTRO DE SALUD  MARIA AUXILIADORA WILLIAM MORRIS	SANTA MARIA 2500	BUENOS AIRES	PILAR	DEL VISO',
  'UNIDAD SANITARIA MANUEL ALBERTI	M. Paillete e/ Sta María y Sta Rita	BUENOS AIRES	PILAR	MANUEL ALBERTI',
  'UNIDAD SANITARIA MANZANARES	Alas Argentinas 79	BUENOS AIRES	PILAR	MANZANARES',
  'UNIDAD SANITARIA SAN CAYETANO DE PILAR	Noruega y Honduras	BUENOS AIRES	PILAR	MAQUINISTA F. SAVIO (OESTE)',
  'UNIDAD SANITARIA SAN ALEJO	San Salvador y Dr. Ignacio Pirovano	BUENOS AIRES	PILAR	PILAR',
  'UNIDAD SANITARIA BARRIO TORO	NORUEGA ENTRE RIO TERCERO Y RIO CUARTO	BUENOS AIRES	PILAR	PRESIDENTE DERQUI',
  'HOSPITAL ZONAL GENERAL AGUDOS PETRONA V. DE CORDERO	Belgrano 1955	BUENOS AIRES	SAN FERNANDO	VIRREYES',
  'HOSPITAL MUNICIPAL DE DIAGNOSTICO Y ESPECIALIDADES SAN CAYETANO	Avellaneda N° 4850	BUENOS AIRES	SAN FERNANDO	VIRREYES',
  'HOSPITAL MATERNO INFANTIL DE SAN ISIDRO	Diego Palma 534	BUENOS AIRES	SAN ISIDRO	SAN ISIDRO',
  'CENTRO DE SALUD EL ARCO	Guido y Spano 10	BUENOS AIRES	TIGRE	BENAVIDEZ',
  'CENTRO DE SALUD DON TORCUATO	ESPAÑA 1450	BUENOS AIRES	TIGRE	DON TORCUATO ESTE',
  'CENTRO DE SALUD BAIRES	El cano N° 960 e/e Gallardo e Ituzaingó	BUENOS AIRES	TIGRE	DON TORCUATO ESTE',
  'CENTRO DE SALUD LA PALOMA	AV. LA PALOMA E/PARAGUAY Y MONTEAGUDO - G. PACHECO	BUENOS AIRES	TIGRE	GENERAL PACHECO',
  'CATAMARAN SANITARIO DR. LUIS PEREYRA	Bourdieu 460 - Islas del Delta	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE SALUD TRONCOS DEL TALAR	Mozart 500	BUENOS AIRES	TIGRE	LOS TRONCOS DEL TALAR',
  'CENTRO DE SALUD ALMIRANTE BROWN	Gral. Andrés 3010 y Alemania - El Talar de Pacheco	BUENOS AIRES	TIGRE	EL TALAR',
  'CENTRO DE SALUD RICARDO ROJAS	RICCHIERI Y ELIZALDE	BUENOS AIRES	TIGRE	EL TALAR',
  'HOSPITAL DE DIAGNOSTICO INMEDIATO DR. VALENTIN NORES	Maipú N° 257	BUENOS AIRES	TIGRE	TIGRE',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD EVA PERON	Padre Nuestro 154	BUENOS AIRES	TIGRE	GENERAL PACHECO',
  'CAPS CARUPA	RUPERTO MAZZA 1154	BUENOS AIRES	TIGRE	TIGRE',
  'UAP BLANCA ELOISA RODRIGUEZ DE ACOSTA	MARIQUITA SANCHEZ DE THOMPSON 1141	BUENOS AIRES	VICENTE LÓPEZ	FLORIDA',
  'INSTITUTO MATERNIDAD SANTA ROSA	MARTIN J. HAEDO 4150	BUENOS AIRES	VICENTE LÓPEZ	FLORIDA',
  'UNIDAD SANITARIA EL CEIBO	Capitán Justo G. de Bermúdez 200	BUENOS AIRES	VICENTE LÓPEZ	LA LUCILA',
  'UNIDAD DE ATENCION PRIMARIA DR. LLOBERA	Estados Unidos 314	BUENOS AIRES	VICENTE LÓPEZ	VILLA MARTELLI',
  'UNIDAD SANITARIA N° 18 VIAS RESPIRATORIAS DE BURZACO	Presidente Perón (Ex Gorriti) 888 entre Brasil e Italia	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'CAPS N° 26 UNIDAD DE SALUD AMBIENTAL (USAM)	CONSTITUCION NRO. 972 ESQ. PRIETO, DE BURZACO	BUENOS AIRES	ALMIRANTE BROWN	LONGCHAMPS',
  'UNIDAD SANITARIA N° 1 MINISTRO RIVADAVIA DE BURZACO	25 de Mayo entre Cardenas y Sandoval - Barrio Ministro Rivadavia	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'CAPS N° 25 2 DE ABRIL	SANTA ANA 2440 E/ MARATURE Y CEFERINO RAMIREZ, RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'HOSPITAL INTERZONAL GENERAL AGUDOS DR. PEDRO FIORITO	Avenida Manuel Belgrano 851	BUENOS AIRES	AVELLANEDA	WILDE',
  'CENTRO MUNICIPAL DE CUIDADO FAMILIAR Y COMUNITARIO VILLA AZUL	Ramón Franco 6500	BUENOS AIRES	AVELLANEDA	AVELLANEDA',
  'HOSPITAL INTERZONAL GENERAL AGUDOS PRESIDENTE PERON	Anatole France 773	BUENOS AIRES	AVELLANEDA	SARANDI',
  'UNIDAD SANITARIA N° 6 DE BERAZATEGUI	CALLE 160 ENTRE 30 Y 31 VILLA MITRE	BUENOS AIRES	BERAZATEGUI	BERAZATEGUI',
  'UNIDAD SANITARIA Nº 25	58 e/ 121 y 122  S/N	BUENOS AIRES	BERAZATEGUI	GUILLERMO ENRIQUE HUDSON',
  'UNIDAD SANITARIA N° 33 DE BERAZATEGUI	CALLE 161 Y 45 S/N BARRIO 3 DE JUNIO	BUENOS AIRES	BERAZATEGUI	PLATANOS',
  'UNIDAD SANITARIA N° 10 DE PLATANOS	CALLE 157 ENTRE 43 Y 44 PLATANOS	BUENOS AIRES	BERAZATEGUI	GUILLERMO ENRIQUE HUDSON',
  'UNIDAD SANITARIA N° 29 DE BERAZATEGUI	AV. NICOLAS MILAZZO 368 BARRIO LUZ	BUENOS AIRES	BERAZATEGUI	RANELAGH',
  'POLICLINICO SOFIA TERRERO DE SANTAMARINA	General Alvear 350	BUENOS AIRES	ESTEBAN ECHEVERRÍA	MONTE GRANDE',
  'CENTRO DE SALUD RAMON CARRILLO DE ESTEBAN ECHEVERRIA	Mariano Acosta 481	BUENOS AIRES	ESTEBAN ECHEVERRÍA	MONTE GRANDE',
  'HOSPITAL ZONAL GENERAL DE AGUDOS EURNEKIAN (EX MADRE TERESA DE CALCUTA)	Alem Nº 349	BUENOS AIRES	EZEIZA	AEROPUERTO INTERNACIONAL EZEIZA',
  'CENTRO DE SALUD N° 2	Giribone 154	BUENOS AIRES	EZEIZA	TRISTAN SUAREZ',
  'CENTRO DE SALUD N° 24 LA CUNITA	URQUIZA Y SAAVEDRA - BO. VECINAL	BUENOS AIRES	EZEIZA	JOSE MARIA EZEIZA',
  'CENTRO DE SALUD N° 14	Floresta y Hugo Gilarte	BUENOS AIRES	EZEIZA	LA UNION',
  'CENTRO DE SALUD N° 12	Gonnet y Echeverría - Altos de Tristán Suárez	BUENOS AIRES	EZEIZA	TRISTAN SUAREZ',
  'UNIDAD SANITARIA SAN FRANCISCO DE FLORENCIO VARELA	CALLE 1336 ENTRE 1319 y 1321 S/Nº - BARRIO SAN FRANCISCO - EL ALPINO	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'UNIDAD SANITARIA BOSQUES NORTE BAIGORRI	Marcos Paz 1383	BUENOS AIRES	FLORENCIO VARELA	BOSQUES',
  'UNIDAD SANITARIA LA ESMERALDA	Avenida 13 de Diciembre (Av. Padre Obispo J. Novak)  2332 e/Lambardi y Liejas - Barrio La Esmeralda	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'UNIDAD SANITARIA INGENIERO ALLAN	AMELIA (1134) ENTRE CUYEN (1147) Y PIRAN (1145) BARRIO INGENIERO ALLAN	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'CENTRO DE SALUD DON JOSE	EL INDIO 57 - BARRIO DON JOSE	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'UNIDAD SANITARIA SANTA ROSA	Sicilia entre Milan y Brown Manzana 5	BUENOS AIRES	FLORENCIO VARELA	FLORENCIO VARELA',
  'CAPS VILLA VATTEONE	12 de Octubre N° 363	BUENOS AIRES	FLORENCIO VARELA	VILLA VATTEONE',
  'CENTRO DE SALUD VILLA INDUSTRIAL FIORITO	Teniente Coronel Bueras 3386	BUENOS AIRES	LANÚS	LANUS ESTE',
  'HOSPITAL ZONAL GENERAL AGUDOS NARCISO LOPEZ	O Higgins 1333	BUENOS AIRES	LANÚS	LANUS ESTE',
  'UNIDAD SANITARIA PROVINCIAS UNIDAS	Paris 1947	BUENOS AIRES	LOMAS DE ZAMORA	BANFIELD',
  'UNIDAD SANITARIA N° 17 DE INGENIERO BUDGE	Quesada y Campoamor	BUENOS AIRES	LOMAS DE ZAMORA	LOMAS DE ZAMORA',
  'HOSPITAL MUNICIPAL MATERNO INFANTIL DR. O. ALENDE	CLAUDIO DE ALAS 2584	BUENOS AIRES	LOMAS DE ZAMORA	LOMAS DE ZAMORA',
  'UNIDAD SANITARIA LAVALLOL	GRAL. NECOCHEA Y GERMÁN KURTH	BUENOS AIRES	LOMAS DE ZAMORA	LLAVALLOL',
  'UNIDAD SANITARIA SANTA MARTA	VOLTAIRE 1650 BARRIO SANTA MARTA	BUENOS AIRES	LOMAS DE ZAMORA	BANFIELD',
  'UNIDAD SANITARIA 2 DE ABRIL DE LOMAS DE ZAMORA	SOLDADO ZELARRAYAN 1103	BUENOS AIRES	LOMAS DE ZAMORA	LOMAS DE ZAMORA',
  'UNIDAD SANITARIA VILLA ALBERTINA	BUSTOS 2172 VILLA ALBERTINA	BUENOS AIRES	LOMAS DE ZAMORA	LOMAS DE ZAMORA',
  'HOSPITAL INTERZONAL GENERAL AGUDOS L. C. DE GANDULFO	Balcarce 351	BUENOS AIRES	LOMAS DE ZAMORA	TEMPERLEY',
  'UNIDAD SANITARIA BARRIO OBRERO	107 ESQUINA 4 MANZANA 1 CASA 1-2	BUENOS AIRES	LOMAS DE ZAMORA	LOMAS DE ZAMORA',
  'UNIDAD SANITARIA DR. M. J. OLIVERAS	CARHUE 850	BUENOS AIRES	LOMAS DE ZAMORA	TEMPERLEY',
  'UNIDAD SANITARIA LAS CASUARINAS	LAS CASUARINAS 347	BUENOS AIRES	LOMAS DE ZAMORA	TEMPERLEY',
  'UNIDAD SANITARIA FONROUGE	CARAZA 1848	BUENOS AIRES	LOMAS DE ZAMORA	VILLA CENTENARIO',
  'CENTRO DE SALUD DR. E. FINOCHIETTO	CAMPOAMOR ESQUINA GINEBRA S/N	BUENOS AIRES	LOMAS DE ZAMORA	BANFIELD',
  'UNIDAD SANITARIA VILLA AZUL	Sargento Cabral entre Chubut y Dr. Caviglia	BUENOS AIRES	QUILMES	BERNAL',
  'UNIDAD SANITARIA VILLA ITATI II	FALUCHO 1146	BUENOS AIRES	QUILMES	BERNAL',
  'CENTRO ASISTENCIAL MUNICIPAL DON BOSCO	Coronel Pringles 1010	BUENOS AIRES	QUILMES	DON BOSCO',
  'UNIDAD SANITARIA DREYMAR	CALLE 895 E/819 Y 820	BUENOS AIRES	QUILMES	SAN FRANCISCO SOLANO',
  'UNIDAD SANITARIA 8 DE OCTUBRE I DE QUILMES	CALLE 829 1900	BUENOS AIRES	QUILMES	SAN FRANCISCO SOLANO',
  'SALA N° 13 BARRIO ALTOS DEL OESTE	CENTRAL S/N ENTRE FLORIDA Y BARADERO	BUENOS AIRES	GENERAL RODRÍGUEZ	GENERAL RODRIGUEZ',
  'HOSPITAL ZONAL GENERAL VICENTE LOPEZ Y PLANES	ALEM Y 25 DE MAYO	BUENOS AIRES	GENERAL RODRÍGUEZ	GENERAL RODRIGUEZ',
  'HOSPITAL NACIONAL DR. BALDOMERO SOMMER	Ruta 24 km. 23.500 - Cuartel IV	BUENOS AIRES	GENERAL RODRÍGUEZ	GENERAL RODRIGUEZ',
  'UNIDAD SANITARIA ITUZAINGO SUR	GELPI 2155	BUENOS AIRES	ITUZAINGÓ	ITUZAINGO SUR',
  'CENTRO VILLA LAS NACIONES	HAITI Y TURQUIA Bº VILLA LAS NACIONES	BUENOS AIRES	ITUZAINGÓ	ITUZAINGO SUR',
  'HOSPITAL ZONAL MUNICIPAL NUESTRA SEÑORA DE LUJAN	SAN MARTIN 1750	BUENOS AIRES	LUJÁN	LUJAN',
  'CENTRO PERIFERICO DE SALUD TORRES	CAPITAN HERNANDEZ E/ CALDERON DE LA BARCA Y BLOMBERG	BUENOS AIRES	LUJÁN	LUJAN',
  'UNIDAD SANITARIA SAN BERNARDO	JOAQUIN V. GONZALEZ 372 S/N BARRIO SAN BERNARDO	BUENOS AIRES	LUJÁN	LUJAN',
  'HOSPITAL MUNICIPAL DR. HECTOR J. D AGNILLO	Leandro N. Alem 250	BUENOS AIRES	MARCOS PAZ	MARCOS PAZ',
  'UNIDAD SANITARIA N° 13 DE MERLO	COLOMBIA Y MORETTI	BUENOS AIRES	MERLO	LIBERTAD',
  'HOSPITAL MUNICIPAL EVA PERON	Colón 451	BUENOS AIRES	MERLO	SAN ANTONIO DE PADUA',
  'HOSPITAL MATERNO INFANTIL DE PONTEVEDRA	Capitán Pedro Giachino 2220	BUENOS AIRES	MERLO	PONTEVEDRA',
  'UPA 12	Ruta Prov. 24 y C. Bernardi	BUENOS AIRES	MORENO	CUARTEL V',
  'UNIDAD SANITARIA ANDERSON	DISCEPOLO 6702/8 - BARRIO ANDERSON	BUENOS AIRES	MORENO	CUARTEL V',
  'UNIDAD SANITARIA VILLA ESCOBAR	Tito Livio 4502 - Barrio Villa Escobar	BUENOS AIRES	MORENO	FRANCISCO ALVAREZ',
  'UNIDAD SANITARIA REJA CENTRO	ALFONSINA STORNI 1476 BARRIO LA REJA CENTRO	BUENOS AIRES	MORENO	LA REJA',
  'CAPS ALTOS DE LA REJA	PILCOMAYO E/ SALTA Y BENITO JUAREZ	BUENOS AIRES	MORENO	LA REJA',
  'UNIDAD SANITARIA N° 5 DR. CORSI DE MORENO	Avenida Miero 906 - Barrio Santa Rosa	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA LA ESPERANZA	TUPAC AMARU 6302 BARRIO ARTURO ULLIA	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA BARRIO INDANBURU	Segurola 1475	BUENOS AIRES	MORENO	MORENO',
  'UNIDAD SANITARIA POSTA PARQUE PASO DEL REY	BELGRANO 3873	BUENOS AIRES	MORENO	PASO DEL REY',
  'UNIDAD SANITARIA SANTA BRIGIDA 17 DE AGOSTO	REPUBLICA  ARGENTINA 716/80 BARRIO SANTA BRIGIDA	BUENOS AIRES	MORENO	TRUJUI',
  'UNIDAD SANITARIA LAS CATONAS	CHUQUISACA 3181	BUENOS AIRES	MORENO	TRUJUI',
  'UNIDAD SANITARIA VILLA RIVADAVIA	Dr. Osvaldo Magnasco 933	BUENOS AIRES	MORÓN	HAEDO',
  'HOSPITAL ZONAL GENERAL AGUDOS PROF. DR. RAMON CARRILLO	Hipólito Yrigoyen 1055	BUENOS AIRES	TRES DE FEBRERO	CIUDADELA',
  'HOSPITAL MUNICIPAL DR. PEDRO SOLANET	Av. Dindart 852	BUENOS AIRES	AYACUCHO	AYACUCHO',
  'CENTRO DE SALUD EVA PERON	AVENIDA SOLANET e/ SOMIGLIANA y BROWN	BUENOS AIRES	AYACUCHO	AYACUCHO',
  'CENTRO DE SALUD DR. CARRILLO DE AYACUCHO	JACOBO BERRA	BUENOS AIRES	AYACUCHO	AYACUCHO',
  'UNIDAD SANITARIA DR. CARMELO PEPI (MECHONGUE)	CALLE 4 N° 234	BUENOS AIRES	GENERAL ALVARADO	MECHONGUE',
  'SALA DE PRIMEROS AUXILIOS JUAN DE DIOS STELLA	AV. 9 ENTRE 74 Y 76 BARRIO LAS FLORES	BUENOS AIRES	GENERAL ALVARADO	MIRAMAR',
  'CAPS BARRIO OESTE DE MIRAMAR	CALLE 55 1261 ENTRE 24 Y AVENIDA 26 BARRIO OESTE	BUENOS AIRES	GENERAL ALVARADO	MIRAMAR',
  'UNIDAD SANITARIA GENERAL GUIDO	SAN MARTIN S/N	BUENOS AIRES	GENERAL GUIDO	GENERAL GUIDO',
  'HOSPITAL MUNICIPAL ANA ROSA S. DE MARTINEZ GUERRERO	Avda. Buenos Aires y Echeverría	BUENOS AIRES	GENERAL JUAN MADARIAGA	GENERAL JUAN MADARIAGA',
  'HOSPITAL MUNICIPAL SAGRADO CORAZON DE JESUS	AV. DE LA SERNA N° 1064	BUENOS AIRES	GENERAL LAVALLE	GENERAL LAVALLE',
  'SALA DE SALUD PARAJE PAVON	HECTOR J. CAMPORA S/N	BUENOS AIRES	GENERAL LAVALLE	GENERAL LAVALLE',
  'C.A.P.S. EL MARTILLO	Génova 6657	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. PLAYAS DEL SUR	445 e/ 8 y 6 bis - B° Playa Serena	BUENOS AIRES	GENERAL PUEYRREDÓN	PUNTA MOGOTES',
  'C.A.P.S. LA PEREGRINA	RUTA N° 226 KM. 17 SIERRA DE LOS PADRES	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'C.A.P.S. 2 DE ABRIL	Calle Cisneros esq. Falkonier, B° El Retazo	BUENOS AIRES	GENERAL PUEYRREDÓN	MAR DEL PLATA',
  'HOSPITAL MUNICIPAL CARLOS F. MACIAS	Avenida Libertador San Martín 1780	BUENOS AIRES	LA COSTA	MAR DE AJO',
  'HOSPITAL LOCAL MATERNO INFANTIL DE SAN CLEMENTE DEL TUYU	AVENIDA SAN MARTIN 505	BUENOS AIRES	LA COSTA	SAN CLEMENTE DEL TUYU',
  'CENTRO DE ATENCION PRIMARIA LAS QUINTAS	16 e/ 41 y 42	BUENOS AIRES	LA COSTA	SANTA TERESITA',
  'CENTRO DE SALUD BARRIO SAN MARTIN DE LOBERIA	AVENIDA SARMIENTO 432	BUENOS AIRES	LOBERÍA	LOBERIA',
  'UNIDAD SANITARIA SAN MANUEL	Rivadavia 656	BUENOS AIRES	LOBERÍA	SAN MANUEL',
  'UNIDAD SANITARIA RAMON CARRILLO	Macías y Lamadrid	BUENOS AIRES	LOBERÍA	LOBERIA',
  'SALA ITATI (ESCUELA Nº 3)	AMEGHINO 750	BUENOS AIRES	LOBERÍA	LOBERIA',
  'UNIDAD SANITARIA BARRIO INDEPENDENCIA	SUAREZ GARCIA 530	BUENOS AIRES	LOBERÍA	LOBERIA',
  'UNIDAD SANITARIA TAMANGUEYU	RUTA N° 227 KM. 45	BUENOS AIRES	LOBERÍA	TAMANGUEYU',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD BARRIO BELGRANO	Belgrano 1691	BUENOS AIRES	MAIPÚ	MAIPU',
  'CENTRO PERIFERICO VILLA VANELLI	CALLE COLÓN ENTRE NECOCHEA Y SAN MARTIN S/N	BUENOS AIRES	MAIPÚ	MAIPU',
  'HOSPITAL MUNICIPAL EUSTAQUIO ARISTIZABAL	General Belgrano 250, Coronel Vidal	BUENOS AIRES	MAR CHIQUITA	CORONEL VIDAL',
  'CENTRO DE SALUD FOMENTO DE QUEUQEN	Calle 519 2267	BUENOS AIRES	NECOCHEA	QUEQUEN',
  'CAPS OSTENDE	MISIONES Y AV. DEL PARQUE	BUENOS AIRES	PINAMAR 	OSTENDE',
  'CENTRO DE SALUD CENTRO	Avenida 13 1700	BUENOS AIRES	VILLA GESELL 	VILLA GESELL',
  'HOSPITAL MUNICIPAL DR. ARTURO ILLIA	Paseo 123 entre 8 Y 9	BUENOS AIRES	VILLA GESELL 	VILLA GESELL',
  'HOSPITAL SUBZONAL DR. MIGUEL L. CAPREDONI	Av. Calfucurá S/Nº	BUENOS AIRES	BOLÍVAR	SAN CARLOS DE BOLIVAR',
  'UNIDAD SANITARIA DR. JOSE ANTONIO BUCCA	MANOLO CHATRUC MIGUEZ Y MONSEÑOR PASTEUR BARRIO VILLA DIAMANTE	BUENOS AIRES	BOLÍVAR	SAN CARLOS DE BOLIVAR',
  'HOSPITAL MUNICIPAL BERNARDINO RIVADAVIA	Althabe 1041	BUENOS AIRES	GENERAL ALVEAR	GENERAL ALVEAR',
  'SALA BARRIO OBRERO DE GENERAL ALVEAR	BERNARDO DE IRIGOYEN S/N	BUENOS AIRES	GENERAL ALVEAR	GENERAL ALVEAR',
  'UNIDAD SANITARIA VILLA FLORIDA	ARAVENA S/Nº	BUENOS AIRES	GENERAL LA MADRID	GENERAL LA MADRID',
  'HOSPITAL LOCAL GENERAL DR. MARIANO ECHEGARAY	Dr. Etchegaray S/N	BUENOS AIRES	GENERAL LA MADRID	GENERAL LA MADRID',
  'HOSPITAL MUNICIPAL PEDRO S. SANCHOLUZ	Sancholuz	BUENOS AIRES	LAPRIDA	LAPRIDA',
  'UNIDAD SANITARIA BARRIO TRAUT	AVELLANEDA 1261	BUENOS AIRES	LAS FLORES	LAS FLORES',
  'UNIDAD SANITARIA N° 1 DE OLAVARRIA	AV. DEL VALLE 4291 BARRIO OBRERO	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'HOSPITAL ZONAL MUNICIPAL DR. HECTOR M. CURA	Rivadavia 4057	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 18 ALBERDI DE OLAVARRIA	SAN MARTIN 1106 BARRIO ALBERDI	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 23 BELEN	EMILIOZZI BELEN 5936	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'UNIDAD SANITARIA N° 5 DE OLAVARRIA	RUFINO FAL 4124	BUENOS AIRES	OLAVARRÍA	OLAVARRIA',
  'HOSPITAL MUNICIPAL DE SIERRAS BAYAS ARTURO IGLESIAS	DOCTOR MANUEL SMIRNOFF 2363	BUENOS AIRES	OLAVARRÍA	VILLA ARRIETA',
  'HOSPITAL GENERAL DE TAPALQUE	Avenida 9 de Julio 961	BUENOS AIRES	TAPALQUÉ	TAPALQUE',
  'CENTRO INTEGRADOR COMUNITARIO	Avenida San Martín  Y colombia	BUENOS AIRES	ALBERTI	ALBERTI',
  'HOSPITAL MUNICIPAL SAN LUIS	Hermanos Islas 700	BUENOS AIRES	BRAGADO	BRAGADO',
  'DISPENSARIO BARRIO DEL PITO	BASSO DASTUGUE 380	BUENOS AIRES	CHIVILCOY	CHIVILCOY',
  'HOSPITAL MUNICIPAL DE CHIVILCOY	Av. Hijas de José 31	BUENOS AIRES	CHIVILCOY	CHIVILCOY',
  'HOSPITAL ZONAL GENERAL AGUDOS BLAS DUBARRY	Calle 12 825	BUENOS AIRES	MERCEDES	MERCEDES',
  'UNIDAD SANITARIA SAN JOSE DE MERCEDES	Calle 50 s/nº entre 19 Y 21 - Barrio San José - ( 21 y 50)	BUENOS AIRES	MERCEDES	MERCEDES',
  'HOSPITAL MUNICIPAL SAN ANTONIO DE PADUA	Avenida 16  Nº 750 (Entre 115 y 117)	BUENOS AIRES	NAVARRO	NAVARRO',
  'HOSPITAL ZONAL GENERAL DR. ALEJANDRO POSADAS	Doctor Francisco Emparanza 2753	BUENOS AIRES	SALADILLO	SALADILLO',
  'HOSPITAL MUNICIPAL ESTEBAN IRIBARNE	Dr. Eduardo Cusa 251	BUENOS AIRES	SUIPACHA	SUIPACHA',
  'HOSPITAL SUBZONAL SATURNINO E. UNZUE	Calle 37 entre 1 y 102	BUENOS AIRES	25 DE MAYO	25 DE MAYO',
  'HOSPITAL ZONAL GENERAL AGUDOS DR. LARRAIN	Londres 4435	BUENOS AIRES	BERISSO	VILLA NUEVA',
  'UNIDAD SANITARIA N° 43 DE BERISSO	CALLE 145 ENTRE 6 Y 7 S/N	BUENOS AIRES	BERISSO	BERISSO',
  'ENTE DESCENTRALIZADO HOSPITAL DR. ANGEL MARZETTI	Rawson 450	BUENOS AIRES	CAÑUELAS	CAÑUELAS',
  'UNIDAD SANITARIA LOS POZOS	NECOCHEA E/LUZURIAGA Y URBINEA S/Nº	BUENOS AIRES	CAÑUELAS	LOS POZOS',
  'UNIDAD SANITARIA SANTA ROSA DE SANTA ROSA	SAN MARTIN JOSE GAMARDO 63	BUENOS AIRES	CAÑUELAS	SANTA ROSA',
  'HOSPITAL SAN ROQUE	Lamadrid 880	BUENOS AIRES	DOLORES	DOLORES',
  'HOSPITAL ZONAL GENERAL AGUDOS HORACIO CESTINO	San Martín 328	BUENOS AIRES	ENSENADA	VILLA CATELA',
  'UNIDAD SANITARIA N° 184 DE ENSENADA	COLUMNA 184 E/ 90 Y 92  CAMINO COSTANERO	BUENOS AIRES	ENSENADA	PUNTA LARA',
  'UNIDAD SANITARIA JESUS CRUCIFICADO	AV. 9 DE JULIO S/N	BUENOS AIRES	GENERAL BELGRANO	GENERAL BELGRANO',
  'HOSPITAL MUNICIPAL JUAN E. DE LA FUENTE	AV. ESPAÑA 325	BUENOS AIRES	GENERAL BELGRANO	GENERAL BELGRANO',
  'HOSPITAL MUNICIPAL JUAN Y MARIA SCASSO DE CAMPOMAR	Avenida Campomar 3413	BUENOS AIRES	GENERAL PAZ	RANCHOS',
  'UNIDAD SANITARIA LOMA VERDE DE GENERAL PAZ	HIPOLITO IRIGOYEN 677	BUENOS AIRES	GENERAL PAZ	LOMA VERDE',
  'UNIDAD SANITARIA VILLANUEVA	BELGRANO 776 ENTRE 25 DE MAYO Y LIBERTAD	BUENOS AIRES	GENERAL PAZ	VILLANUEVA',
  'CENTRO N° 43 DE LA PLATA	CALLE 7 ESQUINA 631 BARRIO SAN CARLOS	BUENOS AIRES	LA PLATA	LA PLATA',
  'CENTRO DE SALUD N° 30 DE LA PLATA	CALLE 20 Y 50	BUENOS AIRES	LA PLATA	LA PLATA',
  'HOSPITAL INTERZONAL GENERAL DE AGUDOS DR. PROFESOR RODOLFO ROSSI	CALLE 37 ENTRE 116 Y 117 S/N	BUENOS AIRES	LA PLATA	LA PLATA',
  'CENTRO DE SALUD N° 28 DE LA PLATA	CALLE 13 ENTRE 493 Y 494	BUENOS AIRES	LA PLATA	MANUEL B. GONNET',
  'CENTRO DE SALUD N° 7 DE LA PLATA	CALLE 7 ESQUINA 82	BUENOS AIRES	LA PLATA	LA PLATA',
  'CENTRO DE SALUD N° 6 DE LA PLATA	CALLE 122 ENTRE 80 Y 81	BUENOS AIRES	LA PLATA	LA PLATA',
  'HOSPITAL SUBZONAL AGUDOS MARIA MAGDALENA	LAS HERAS 385	BUENOS AIRES	MAGDALENA	MAGDALENA',
  'UNIDAD SANITARIA SAN FRANCISCO DE ASIS	NEUQUÉN E/ SANTIAGO DEL ESTERO Y SANTA FÉ - BARRIO COPOLA	BUENOS AIRES	MONTE	SAN MIGUEL DEL MONTE (EST. MONTE)',
  'HOSPITAL ZENON VIDELA DORNA	Zenón Videla Dorna 851	BUENOS AIRES	MONTE	SAN MIGUEL DEL MONTE (EST. MONTE)',
  'HOSPITAL MUNICIPAL DR. RAMON CARRILLO - SAN VICENTE	Pascual Santoro y Matheu S/Nº	BUENOS AIRES	SAN VICENTE	SAN VICENTE',
  'CIC DR HORACIO QUINTIN	BULEVAR 5 Y CALLE 2	BUENOS AIRES	CHASCOMÚS	CHASCOMUS',
  'HOSPITAL MUNICIPAL SAN VICENTE DE PAUL	Av. Lastra esq. Hipólito Yrigoyen	BUENOS AIRES	CHASCOMÚS	CHASCOMÚS (CHASCOMÚS COUNTRY CLUB)',
  'UNIDAD SANITARIA ROQUE CARRANZA	JUAREZ E/26 DE JULIO Y BO. CORREA	BUENOS AIRES	CHASCOMÚS	CHASCOMUS',
  'HOSPITAL MATENRO INFANTIL DR. EQUIZA	DR. EQUIZA N° 4246	BUENOS AIRES	LA MATANZA	GREGORIO DE LAFERRERE',
  'CENTRO DE SALUD F. GIOVINAZZO	FRANCISCO SEGUI 6164	BUENOS AIRES	LA MATANZA	ISIDRO CASANOVA',
  'POLICLINICO CENTRAL SAN JUSTO	ALMAFUERTE 3016	BUENOS AIRES	LA MATANZA	SAN JUSTO',
  'CENTRO DE SALUD N° 7 EIZAGUIRRE DE VILLA CELINA	GONZALEZ CHAVEZ Y JUAREZ CELMAN S/N BARRIO J. M. DE ROSAS	BUENOS AIRES	LA MATANZA	VILLA CELINA',
  'HOSPITAL REGIONAL RAMON JOSE CARCANO	AVENIDA GENERAL JUAN DOMINGO PERON 20	CORDOBA	PRESIDENTE ROQUE SÁENZ PEÑA	LABOULAYE',
  'HOSPITAL RURAL RIO SENGUER	BOSCO	CHUBUT	RÍO SENGUER	ALTO RIO SENGUER',
  'HOSPITAL PROVINCIAL MISION SAN FRANCISCO DE LAISHI	AV. 9 DE JULIO - MISION LAISHI	FORMOSA	LAISHI	SAN FRANCISCO DE LAISHI',
  'HOSPITAL PROVINCIAL LAS LOMITAS	AV. ENTRE RIOS Y SAAVEDRA S/N	FORMOSA	PATIÑO	LAS LOMITAS',
  'ESTABLECIMIENTO ASISTENCIAL DR. ANTONIO OLAIZ	Salta 165	LA PAMPA	ATREUCÓ	MIGUEL RIGLOS',
  'HOSPITAL DR. OSCAR H. COSTAS	Sarmiento esq. Aniceto Latorre - Joaquin V. Gonzalez	SALTA	ANTA	JOAQUIN V. GONZALEZ',
  'HOSPITAL DR. RAMON VILLAFAÑE	GRAL GÜEMES ESQ. LEGUIZAMÓN - APOLINARIO SARAVIA	SALTA	ANTA	APOLINARIO SARAVIA',
  'HOSPITAL DR. NICOLAS LOZANO	HIPOLITO YRIGOYEN 958	SALTA	CERRILLOS 	LA MERCED',
  'HOSPITAL SAN ROQUE	Perón esq. Córdoba	SALTA	GRL. JOSÉ DE SAN MARTÍN	EMBARCACION',
  'HOSPITAL ENFERMERA CORINA SANCHEZ DE BUSTAMANTE	Bº EL JARDIN	SALTA	LA CALDERA	LA CALDERA',
  'HOSPITAL ELISEO CANTON LULES	Belgrano 300	TUCUMAN	LULES	LULES',
  'HOSPITAL DE TRANCAS	AVENIDA HIPOLITO YRIGOYEN 161	TUCUMAN	TRANCAS	VILLA DE TRANCAS',
  'HOSPITAL DEL NIÑO JESUS	HUNGRIA 750	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'DISPENSARIO LA COSTANERA	ZIPOLI 700	CORDOBA	COLÓN	JESUS MARIA',
  'DISPENSARIO FLORIDA NORTE	AV. SAN MARTIN 598	CORDOBA	COLÓN	JESUS MARIA',
  'DISPENSARIO SIERRAS Y PARQUE	AV. SAN MARTIN 598	CORDOBA	COLÓN	JESUS MARIA',
  'HOSPITAL ILLIA	República de Bolivia s/n B°25 de Mayo	CORDOBA	COLÓN	LA CALERA',
  'CENTRO PERIFERICO Nº 15	17 de Octubre y Pasaje Público	CORDOBA	RÍO CUARTO	RIO CUARTO',
  'CENTRO DE SALUD Nº 13	PASAJE CABILDO DE LA CONCEPCION 650	CORDOBA	RÍO CUARTO	RIO CUARTO',
  'CENTRO ASISTENCIAL Nº 2 BARRIO CASTAGNINO	JUAN B. BUSTOS 213	CORDOBA	TERCERO ARRIBA	RIO TERCERO',
  'CENTRO DE SALUD PLAYA UNION	Avenida Juan Manuel de Rosas 450	CHUBUT	RAWSON	RAWSON',
  'C.A.P.S.  EVA PERON	PARANÁ S/Nº - STROBEL	ENTRE RIOS	DIAMANTE	STROBEL',
  'CENTRO DE SALUD LUIS MARIA CODDA BARRIO LIBORSI	CORRIENTES Y QUINTA PROYECTADA - BARRIO LIBORSI	FORMOSA	FORMOSA	PARQUE BOTÁNICO FORESTAL IGR L',
  'CIC SAN JOSE (4)	LA QUIACA ESQUINA LEON - BARRIO SAN JOSE	JUJUY	PALPALÁ 	PALPALA',
  'CAPS SANTA BARBARA (4)	AVENIDA MINA EL AGUILAR	JUJUY	PALPALÁ 	PALPALA',
  'CIC CANAL DE BEAGLE (4)	Quispe Esq. Chacho Peñaloza	JUJUY	PALPALÁ 	PALPALA',
  'DR. GUILLERMO FURST	MIGUEL CANE Nº 1175	LA PAMPA	CAPITAL	SANTA ROSA',
  'MARIA VIOLA (EX CENTRO DE SALUD AEROPUERTO)	CALLES CARLOS GARDEL Y CASTRO	LA PAMPA	CAPITAL	SANTA ROSA',
  'CENTRO DE SALUD BARRIO LA FALDA	PEHUEN S/Nº	NEUQUEN	PEHUENCHES	RINCON DE LOS SAUCES',
  'CENTRO DE SALUD Nº 54 BARRIO SAN IGNACIO	MANZANA 38 - BARRIO SAN IGNACIO	SALTA	CAPITAL	SALTA',
  'CIC EL CHAÑAR	25 de Mayo y JJ Paso	TUCUMAN	BURRUYACÚ	EL CHAÑAR',
  'CAPS MONSEÑOR DIAZ.	AVENIDA AMÉRICA Y 25 DE MAYO	TUCUMAN	CRUZ ALTA	LASTENIA',
  'DM COMPLEJO GUSTAVO LOPEZ	LAVALLE Y OBISPO COLOMBRES	TUCUMAN	CRUZ ALTA	BANDA DEL RIO SALI',
  'CAPS LA NUEVA ESPERANZA	PRINCIPAL S/N°	TUCUMAN	LULES	PARADA DE OHUANTA',
  'POSTA SANITARIA VILLA DEL ROSARIO	B° ALBERDI S/N°	TUCUMAN	LULES	INGENIO SAN PABLO',
  'CAPS BARRIO JARDIN	Azcuénaga 1070	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'CIC SAN FELIPE	JUJUY 4500 - BARRIO PARQUE SUR	TUCUMAN	CAPITAL	SAN MIGUEL DE TUCUMAN',
  'CAPS NRO 3  DR. TOMAS GONZALEZ	KARUKINKA Y KEKUMBOCH - BARRIO MARGEN SUR	TIERRA DEL FUEGO	RÍO GRANDE	RIO GRANDE',
];
