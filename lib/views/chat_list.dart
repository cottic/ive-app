import 'dart:async';
import 'dart:io';

import 'package:famedlysdk/famedlysdk.dart';
import 'package:famedlysdk/matrix_api.dart';
// import 'package:fluffychat/components/avatar.dart';
import 'package:fluffychat/components/connection_status_header.dart';
import 'package:fluffychat/components/dialogs/simple_dialogs.dart';
// import 'package:fluffychat/components/list_items/status_list_item.dart';
import 'package:fluffychat/components/list_items/public_room_list_item.dart';
import 'package:fluffychat/components/list_items/situacion_list_item.dart';
import 'package:fluffychat/stats_dashboard/dashboard_menu_screen.dart';
import 'package:fluffychat/utils/platform_infos.dart';
// import 'package:fluffychat/views/status_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/stats_dashboard/services/dashboard_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:share/share.dart';
import 'dart:convert';

import '../stats_dashboard/models/situacion_model.dart';
import '../components/adaptive_page_layout.dart';
import '../components/list_items/chat_list_item.dart';
import '../components/matrix.dart';
import '../utils/app_route.dart';
import '../utils/matrix_file_extension.dart';
import '../utils/url_launcher.dart';
import 'archive.dart';
import 'maps_enia_menu.dart';
import 'homeserver_picker.dart';
import 'settings.dart';

enum SelectMode { normal, share, select }

class ChatListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptivePageLayout(
      primaryPage: FocusPage.FIRST,
      firstScaffold: ChatList(),
      secondScaffold: Scaffold(
        body: Center(
          child: Image.asset('assets/logo.png', width: 100, height: 100),
        ),
      ),
    );
  }
}

class ChatList extends StatefulWidget {
  final String activeChat;

  const ChatList({this.activeChat, Key key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Timer coolDown;
  PublicRoomsResponse publicRoomsResponse;
  bool loadingPublicRooms = false;
  String searchServer;
  final _selectedRoomIds = <String>{};

  List<String> roomsJoined;
  List<User> mainGroupList;

  final ScrollController _scrollController = ScrollController();

  void _toggleSelection(String roomId) =>
      setState(() => _selectedRoomIds.contains(roomId)
          ? _selectedRoomIds.remove(roomId)
          : _selectedRoomIds.add(roomId));

  Future<void> waitForFirstSync(BuildContext context) async {
    var client = Matrix.of(context).client;

    if (client.prevBatch?.isEmpty ?? true) {
      await client.onFirstSync.stream.first;
    }
    return true;
  }

  bool _scrolledToTop = true;

  Future _getSituaciones(user) async {
    var situacionesInfoJson = await DashboardService().getSituaciones(user);

    var parsedJson = json.decode(situacionesInfoJson);
    var situaciones = parsedJson.map((i) => Situacion.fromJson(i)).toList();

    if (situaciones.isNotEmpty) {
      return situaciones;
    }
    return null;
  }

  @override
  void initState() {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels > 0 && _scrolledToTop) {
        setState(() => _scrolledToTop = false);
      } else if (_scrollController.position.pixels == 0 && !_scrolledToTop) {
        setState(() => _scrolledToTop = true);
      }
    });

