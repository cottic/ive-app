import 'package:fluffychat/provider/situaciones_provider.dart';
import 'package:fluffychat/stats_dashboard/models/situacion_model.dart';
import 'package:fluffychat/views/situaciones_list_refactor.dart';
import 'package:flutter/material.dart';

import '../components/adaptive_page_layout.dart';
import '../components/matrix.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class SituacionFormView extends StatelessWidget {
  const SituacionFormView({this.situacion});

  final Situacion situacion;

  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: SituacionesListRefactor(),
      secondScaffold: SituacionesForm(),
    );
  }
}

class SituacionesForm extends StatefulWidget {
  @override
  _SituacionesFormState createState() => _SituacionesFormState();
}

class _SituacionesFormState extends State<SituacionesForm> {
  double semanasResolucionMin = 5.0;
  bool showTratamiento = true;
  bool isCausalEnabled = true;

  final _formKey = GlobalKey<FormBuilderState>();

  int calculateDifference(DateTime date, DateTime compare) {
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(compare.year, compare.month, compare.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SituacionesProvider>(
      builder: (context, situacionesProvider, child) {
        final client = Matrix.of(context).client;
        final username = client.userID;
        var efectorName = '';
        var efector = '';

        if (username == '@maria.jose.mattioli:siilve.codigoi.com.ar') {
          efectorName = 'Hospital de Clínicas “José de San Martín”';
          efector = '10020012515209';
        } else if (username == '@julieta.minasi:siilve.codigoi.com.ar' ||
            username == '@graciela.beatriz.rodriguez:siilve.codigoi.com.ar' ||
            username == '@maria.elida.del.pino:siilve.codigoi.com.ar') {
          efectorName = 'Hospital Iriarte (Quilmes)”';
          efector = '10060582100385';
        } else if (username == '@juanma:siilve.codigoi.com.ar' ||
            username == '@estefania.cioffi:siilve.codigoi.com.ar') {
          efectorName =
              'HOSPITAL SUBZONAL ESPECIALIZADO MATERNO INFANTIL SAN FRANCISCO SOLANO”';
          efector = '12060582200557';
        } else {
          efectorName = 'Hospital General de Agudos “Dr. Teodoro Álvarez”';
          efector = '10020012215221';
        }

        if (situacionesProvider.isLoading != null) {
          if (situacionesProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
        if (situacionesProvider.situacionActiva == null) {
          return Scaffold(
            body: Center(
              child: Image.asset('assets/logo.png', width: 100, height: 100),
            ),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    //TODO: implementar
                    situacionesProvider.situacionActiva.id != 1
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
                  initialValue:
                      context.watch<SituacionesProvider>().initialValues,
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        allowClear: true,
                        initialValue:
                            situacionesProvider.initialValues['efector'],
                        hint: Text('Efector:'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: '* Requerido',
                          )
                        ]),
                        items: [
                          DropdownMenuItem(
                            value: efector,
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
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
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(context,
                                errorText: '* Requerido'),
                            FormBuilderValidators.maxLength(context, 2,
                                errorText: 'Solo las 2 primeras letras'),
                            FormBuilderValidators.match(context, '[A-Za-z]',
                                errorText: 'Solo se permiten letras'),
                          ],
                        ),
                      ),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'mujer', child: Text('Mujer')),
                          FormBuilderFieldOption(
                              value: 'trans', child: Text('Transgenero')),
                          FormBuilderFieldOption(
                              value: 'otra',
                              child:
                                  Text('Otra identidad de género no binaria')),
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
                          labelText:
                              '¿Se trata de una persona con discapacidad?',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            height: 1.0,
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'si', child: Text('Si')),
                          FormBuilderFieldOption(
                              value: 'no', child: Text('No')),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'si', child: Text('Si')),
                          FormBuilderFieldOption(
                              value: 'no', child: Text('No')),
                        ],
                      ),
                      FormBuilderTouchSpin(
                        decoration: InputDecoration(
                          labelText: 'partos',
                          labelStyle: TextStyle(
                            fontSize: 20,
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'ive', child: Text('IVE')),
                          FormBuilderFieldOption(
                              value: 'ile', child: Text('ILE')),
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
                                value: 'vida',
                                child: Text('Riesgo para la vida')),
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
                            final selected = _formKey.currentState
                                .fields['consulta-situacion']?.value;
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                              child: Text(
                                  'Por una organización de la soc. civil')),
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                          FormBuilderFieldOption(
                              value: 'si', child: Text('Si')),
                          FormBuilderFieldOption(
                              value: 'no', child: Text('No')),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context,
                              errorText: '* Requerido')
                        ]),
                      ),
                      /* FormBuilderDropdown(
                        name: 'derivacion-efector',
                        decoration: InputDecoration(
                          labelText: 'Efector:',
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        allowClear: true,
                        initialValue: situacionesProvider
                            .initialValues['derivacion-efector'],
                        hint: Text('Efector:'),
                        validator: (val) {
                          final selected = _formKey.currentState
                              .fields['consulta-derivacion']?.value;
                          if (selected == 'si') {
                            if (val == 0) {
                              return '* Requerido';
                            }
                          }
                          return null;
                        },
                        items: getDropDownListDerivacionEfectores(
                            mapaDerivacionEfectores),
                      ), */
