import 'package:flutter/material.dart';

import 'chat_list.dart';
import '../components/adaptive_page_layout.dart';
import '../components/dialogs/simple_dialogs.dart';
import '../components/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class EniaMenuView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: ChatList(),
      secondScaffold: EniaMenu(),
    );
  }
}

class EniaMenu extends StatefulWidget {
  @override
  _EniaMenuState createState() => _EniaMenuState();
}

class _EniaMenuState extends State<EniaMenu> {
  Future<dynamic> profileFuture;
  dynamic profile;
  Future<bool> crossSigningCachedFuture;
  bool crossSigningCached;
  Future<bool> megolmBackupCachedFuture;
  bool megolmBackupCached;
  String bullet = '\u2022';
  double semanasResolucionMin = 5.0;

  final _formKey = GlobalKey<FormBuilderState>();

  var tipoEfectorOptions = [
    'HOSPITAL DRA. CECILIA GRIERSON (JUAN BAUTISTA ALBERDI 38, GUERNICA, BUENOS AIRES)',
    'UNIDAD SANITARIA GLEW II (DE NAVAZIO Y DI CARLO S/N BO. ALMAFUERTE - GLEW, GLEW, BUENOS AIRES)'
  ];

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

  Future<void> sendFormToApi(formdata) async {
    var barChartInfoJson = await DashboardService().sendFormToApi(formdata);

    return barChartInfoJson;
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    profileFuture ??= client.ownProfile.then((p) {
      if (mounted) setState(() => profile = p);
      return p;
    });
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
                'Formulario IVE/ILE',
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
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  FormBuilderDropdown(
                    name: 'efector',
                    decoration: InputDecoration(
                      labelText: 'Efector:',
                    ),
                    allowClear: true,
                    hint: Text('Efector:'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        context,
                        errorText: '* Requerido',
                      )
                    ]),
                    items: tipoEfectorOptions
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text('$gender'),
                            ))
                        .toList(),
                  ),
                  ListTile(
                    title: Text(
                      'Datos de la persona',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                  FormBuilderDateTimePicker(
                    name: 'date',
                    format: DateFormat('dd/MM/yyyy'),
                    // onChanged: (value){},
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'Fecha de consulta',
                    ),
                    initialValue: DateTime.now(),
                    // enabled: true,
                  ),
                  FormBuilderTextField(
                    name: 'dni',
                    decoration: InputDecoration(
                      labelText: 'DNI',
                    ),
                    onChanged: (value) {},
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(context,
                          errorText: 'Solo se permiten números'),
                      FormBuilderValidators.minLength(context, 8,
                          allowEmpty: true,
                          errorText: 'No es un formato de DNI válido'),
                      FormBuilderValidators.maxLength(context, 8,
                          errorText:
                              'Los DNI solo pueden tener hasta 8 digitos'),
                    ]),
                    keyboardType: TextInputType.number,
                  ),
                  FormBuilderTextField(
                      name: '2nombre',
                      maxLengthEnforced: true,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'Primeras 2 letras del nombre',
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
                  FormBuilderTextField(
                      name: '2apellido',
                      maxLengthEnforced: true,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'Primeras 2 letras del apellido',
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
                    name: 'fecha-de-nacimiento',
                    format: DateFormat('dd/MM/yyyy'),
                    // onChanged: (value){},
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                    ),
                    // enabled: true,
                  ),
                  FormBuilderChoiceChip(
                    name: 'identidad-de-genero',
                    spacing: 20.0,
                    decoration: InputDecoration(
                      labelText: 'Identidad de género',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'mujer', child: Text('Mujer')),
                      FormBuilderFieldOption(
                          value: 'varon-trans', child: Text('Varón trans')),
                      FormBuilderFieldOption(
                          value: 'otra',
                          child: Text('Otra identidad de género no binaria')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ),
                  FormBuilderChoiceChip(
                    name: 'con-discapacidad',
                    spacing: 20.0,
                    decoration: InputDecoration(
                      labelText: '¿Se trata de una persona con discapacidad?',
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(
                          value: 'no', child: Text('No esta consignado')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    name: 'obra-social',
                    spacing: 20.0,
                    decoration: InputDecoration(
                      labelText: '¿Tiene obra social?',
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(value: 'no', child: Text('No')),
                    ],
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(labelText: 'partos'),
                    name: 'partos',
                    initialValue: 0,
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(labelText: 'cesareas'),
                    name: 'cesareas',
                    initialValue: 0,
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  FormBuilderTouchSpin(
                    decoration: InputDecoration(labelText: 'abortos'),
                    name: 'abortos',
                    initialValue: 0,
                    step: 1,
                    min: 0,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
                  ListTile(
                    title: Text(
                      'Datos del caso',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 4.0,
                      ),
                    ),
                  ),
                  FormBuilderSlider(
                    name: 'semanas-gestacion',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.min(context, 5),
                    ]),
                    displayValues: DisplayValues.current,
                    min: 5.0,
                    max: 32.0,
                    initialValue: 14.6,
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
                      if (integerVal > 14) {
                        _formKey.currentState.fields['consulta-situacion']
                            .didChange('ile');
                        _formKey.currentState.fields['consulta-situacion'];
                        _formKey.currentState.save();
                      }
                    },
                    activeColor: Colors.red,
                    inactiveColor: Colors.pink[100],
                    decoration: InputDecoration(
                      labelText:
                          'Semanas de gestación al inicio de la consulta',
                    ),
                  ),
                  FormBuilderChoiceChip(
                    name: 'consulta-situacion',
                    spacing: 20.0,
                    decoration: InputDecoration(
                      labelText: 'La situación se encuadra como',
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
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    name: 'consulta-causal',
                    decoration: InputDecoration(
                      labelText: 'Causal',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'vida', child: Text('Riesgo para la vida')),
                      FormBuilderFieldOption(
                          value: 'salud', child: Text('Riesgo para la salud')),
                      FormBuilderFieldOption(
                          value: 'violacion', child: Text('Violación')),
                      FormBuilderFieldOption(
                          value: 'no-corresponde',
                          child: Text('No corresponde')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    name: 'consulta-origen',
                    decoration: InputDecoration(
                      labelText: '¿Cómo llega a la consulta?',
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
                          child: Text('Programa SSYR / 0800')),
                      FormBuilderFieldOption(
                          value: 'por-desicion-propia',
                          child: Text('Por desición propia')),
                      FormBuilderFieldOption(
                          value: 'otro', child: Text('Otro')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    name: 'consulta-derivacion',
                    decoration: InputDecoration(
                      labelText: 'Derivado a otro efector:',
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'si', child: Text('Si')),
                      FormBuilderFieldOption(value: 'no', child: Text('No')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  FormBuilderTypeAhead(
                    decoration: InputDecoration(
                      labelText: 'Efector al que fue derivado',
                    ),
                    name: 'derivacion-efector',
                    onChanged: (value) {},
                    itemBuilder: (context, country) {
                      return ListTile(
                        title: Text(country),
                      );
                    },
                    controller: TextEditingController(text: ''),
                    // initialValue: 'Uganda',
                    suggestionsCallback: (query) {
                      if (query.isNotEmpty) {
                        var lowercaseQuery = query.toLowerCase();
                        return allEfectores.where((country) {
                          return country.toLowerCase().contains(lowercaseQuery);
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
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    runSpacing: 20.0,
/*                     labelPadding: EdgeInsets.symmetric(vertical: 10.0), */
                    name: 'derivacion-motivo',
                    decoration: InputDecoration(
                      labelText: '¿Porque motivo fue derivado?',
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
                          value: 'no', child: Text('No corresponde')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ),
                  ListTile(
                    title: Text(
                      'Datos del tratamiento',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        height: 4.0,
                      ),
                    ),
                  ),
                  FormBuilderDateTimePicker(
                    name: 'tratamiento-fecha',
                    // onChanged: (value){},
                    inputType: InputType.date,
                    decoration: InputDecoration(
                      labelText:
                          'Fecha de provisión de tratamiento farmacológico o quirúrgico',
                    ),
                    initialValue: DateTime.now(),
                    // enabled: true,
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    name: 'tratamiento-tipo',
                    decoration: InputDecoration(
                      labelText: 'Tipo de tratamiento',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'farmacologico', child: Text('Farmacológico')),
                      FormBuilderFieldOption(
                          value: 'quirurgico', child: Text('Quirúrgico')),
                      FormBuilderFieldOption(
                          value: 'farmacologico-y-quirurgico',
                          child: Text('Farmacológico y Quirúrgico')),
                    ],
                    onChanged: (val) {
                      if (val == 'quirurgico') {
                        _formKey.currentState.fields['tratamiento-comprimidos']
                            .didChange(0);
                        _formKey.currentState.save();
                      }
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ),
                  FormBuilderTouchSpin(
                    decoration:
                        InputDecoration(labelText: 'Cantidad de comprimidos'),
                    name: 'tratamiento-comprimidos',
                    initialValue: 0,
                    min: 0,
                    step: 1,
                    iconSize: 48.0,
                    addIcon: Icon(Icons.arrow_right),
                    subtractIcon: Icon(Icons.arrow_left),
                  ),
/*                   FormBuilderChoiceChip(
                    spacing: 20.0,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    name: 'tratamiento-via',
                    decoration: InputDecoration(
                      labelText: 'Vía de administración',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'vaginal', child: Text('Vaginal')),
                      FormBuilderFieldOption(
                          value: 'sublingual', child: Text('Sublingual')),
                      FormBuilderFieldOption(
                          value: 'bucal', child: Text('Bucal')),
                      FormBuilderFieldOption(
                          value: 'Mas-de-una', child: Text('Más de una')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ), */
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    name: 'tratamiento-quirurgico',
                    decoration: InputDecoration(
                      labelText: 'Tratamiento Quirúrgico',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'ameu', child: Text('AMEU')),
                      FormBuilderFieldOption(
                          value: 'rue-o-legrado', child: Text('RUE o Legrado')),
                      FormBuilderFieldOption(
                          value: 'ameurue', child: Text('AMEU + RUE')),
                      FormBuilderFieldOption(
                          value: 'dilatacion-evacuacion',
                          child: Text('Dilatación y evacuación')),
                      FormBuilderFieldOption(
                          value: 'otros', child: Text('Otros')),
                      FormBuilderFieldOption(
                          value: 'sin-datos', child: Text('Sin datos')),
                    ],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: "* Requerido")
                    ]),
                  ),
                  FormBuilderSlider(
                    name: 'semanas-resolucion',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.min(context, 5),
                    ]),
                    displayValues: DisplayValues.current,
                    onChanged: (value) {},
                    min: semanasResolucionMin,
                    max: 32.0,
                    initialValue: 14.6,
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
                    ),
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    name: 'complicaciones',
                    decoration: InputDecoration(
                      labelText: 'Hubo complicaciones. ¿Cual?',
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  FormBuilderChoiceChip(
                    spacing: 20.0,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    name: 'aipe',
                    decoration: InputDecoration(
                      labelText:
                          'Provisión de Anticoncepción Inmediata Post Aborto ¿Que método?',
                    ),
                    options: [
                      FormBuilderFieldOption(value: 'No', child: Text('no')),
                      FormBuilderFieldOption(
                          value: 'anticoncepcion-oral',
                          child: Text('Anticoncepción Hormonal Oral')),
                      FormBuilderFieldOption(
                          value: 'anticoncepcion-inyectable',
                          child: Text('Anticoncepción Hormonal Inyectable')),
                      FormBuilderFieldOption(value: 'diu', child: Text('DIU')),
                      FormBuilderFieldOption(
                          value: 'implante',
                          child: Text('Implante subdérmico')),
                      FormBuilderFieldOption(value: 'siu', child: Text('SIU')),
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '* Requerido')
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'observaciones',
                    decoration: InputDecoration(
                      labelText: 'Observaciones',
                    ),
                    onChanged: (value) {},
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
                      "Guardar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _formKey.currentState.save();
                      if (_formKey.currentState.validate()) {
                        sendFormToApi(_formKey.currentState.value.toString());

                        print(_formKey.currentState.value);
                        _formKey.currentState.reset();

                        FocusScope.of(context).unfocus();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              duration: Duration(seconds: 3),
                              backgroundColor: Theme.of(context).primaryColor,
                              content:
                                  Text('El registro se guardo correctamente')),
                        );
                      } else {
                        print("La validación del formulario falló");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                  'Revisar el formulario. Esta incompleto')),
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
  'UNIDAD SANITARIA GLEW II	DE NAVAZIO Y DI CARLO S/N BO. ALMAFUERTE - GLEW	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  'UNIDAD SANITARIA N° 10 28 DE DICIEMBRE DE RAFAEL CALZADA	GORRION ENTRE JORGE Y ARROYO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  'UNIDAD SANITARIA N° 11 LA GLORIA DE SAN JOSE	LA CALANDRIA ENTRE BYNON Y MITRE S/N LA TABLADA SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  'UNIDAD SANITARIA N° 12 DON ORIONE DE CLAYPOLE	CALLE 11 Y AV. EVA PERON - BARRIO DON ORIONE	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  'UNIDAD SANITARIA N° 13 DE BURZACO	ALSINA Y MARTIN FIERRO	BUENOS AIRES	ALMIRANTE BROWN	BURZACO',
  'UNIDAD SANITARIA N° 16 DE RAFAEL CALZADA	AV. SAN MARTIN 4900 Y SAN CARLOS BARRIO SAN GERONIMO RAFAEL CALZADA	BUENOS AIRES	ALMIRANTE BROWN	RAFAEL CALZADA',
  'UNIDAD SANITARIA N° 4 SAN JOSE DE ALMIRANTE BROWN	SAN LUIS 166 SAN JOSE	BUENOS AIRES	ALMIRANTE BROWN	SAN JOSE',
  'UNIDAD SANITARIA N° 7 13 DE JULIO DE CLAYPOLE	ANEMONAS 6545 ENTRE CLAVEL Y CAMELIA	BUENOS AIRES	ALMIRANTE BROWN	CLAYPOLE',
  'UNIDAD SANITARIA Nº 23 RAMON CARRILLO	ZUFRIATEGUI 3550	BUENOS AIRES	ALMIRANTE BROWN	GLEW',
  'CENTRO DE ATENCION PRIMARIA DE LA SALUD SAKURA	MOLINA MASSEY 3212 E/ LORETO Y MONTE SANTIAGO	BUENOS AIRES	ALMIRANTE BROWN	LONGCHAMPS',
  'UNIDAD SANITARIA E. MAGUILLANSKY N° 1	CALLE 38 1169 BARRIO SAN FRANCISCO	BUENOS AIRES	AZUL	AZUL',
  'UNIDAD SANITARIA N° 44 DR RAMON CARRILLO	CALLE 122 BIS	BUENOS AIRES	BERISSO	BERISSO',
  'CENTRO PERIFERICO N° 4 DE CAMPANA	ZARATE ENTRE S.DELLEPIANE Y UGARTEMENDIA - SAN CAYETANO	BUENOS AIRES	CAMPANA	CAMPANA',
  'UNIDAD SANITARIA SAGRADO CORAZON DE JESUS MAXIMO PAZ	PERU Y BENAVIDEZ S/Nº Bº SAN CARLOS	BUENOS AIRES	CAÑUELAS	MAXIMO PAZ',
  'CENTRO DE ATENCION PRIMARIA DR. PASCUAL GUIDICE	ESTADOS UNIDOS Y SAN MARTIN	BUENOS AIRES	ENSENADA	ENSENADA',
  'UNIDAD SANITARIA 1° DE MAYO DE ENSENADA	ECUADOR Y SAENZ PEÑA BARRIO 1° DE MAYO 17	BUENOS AIRES	ENSENADA	ENSENADA',
  'UNIDAD SANITARIA N° 5	BELGRANO Y CANALE	BUENOS AIRES	EZEIZA	TRISTAN SUAREZ',
  'UNIDAD SANITARIA BARRIO 2 DE ABRIL DE MAR DEL PLATA	SOLDADO PACHEOLZUK 850 - BARRIO 2 DE ABRIL	BUENOS AIRES	GENERAL PUEYRREDON	PUNTA MOGOTES',
  'SUBCENTRO DE SALUD JORGE NEWBERY	MORENO 9375 - BARRIO JORGE NEWBERY	BUENOS AIRES	GENERAL PUEYRREDON	MAR DEL PLATA',
  'UNIDAD SANITARIA MARENGO	CALLE 51 (REPUBLICA) 10 ESQUINA CALLE 110 (PUEYRREDON)	BUENOS AIRES	GENERAL SAN MARTIN	VILLA BALLESTER',
  'UNIDAD SANITARIA BARRIO ANGEL	POTOSI Y LEVALLE - BARRIO SAN DAMIAN	BUENOS AIRES	HURLINGHAM	HURLINGHAM',
  'HOSPITAL DE ATENCION MEDICA PRIMARIA DE ITUZAINGO	BRANDSEN 3859	BUENOS AIRES	ITUZAINGO	ITUZAINGO SUR',
  'CENTRO DE SALUD SAKAMOTO	NICOLAS DAVILA 2110	BUENOS AIRES	LA MATANZA	RAFAEL CASTILLO',
  'CENTRO DE SALUD LA LOMA	LOS HELECHOS ESQUINA LOS TULIPANES S/N BARRIO LA LOMA	BUENOS AIRES	LUJAN	LUJAN',
  'UNIDAD SANITARIA BARRIO LOS LAURELES	LAS ESTRELLAS Y VENUS S/N BARRIO LOS LAURELES	BUENOS AIRES	LUJAN	LUJAN',
  'UNIDAD SANITARIA N° 11 DE MERLO	AV. SAN MARTIN Y BARILOCHE	BUENOS AIRES	MERLO	MERLO',
  'UNIDAD SANITARIA N° 4 LA FORTUNA DE MORENO	ENRIQUE LARRETA 10471	BUENOS AIRES	MORENO	TRUJUI',
  'UNIDAD SANITARIA SAMBRIZZI SANGUINETTI	CORRIENTES 2301 - BARRIO SANGUINETTI	BUENOS AIRES	MORENO	PASO DEL REY',
  'CENTRO DE SALUD MERCEDES SOSA	EVA PERON ESQUINA BARADERO	BUENOS AIRES	MORON	MORON',
  'CENTRO DE SALUD SANTA LAURA	GRAL. CORNELIO SAAVEDRA 1265 - BARRIO SANTA LAURA	BUENOS AIRES	MORON	MORON',
  'UNIDAD SANITARIA PRESIDENTE IBAÑEZ	PRESIDENTE IBAÑEZ 1824 - BARRIO SAN JOSE	BUENOS AIRES	MORON	MORON',
  'CENTRO DE ATENCION PRIMARIA RAMON CARRILLO DE PERGAMINO	DEAN FUNES Y COSTA RICA BARRIO GUEMES	BUENOS AIRES	PERGAMINO	PERGAMINO',
  'UNIDAD SANITARIA VILLA ROSA	SERRANO Y PERON	BUENOS AIRES	PILAR	VILLA ROSA'
];

const contacts = <Contact>[
  Contact('Andrew', 'stock@man.com',
      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
  Contact('Paul', 'paul@google.com',
      'https://media.istockphoto.com/photos/man-with-crossed-arms-isolated-on-gray-background-picture-id1171169099'),
  Contact('Fred', 'fred@google.com',
      'https://media.istockphoto.com/photos/confident-businessman-posing-in-the-office-picture-id891418990'),
  Contact('Brian', 'brian@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('John', 'john@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Thomas', 'thomas@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Nelly', 'nelly@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Marie', 'marie@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Charlie', 'charlie@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Diana', 'diana@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Ernie', 'ernie@flutter.io',
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
  Contact('Gina', 'gina@flutter.io',
      'https://media.istockphoto.com/photos/all-set-for-a-productive-night-ahead-picture-id637233964'),
];
