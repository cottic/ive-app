import 'package:csv/csv.dart';
import 'package:fluffychat/components/connection_status_header.dart';

import 'package:fluffychat/components/list_items/situacion_list_item.dart';
import 'package:fluffychat/provider/situaciones_provider.dart';
import 'package:fluffychat/stats_dashboard/widgets/drawer_ive.dart';
import 'package:fluffychat/views/situaciones_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';

import 'dart:html' as html;

import '../stats_dashboard/models/situacion_model.dart';
import '../components/adaptive_page_layout.dart';
import '../utils/app_route.dart';

enum SelectMode { normal, share, select }

class SituacionesListRefactorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.FIRST,
      firstScaffold: SituacionesListRefactor(),
      secondScaffold: SituacionesForm(),
    );
  }
}

class SituacionesListRefactor extends StatefulWidget {
  final int activeChat;

  const SituacionesListRefactor({this.activeChat, Key key}) : super(key: key);

  @override
  _SituacionesListRefactorState createState() =>
      _SituacionesListRefactorState();
}

class _SituacionesListRefactorState extends State<SituacionesListRefactor> {
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
  void initState() {
    context.read<SituacionesProvider>().getSituaciones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<SituacionesProvider>().userId;
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
            onTap: () => downloadFile(
                context.read<SituacionesProvider>().listadoParaExportar),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                context
                    .read<SituacionesProvider>()
                    .setSituacionActiva(Situacion(
                      id: 0,
                      efector: 1,
                      personaDni: 0,
                      personaConsultaFecha: DateTime.now(),
                      personaNombre: '',
                      personaApellido: '',
                      personaNacimientoFecha: DateTime(2001),
                      personaIdentidadDeGenero: '',
                      personaConDiscapacidad: '',
                      personaObraSocial: '',
                      partos: 0,
                      cesareas: 0,
                      abortos: 0,
                      consultaSituacion: '',
                      semanasGestacion: 14.6,
                      consultaCausal: '',
                      consultaOrigen: '',
                      consultaDerivacion: '',
                      derivacionEfector: 0,
                      derivacionMotivo: '',
                      tratamientoFecha: DateTime.now(),
                      tratamientoTipo: '',
                      tratamientoComprimidos: 0,
                      tratamientoQuirurgico: '',
                      semanasResolucion: 14.6,
                      complicaciones: '',
                      aipe: '',
                      observaciones: '',
                      user: userId,
                    ));
                _drawerTapAction(
                  SituacionFormView(
                    situacion: null,
                  ),
                );
              }),
        ],
      ),
      body: Column(
        children: [
          ConnectionStatusHeader(),
          Expanded(
            child: Consumer<SituacionesProvider>(
              builder: (context, postsProvider, child) {
                if (postsProvider.listadoSituaciones != null) {
                  return ListView.separated(
                    itemCount: postsProvider.listadoSituaciones.length,
                    separatorBuilder: (BuildContext context, int i) =>
                        i == postsProvider.listadoSituaciones.length
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
                      return i < postsProvider.listadoSituaciones.length
                          ? SituacionListItem(
                              postsProvider.listadoSituaciones[i],
                              onTap: () {
                                context
                                    .read<SituacionesProvider>()
                                    .setSituacionActiva(
                                        postsProvider.listadoSituaciones[i]);
                                //TODO: que no abra una nueva pagina, sino que actualice la abierta
                                // print('postsProvider.listadoSituaciones[i].derivacionEfector');
                                // print(postsProvider.listadoSituaciones[i].derivacionEfector);

                                _drawerTapAction(
                                  SituacionFormView(
                                    situacion:
                                        postsProvider.listadoSituaciones[i],
                                  ),
                                );
                              },
                              situacionFueSleccionada:
                                  postsProvider.situacionActiva != null
                                      ? postsProvider.situacionActiva.id ==
                                          postsProvider.listadoSituaciones[i].id
                                      : false,
                            )
                          : Container();
                    },
                  );
                } else {
                  //ACA puede ir un mensaje cuando todavia no hay una situacion cargada
                  return Container();
                }
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
    listaSituacion.add(situacion.personaConsultaFecha);
    listaSituacion.add(situacion.personaDni);
    listaSituacion.add(situacion.personaNombre);
    listaSituacion.add(situacion.personaApellido);
    listaSituacion.add(situacion.personaNacimientoFecha);
    listaSituacion.add(situacion.personaIdentidadDeGenero);
    listaSituacion.add(situacion.personaConDiscapacidad);
    listaSituacion.add(situacion.personaObraSocial);
    listaSituacion.add(situacion.partos);
    listaSituacion.add(situacion.cesareas);
    listaSituacion.add(situacion.abortos);
    listaSituacion.add(situacion.consultaSituacion);
    listaSituacion.add(situacion.semanasGestacion);
    listaSituacion.add(situacion.consultaCausal);
    listaSituacion.add(situacion.consultaOrigen);
    listaSituacion.add(situacion.consultaDerivacion);
    listaSituacion.add(situacion.derivacionEfector);
    listaSituacion.add(situacion.derivacionMotivo);
    listaSituacion.add(situacion.tratamientoFecha);
    listaSituacion.add(situacion.tratamientoTipo);
    listaSituacion.add(situacion.tratamientoComprimidos);
    listaSituacion.add(situacion.tratamientoQuirurgico);
    listaSituacion.add(situacion.semanasResolucion);
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