/*  DropdownSearch<UserModel>(
                        label: 'Name',
                        onFind: (String filter) => getData(filter),
                        itemAsString: (UserModel u) => u.userAsString(),
                        onChanged: (UserModel data) => print(data),
                      ),

                      DropdownSearch<UserModel>(
                        label: 'Name2',
                        onFind: (String filter) => getData(filter),
                        itemAsString: (UserModel u) => u.userAsString(),
                        onChanged: (UserModel data) => print(data),
                      ), */
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FormBuilderTypeAhead(
                              decoration: InputDecoration(
                                labelText: 'Efector al que fue derivado',
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                              ),
                              name: 'derivacion-efector',
                              onChanged: (value) {},
                              validator: (val) {
                                var estaEnLaLista = situacionesProvider
                                    .listadoNombresEfectores
                                    .where((element) => element == val);

                                final selected = _formKey.currentState
                                    .fields['consulta-derivacion']?.value;
                                if (selected == 'si') {
                                  if (val == null || val.isEmpty) {
                                    return '* Requerido';
                                  }
                                  if (estaEnLaLista.isEmpty) {
                                    return '* Requerido';
                                  }
                                }

                                return null;
                              },
                              valueTransformer: (value) => situacionesProvider
                                  .transfromStringToIntInEfectores(value),
                              getImmediateSuggestions: true,
                              noItemsFoundBuilder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No se encontraron resultados',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                              itemBuilder: (context, listadoEfectores) {
                                return ListTile(
                                  title: Text(listadoEfectores),
                                );
                              },
                              controller: TextEditingController(
                                  text: situacionesProvider
                                      .initialValues['derivacion-efector']),
                              suggestionsCallback: (query) {
                                if (query.isNotEmpty) {
                                  var lowercaseQuery = query.toLowerCase();
                                  return situacionesProvider
                                      .listadoNombresEfectores
                                      .where((efectores) {
                                    return efectores
                                        .toLowerCase()
                                        .contains(lowercaseQuery);
                                  }).toList(growable: true)
                                        ..sort((a, b) => a
                                            .toLowerCase()
                                            .indexOf(lowercaseQuery)
                                            .compareTo(b
                                                .toLowerCase()
                                                .indexOf(lowercaseQuery)));
                                } else {
                                  return situacionesProvider
                                      .listadoNombresEfectores;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 38.0),
                            child: IgnorePointer(
                                child: RaisedButton(
                              child: Text('Buscar'),
                              onPressed: () {},
                            )),
                          ),
                        ],
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
                          contentPadding:
                              EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'edad', child: Text('Edad gestacional')),
                          FormBuilderFieldOption(
                              value: 'falla',
                              child: Text('Falla de tratamiento')),
                          FormBuilderFieldOption(
                              value: 'contraindicacion',
                              child:
                                  Text('Contraindicacion de Tto ambulatorio')),
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
                          final selected = _formKey.currentState
                              .fields['consulta-derivacion']?.value;
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
                              _formKey.currentState
                                  .fields['tratamiento-comprimidos']
                                  .didChange(0);
                              _formKey.currentState.save();
                            }
                            if (val == 'farmacologico') {
                              _formKey
                                  .currentState.fields['tratamiento-quirurgico']
                                  .didChange('no-corresponde');
                              _formKey.currentState.save();
                            }
                          },
                          validator: (val) {
                            final selected = _formKey.currentState
                                .fields['consulta-derivacion']?.value;
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
                            final selected = _formKey.currentState
                                .fields['consulta-derivacion']?.value;
                            if (selected == 'no') {
                              final selected2 = _formKey.currentState
                                  .fields['tratamiento-tipo']?.value;
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
                            final selected = _formKey.currentState
                                .fields['semanas-gestacion']?.value;
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
                            FormBuilderFieldOption(
                                value: 'No', child: Text('no')),
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
                            final selected = _formKey.currentState
                                .fields['consulta-derivacion']?.value;
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
                            FormBuilderFieldOption(
                                value: 'No', child: Text('no')),
                            FormBuilderFieldOption(
                                value: 'anticoncepcion-oral',
                                child: Text('Anticoncepción Hormonal Oral')),
                            FormBuilderFieldOption(
                                value: 'anticoncepcion-inyectable',
                                child:
                                    Text('Anticoncepción Hormonal Inyectable')),
                            FormBuilderFieldOption(
                                value: 'diu', child: Text('DIU')),
                            FormBuilderFieldOption(
                                value: 'implante',
                                child: Text('Implante subdérmico')),
                            FormBuilderFieldOption(
                                value: 'siu', child: Text('SIU')),
                            FormBuilderFieldOption(
                                value: 'preservativo',
                                child: Text('Preservativo')),
                            FormBuilderFieldOption(
                                value: 'preservativo-hormonal',
                                child: Text(
                                    'Preservativo + Anticonceptivo Hormonal')),
                            FormBuilderFieldOption(
                                value: 'preservativo-diu',
                                child:
                                    Text('Preservativo + DIU, SIU o implante')),
                            FormBuilderFieldOption(
                                value: 'ligadura-tubaria',
                                child: Text('Ligadura tubaria')),
                          ],
                          validator: (val) {
                            final selected = _formKey.currentState
                                .fields['consulta-derivacion']?.value;
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
                            print('_formKey.currentState.value');
                            print(_formKey.currentState.value);

                            situacionesProvider.enviarSituacion(
                                json.encode(_formKey.currentState.value));

                            /* final selected =
                                _formKey.currentState.fields['id']?.value;
                            if (selected == 1) {
                              _formKey.currentState.reset();
                            } */

                            FocusScope.of(context).requestFocus(FocusNode());
                            FocusScope.of(context).unfocus();

                            /* ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    duration: Duration(seconds: 6),
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    content: Text(
                                        'El registro se guardo correctamente')), 
                              );*/
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 6),
                                backgroundColor: Colors.redAccent,
                                content: Text('El formulario esta incompleto'),
                              ),
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
      },
    );
  }
}