    _initReceiveSharingIntent();
    super.initState();
  }

  void logoutAction(BuildContext context) async {
    if (await SimpleDialogs(context).askConfirmation() == false) {
      return;
    }
    var matrix = Matrix.of(context);
    await SimpleDialogs(context)
        .tryRequestWithLoadingDialog(matrix.client.logout());
  }

  StreamSubscription _intentDataStreamSubscription;

  StreamSubscription _intentFileStreamSubscription;

  void _processIncomingSharedFiles(List<SharedMediaFile> files) {
    if (files?.isEmpty ?? true) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
    final file = File(files.first.path);

    Matrix.of(context).shareContent = {
      'msgtype': 'chat.fluffy.shared_file',
      'file': MatrixFile(
        bytes: file.readAsBytesSync(),
        name: file.path,
      ).detectFileType,
    };
  }

  void _processIncomingSharedText(String text) {
    if (text == null) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
    if (text.startsWith('https://matrix.to/#/')) {
      UrlLauncher(context, text).openMatrixToUrl();
      return;
    }
    Matrix.of(context).shareContent = {
      'msgtype': 'm.text',
      'body': text,
    };
  }

  void _initReceiveSharingIntent() {
    if (!PlatformInfos.isMobile) return;

    // For sharing images coming from outside the app while the app is in the memory
    _intentFileStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen(_processIncomingSharedFiles, onError: print);

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_processIncomingSharedFiles);

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream()
        .listen(_processIncomingSharedText, onError: print);

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(_processIncomingSharedText);
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
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentFileStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _archiveAction(BuildContext context) async {
    final confirmed = await SimpleDialogs(context).askConfirmation();
    if (!confirmed) return;
    await SimpleDialogs(context)
        .tryRequestWithLoadingDialog(_archiveSelectedRooms(context));
    setState(() => null);
  }

  Future<void> _archiveSelectedRooms(BuildContext context) async {
    final client = Matrix.of(context).client;
    while (_selectedRoomIds.isNotEmpty) {
      final roomId = _selectedRoomIds.first;
      await client.getRoomById(roomId).leave();
      _selectedRoomIds.remove(roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoginState>(
        stream: Matrix.of(context).client.onLoginStateChanged.stream,
        builder: (context, snapshot) {
          if (snapshot.data == LoginState.loggedOut) {
            Timer(Duration(seconds: 1), () {
              Matrix.of(context).clean();
              Navigator.of(context).pushAndRemoveUntil(
                  AppRoute.defaultRoute(context, HomeserverPicker()),
                  (r) => false);
            });
          }
          return StreamBuilder(
              stream: Matrix.of(context).onShareContentChanged.stream,
              builder: (context, snapshot) {
                final selectMode = Matrix.of(context).shareContent == null
                    ? _selectedRoomIds.isEmpty
                        ? SelectMode.normal
                        : SelectMode.select
                    : SelectMode.share;
                if (selectMode == SelectMode.share) {
                  _selectedRoomIds.clear();
                }
                var situacionNew = Situacion();
                return Scaffold(
                  drawer: selectMode != SelectMode.normal
                      ? null
                      : Drawer(
                          child: SafeArea(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: <Widget>[
                                SizedBox(height: 20),
                                ListTile(
                                  leading: Image.asset(
                                    'assets/logoSoloFondo.png',
                                    width: 22,
                                  ),
                                  title: Text(L10n.of(context).projectName),
                                  /* onTap: () => _drawerTapAction(
                                    // SituacionFormView(),
                                  ), */
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.insert_chart),
                                  title: Text(L10n.of(context).statsTitle),
                                  onTap: () => _drawerTapAction(
                                    StatsEniaMenuView(),
                                  ),
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.map),
                                  title: Text(L10n.of(context).mapsTitle),
                                  onTap: () => _drawerTapAction(
                                    MapsEniaMenuView(),
                                  ),
                                ),
                                Divider(height: 1),

                                ListTile(
                                  leading: Icon(Icons.archive),
                                  title: Text(L10n.of(context).archive),
                                  onTap: () => _drawerTapAction(
                                    Archive(),
                                  ),
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.settings),
                                  title: Text(L10n.of(context).settings),
                                  onTap: () => _drawerTapAction(
                                    SettingsView(),
                                  ),
                                ),
                                // Invitar contactos, no disponible en version 1
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text(L10n.of(context).inviteContact),
                                  /* onTap: () {
                                    _drawerTapAction(
                                      SituacionFormView(),
                                    );
                                  }, */
                                ),
                                Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.exit_to_app),
                                  title: Text(L10n.of(context).logout),
                                  onTap: () => logoutAction(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                  appBar: AppBar(
                    centerTitle: false,
                    elevation: _scrolledToTop ? 0 : null,
                    leading: selectMode == SelectMode.share
                        ? IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () =>
                                Matrix.of(context).shareContent = null,
                          )
                        : selectMode == SelectMode.select
                            ? IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    setState(_selectedRoomIds.clear),
                              )
                            : null,
                    titleSpacing: 0,
                    actions: selectMode != SelectMode.select
                        ? null
                        : [
                            IconButton(
                              icon: Icon(Icons.archive),
                              onPressed: () => _archiveAction(context),
                            ),
                          ],
                    title: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 284),
                      child: ListTile(
                        leading: Icon(Icons.archive),
                        onTap: () => _drawerTapAction(
                          Archive(),
                        ),
                      ),
                    ),
                  ),
                  /* floatingActionButton: (selectMode != SelectMode.normal)
                      ? null
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              child: Icon(Icons.add),
                              backgroundColor: Theme.of(context).primaryColor,
                              onPressed: () => Navigator.of(context)
                                  .pushAndRemoveUntil(
                                      AppRoute.defaultRoute(
                                          context, SituacionFormView()),
                                      (r) => r.isFirst),
                            ),
                          ],
                        ), */
                  body: Column(
                    children: [
                      ConnectionStatusHeader(),
                      Expanded(
                          child: FutureBuilder<void>(
                        future: waitForFirstSync(context),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasData) {
                            var rooms = List<Room>.from(
                                Matrix.of(context).client.rooms);
                            final client = Matrix.of(context).client;
                            final username = client.userID;

                            return FutureBuilder(
                              future: _getSituaciones(username),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshotSituaciones) {
                                /* if (snapshotSituaciones.hasData) {
                                  List situaciones = snapshotSituaciones.data;
                                  final totalCount = situaciones.length;
                                  // var situacionSeleccionada = ;
                                  //Si esta seleccinado, lo muestro
                                  // si el item se muestra arriba, no se muestra abajo
                                  return ListView.separated(
                                    controller: _scrollController,
                                    itemCount: totalCount,
                                    separatorBuilder: (BuildContext context,
                                            int i) =>
                                        i == totalCount
                                            ? ListTile(
                                                title: Text(
                                                  L10n.of(context).publicRooms +
                                                      ':',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                    itemBuilder: (BuildContext context, int i) {
                                      // print(rooms[i].id);
                                      if (i == 0) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 300),
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
                                                    roomId: rooms[i].id,
                                                  ),
                                                );
                                              },
                                              situacionFueSleccionada:
                                                  widget.activeChat ==
                                                      situaciones[i].id,
                                            )
                                          : PublicRoomListItem(
                                              publicRoomsResponse
                                                  .chunk[i - rooms.length]);
                                    },
                                  );
                                } */

                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )),
                    ],
                  ),
                );
              });
        });
  }
}
