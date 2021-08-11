import 'dart:async';
import 'package:csv/csv.dart';
import 'package:fluffychat/components/connection_status_header.dart';
import 'package:fluffychat/components/dialogs/simple_dialogs.dart';

import 'package:fluffychat/components/list_items/situacion_list_item.dart';
import 'package:fluffychat/stats_dashboard/widgets/drawer_ive.dart';
import 'package:fluffychat/views/situaciones_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';

import 'dart:convert';
import 'dart:html' as html;

import '../stats_dashboard/models/situacion_model.dart';
import '../components/adaptive_page_layout.dart';
import '../components/matrix.dart';
import '../utils/app_route.dart';

enum SelectMode { normal, share, select }

class SituacionesListRefactorView extends StatelessWidget {
  SituacionesListRefactorView({this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.FIRST,
      firstScaffold: SituacionesListRefactor(
        userId: userId,
      ),
      secondScaffold: Scaffold(
        body: Center(
          child: Image.asset('assets/logo.png', width: 100, height: 100),
        ),
      ),
    );
  }
}

class SituacionesListRefactor extends StatefulWidget {
  final int activeChat;
  final String userId;

  const SituacionesListRefactor({this.activeChat, this.userId, Key key})
      : super(key: key);

  @override
  _SituacionesListRefactorState createState() =>
      _SituacionesListRefactorState();
}

class _SituacionesListRefactorState extends State<SituacionesListRefactor> {
  dynamic listadoParaExporta;

  Future _getSituaciones() async {
    print('ENtro get situaciones');
    var situacionesInfoJson =
        await DashboardService().getSituaciones(widget.userId);

    var parsedJson = json.decode(situacionesInfoJson);

    listadoParaExporta = parsedJson;

    var situaciones = parsedJson.map((i) => Situacion.fromJson(i)).toList();

    return situaciones;
  }

  void logoutAction(BuildContext context) async {
    if (await SimpleDialogs(context).askConfirmation() == false) {
      return;
    }
    var matrix = Matrix.of(context);
    await SimpleDialogs(context)
        .tryRequestWithLoadingDialog(matrix.client.logout());
  }

  void _drawerTapAction(Widget view) {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute.defaultRoute(
        context,
        view,
      ),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerIle(),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.5,
        titleSpacing: 0,
        title: Container(
          height: 40,
          padding: EdgeInsets.only(left: 284),
          child: ListTile(
            leading: Icon(Icons.archive),
            onTap: () => downloadFile(listadoParaExporta),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                AppRoute.defaultRoute(context, SituacionFormView()),
                (r) => r.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionStatusHeader(),
          Expanded(
            child: FutureBuilder(
              future: _getSituaciones(),
              builder:
                  (BuildContext context, AsyncSnapshot snapshotSituaciones) {
                if (snapshotSituaciones.hasData) {
                  List situaciones = snapshotSituaciones.data;
                  final totalCount = situaciones.length;

                  return ListView.separated(
                    itemCount: totalCount,
                    separatorBuilder: (BuildContext context, int i) =>
                        i == totalCount
                            ? ListTile(
                                title: Text(
                                  L10n.of(context).publicRooms + ':',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Container(),
                    itemBuilder: (BuildContext context, int i) {
                      if (i == 0) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 1,
                            ),
                          ],
                        );
                      }
                      i--;
                      return i < situaciones.length
                          ? SituacionListItem(
                              situaciones[i],
                              onTap: () {
                                _drawerTapAction(
                                  SituacionFormView(
                                    situacion: situaciones[i],
                                    // roomId: rooms[i].id,
                                  ),
                                );
                              },
                              situacionFueSleccionada:
                                  widget.activeChat == situaciones[i].id,
                            )
                          : Container();
                    },
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void downloadFile(listadoParaExporta) {
  List listadoParaExportaSituaciones =
      listadoParaExporta.map((i) => Situacion.fromJson(i)).toList();

  // Titulos columna excel
  // ignore: omit_local_variable_types
  List<List<dynamic>> listadoCompleto = [
    [
      'ID',
      'Efector',
      'Fecha Consulta',
      'DNI',
      'Nombre',
      'Apellido',
      'Fecha de Nacimiento',
      'Identidad de genero',
      'Discapacidad',
      'Obra Social',
      'Partos',
      'Cesareas',
      'Abortos',
      'Consulta Situacion',
      'Semanas Gestacion',
      'Causal consulta',
      'Origen Consulta',
      'Derivacion',
      'Efector Derivacion',
      'Motivo Derivacion',
      'Fecha tratamiento',
      'Tipo tratamiento',
      'Comprimidos tratamiento',
      'Quirurgico',
      ' Semanas Resolucion',
      'Complicaciones',
      'AIPE',
      'Observaciones'
    ]
  ];

  for (Situacion situacion in listadoParaExportaSituaciones) {
    var listaSituacion = [];

    listaSituacion.add(situacion.id);
    listaSituacion.add(situacion.efector);
    listaSituacion.add(situacion.persona_consulta_fecha);
    listaSituacion.add(situacion.persona_dni);
    listaSituacion.add(situacion.persona_nombre);
    listaSituacion.add(situacion.persona_apellido);
    listaSituacion.add(situacion.persona_nacimiento_fecha);
    listaSituacion.add(situacion.persona_identidad_de_genero);
    listaSituacion.add(situacion.persona_con_discapacidad);
    listaSituacion.add(situacion.persona_obra_social);
    listaSituacion.add(situacion.partos);
    listaSituacion.add(situacion.cesareas);
    listaSituacion.add(situacion.abortos);
    listaSituacion.add(situacion.consulta_situacion);
    listaSituacion.add(situacion.semanas_gestacion);
    listaSituacion.add(situacion.consulta_causal);
    listaSituacion.add(situacion.consulta_origen);
    listaSituacion.add(situacion.consulta_derivacion);
    listaSituacion.add(situacion.derivacion_efector);
    listaSituacion.add(situacion.derivacion_motivo);
    listaSituacion.add(situacion.tratamiento_fecha);
    listaSituacion.add(situacion.tratamiento_tipo);
    listaSituacion.add(situacion.tratamiento_comprimidos);
    listaSituacion.add(situacion.tratamiento_quirurgico);
    listaSituacion.add(situacion.semanas_resolucion);
    listaSituacion.add(situacion.complicaciones);
    listaSituacion.add(situacion.aipe);
    listaSituacion.add(situacion.observaciones);

    listadoCompleto.add(listaSituacion);
  }

  final bytes = const ListToCsvConverter().convert(listadoCompleto);

  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = 'listado_situaciones.csv';
  html.document.body.children.add(anchor);

  // download
  anchor.click();

  // cleanup
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
