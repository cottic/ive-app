import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:famedlysdk/famedlysdk.dart';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:fluffychat/components/adaptive_page_layout.dart';
import 'package:fluffychat/components/avatar.dart';
import 'package:fluffychat/components/dialogs/frequent_message_dialog.dart';

import 'package:fluffychat/components/chat_settings_popup_menu.dart';
import 'package:fluffychat/components/connection_status_header.dart';
import 'package:fluffychat/components/dialogs/recording_dialog.dart';
import 'package:fluffychat/components/dialogs/simple_dialogs.dart';
import 'package:fluffychat/components/list_items/message.dart';
import 'package:fluffychat/components/matrix.dart';
import 'package:fluffychat/components/reply_content.dart';
import 'package:fluffychat/config/app_emojis.dart';
import 'package:fluffychat/utils/app_route.dart';
import 'package:fluffychat/utils/matrix_locals.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/room_status_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../components/dialogs/send_file_dialog.dart';
import '../components/input_bar.dart';
import '../utils/matrix_file_extension.dart';

import 'chat_details.dart';
import 'chat_list.dart';

class ChatView extends StatelessWidget {
  final String id;
  final String scrollToEventId;

  const ChatView(this.id, {Key key, this.scrollToEventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AdaptivePageLayout(
      primaryPage: FocusPage.SECOND,
      firstScaffold: ChatList(
        activeChat: id,
      ),
      secondScaffold: _Chat(id, scrollToEventId: scrollToEventId),
    );
  }
}

class _Chat extends StatefulWidget {
  final String id;
  final String scrollToEventId;

  const _Chat(this.id, {Key key, this.scrollToEventId}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<_Chat> {
  Room room;

  Timeline timeline;

  MatrixState matrix;

  String seenByText = '';

  final AutoScrollController _scrollController = AutoScrollController();

  FocusNode inputFocus = FocusNode();

  Timer typingCoolDown;
  Timer typingTimeout;
  bool currentlyTyping = false;

  List<Event> selectedEvents = [];

  Event replyEvent;

  Event editEvent;

  bool showScrollDownButton = false;

  bool get selectMode => selectedEvents.isNotEmpty;

  bool _loadingHistory = false;

  final int _loadHistoryCount = 100;

  String inputText = '';

  bool get _canLoadMore => timeline.events.last.type != EventTypes.RoomCreate;

  void requestHistory() async {
    if (_canLoadMore) {
      setState(() => _loadingHistory = true);

      await SimpleDialogs(context).tryRequestWithErrorToast(
        timeline.requestHistory(historyCount: _loadHistoryCount),
      );

      // we do NOT setState() here as then the event order will be wrong.
      // instead, we just set our variable to false, and rely on timeline update to set the
      // new state, thus triggering a re-render, for us
      _loadingHistory = false;
    }
  }

  void _updateScrollController() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        timeline.events.isNotEmpty &&
        timeline.events[timeline.events.length - 1].type !=
            EventTypes.RoomCreate) {
      requestHistory();
    }
    if (_scrollController.position.pixels > 0 &&
        showScrollDownButton == false) {
      setState(() => showScrollDownButton = true);
    } else if (_scrollController.position.pixels == 0 &&
        showScrollDownButton == true) {
      setState(() => showScrollDownButton = false);
    }
  }

  @override
  void initState() {
    _scrollController.addListener(_updateScrollController);
    super.initState();
  }

  void updateView() {
    if (!mounted) return;

    var seenByText = '';
    if (timeline.events.isNotEmpty) {
      var lastReceipts = List.from(timeline.events.first.receipts);
      lastReceipts.removeWhere((r) =>
          r.user.id == room.client.userID ||
          r.user.id == timeline.events.first.senderId);
      if (lastReceipts.length == 1) {
        seenByText = L10n.of(context)
            .seenByUser(lastReceipts.first.user.calcDisplayname());
      } else if (lastReceipts.length == 2) {
        seenByText = seenByText = L10n.of(context).seenByUserAndUser(
            lastReceipts.first.user.calcDisplayname(),
            lastReceipts[1].user.calcDisplayname());
      } else if (lastReceipts.length > 2) {
        seenByText = L10n.of(context).seenByUserAndCountOthers(
            lastReceipts.first.user.calcDisplayname(),
            (lastReceipts.length - 1).toString());
      }
    }
    if (timeline != null) {
      setState(() {
        this.seenByText = seenByText;
      });
    }
  }

  Future<bool> getTimeline(BuildContext context) async {
    if (timeline == null) {
      timeline = await room.getTimeline(onUpdate: updateView);
      if (timeline.events.isNotEmpty) {
        unawaited(room.sendReadReceipt(timeline.events.first.eventId));
      }

      // when the scroll controller is attached we want to scroll to an event id, if specified
      // and update the scroll controller...which will trigger a request history, if the
      // "load more" button is visible on the screen
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (widget.scrollToEventId != null) {
          _scrollToEventId(widget.scrollToEventId, context: context);
        }
        _updateScrollController();
      });
    }
    updateView();
    return true;
  }

  @override
  void dispose() {
    timeline?.cancelSubscriptions();
    timeline = null;
    matrix.activeRoomId = '';
    super.dispose();
  }

  TextEditingController sendController = TextEditingController();

  void send() {
    if (sendController.text.isEmpty) return;
    room.sendTextEvent(sendController.text,
        inReplyTo: replyEvent, editEventId: editEvent?.eventId);
    sendController.text = '';

    setState(() {
      inputText = '';
      replyEvent = null;
      editEvent = null;
    });
  }

  void sendFileAction(BuildContext context) async {
    final result =
        await FilePickerCross.importFromStorage(type: FileTypeCross.any);
    if (result == null) return;
    await showDialog(
      context: context,
      builder: (context) => SendFileDialog(
        file: MatrixFile(
          bytes: result.toUint8List(),
          name: result.fileName,
        ).detectFileType,
        room: room,
      ),
    );
  }

  void sendVideoAction(BuildContext context) async {
    final result =
        await FilePickerCross.importFromStorage(type: FileTypeCross.video);
    if (result == null) return;
    await showDialog(
      context: context,
      builder: (context) => SendFileDialog(
        file: MatrixFile(
          bytes: result.toUint8List(),
          name: result.fileName,
        ).detectFileType,
        room: room,
      ),
    );
  }

  void sendImageAction(BuildContext context) async {
    final result =
        await FilePickerCross.importFromStorage(type: FileTypeCross.image);
    if (result == null) return;
    await showDialog(
      context: context,
      builder: (context) => SendFileDialog(
        file: MatrixImageFile(
          bytes: result.toUint8List(),
          name: result.fileName,
        ),
        room: room,
      ),
    );
  }

  void openCameraAction(BuildContext context) async {
    var file = await ImagePicker().getImage(source: ImageSource.camera);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await showDialog(
      context: context,
      builder: (context) => SendFileDialog(
        file: MatrixImageFile(
          bytes: bytes,
          name: file.path,
        ),
        room: room,
      ),
    );
  }

  void voiceMessageAction(BuildContext context) async {
    String result;
    await showDialog(
        context: context,
        builder: (context) => RecordingDialog(
              onFinished: (r) => result = r,
            ));
    if (result == null) return;
    final audioFile = File(result);
    // as we already explicitly say send in the recording dialog,
    // we do not need the send file dialog anymore. We can just send this straight away.
    await SimpleDialogs(context).tryRequestWithLoadingDialog(
      room.sendFileEvent(
        MatrixAudioFile(
            bytes: audioFile.readAsBytesSync(), name: audioFile.path),
      ),
    );
  }

  void frequentMessageAction(BuildContext context) async {
    String result;

    await showDialog(
        context: context,
        builder: (context) => FrequentMessageDialog(
              onFinished: (r) => result = r,
            ));
    if (result == null) {
      return;
    } else {
      // Asigns selected texto to controller
      sendController.text = result;
      // Activates keyboard after text select
      FocusScope.of(context).requestFocus(inputFocus);
    }
    ;
  }

  String _getSelectedEventString(BuildContext context) {
    var copyString = '';
    if (selectedEvents.length == 1) {
      return selectedEvents.first
          .getLocalizedBody(MatrixLocals(L10n.of(context)));
    }
    for (var event in selectedEvents) {
      if (copyString.isNotEmpty) copyString += '\n\n';
      copyString += event.getLocalizedBody(MatrixLocals(L10n.of(context)),
          withSenderNamePrefix: true);
    }
    return copyString;
  }

  void copyEventsAction(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _getSelectedEventString(context)));
    setState(() => selectedEvents.clear());
  }

  void redactEventsAction(BuildContext context) async {
    var confirmed = await SimpleDialogs(context).askConfirmation(
      titleText: L10n.of(context).messageWillBeRemovedWarning,
      confirmText: L10n.of(context).remove,
    );
    if (!confirmed) return;
    for (var event in selectedEvents) {
      await SimpleDialogs(context).tryRequestWithLoadingDialog(
          event.status > 0 ? event.redact() : event.remove());
    }
    setState(() => selectedEvents.clear());
  }

  bool get canRedactSelectedEvents {
    for (var event in selectedEvents) {
      if (event.canRedact == false) return false;
    }
    return true;
  }

  void forwardEventsAction(BuildContext context) async {
    if (selectedEvents.length == 1) {
      Matrix.of(context).shareContent = selectedEvents.first.content;
    } else {
      Matrix.of(context).shareContent = {
        'msgtype': 'm.text',
        'body': _getSelectedEventString(context),
      };
    }
    setState(() => selectedEvents.clear());
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void sendAgainAction(Timeline timeline) {
    final event = selectedEvents.first;
    if (event.status == -1) {
      event.sendAgain();
    }
    final allEditEvents = event
        .aggregatedEvents(timeline, RelationshipTypes.Edit)
        .where((e) => e.status == -1);
    for (final e in allEditEvents) {
      e.sendAgain();
    }
    setState(() => selectedEvents.clear());
  }

  void replyAction() {
    setState(() {
      replyEvent = selectedEvents.first;
      selectedEvents.clear();
    });
    inputFocus.requestFocus();
  }

  void _scrollToEventId(String eventId, {BuildContext context}) async {
    var eventIndex =
        getFilteredEvents().indexWhere((e) => e.eventId == eventId);
    if (eventIndex == -1) {
      // event id not found...maybe we can fetch it?
      // the try...finally is here to start and close the loading dialog reliably
      try {
        if (context != null) {
          SimpleDialogs(context).showLoadingDialog(context);
        }
        // okay, we first have to fetch if the event is in the room
        try {
          final event = await timeline.getEventById(eventId);
          if (event == null) {
            // event is null...meaning something is off
            return;
          }
        } catch (err) {
          if (err is MatrixException && err.errcode == 'M_NOT_FOUND') {
            // event wasn't found, as the server gave a 404 or something
            return;
          }
          rethrow;
        }
        // okay, we know that the event *is* in the room
        while (eventIndex == -1) {
          if (!_canLoadMore) {
            // we can't load any more events but still haven't found ours yet...better stop here
            return;
          }
          try {
            await timeline.requestHistory(historyCount: _loadHistoryCount);
          } catch (err) {
            if (err is TimeoutException) {
              // loading the history timed out...so let's do nothing
              return;
            }
            rethrow;
          }
          eventIndex =
              getFilteredEvents().indexWhere((e) => e.eventId == eventId);
        }
      } finally {
        if (context != null) {
          Navigator.of(context)?.pop();
        }
      }
    }
    await _scrollController.scrollToIndex(eventIndex,
        preferPosition: AutoScrollPosition.middle);
    _updateScrollController();
  }

  List<Event> getFilteredEvents() => timeline.events
      .where((e) =>
          ![RelationshipTypes.Edit, RelationshipTypes.Reaction]
              .contains(e.relationshipType) &&
          e.type != 'm.reaction')
      .toList();

  @override
  Widget build(BuildContext context) {
    matrix = Matrix.of(context);
    var client = matrix.client;
    room ??= client.getRoomById(widget.id);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context).oopsSomethingWentWrong),
        ),
        body: Center(
          child: Text(L10n.of(context).youAreNoLongerParticipatingInThisChat),
        ),
      );
    }
    matrix.activeRoomId = widget.id;
/* 
    print('entro CHECK VIDEO CALL  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

    // Participantes de la room actual
    var roomPatrticipantsChat = room.getParticipants();

    print('Participantes de la room actual');
    print(roomPatrticipantsChat.toString());

    print(roomPatrticipantsChat.elementAt(0).displayName.toString());
    // print(roomPatrticipantsChat.elementAt(1).displayName.toString());

    // Traer Room ENIA
    var eniaRoom = client.getRoomById(Matrix.mainGroup);

    // Participantes de la ENIA ROOM
    var participantseniaRoom = eniaRoom.getParticipants();

    print('Participantes de la ENIA ROOM');
    print(participantseniaRoom.toString());

/*     print('participantseniaRoom');
    print(participantseniaRoom.elementAt(0).displayName.toString());
    print(participantseniaRoom.elementAt(1).displayName.toString());

    print(participantseniaRoom.elementAt(2).displayName.toString());
    print(participantseniaRoom.elementAt(3).displayName.toString());

    print(participantseniaRoom.elementAt(4).displayName.toString());
    print(participantseniaRoom.elementAt(5).displayName.toString());

    print(participantseniaRoom.elementAt(6).displayName.toString());
    print(participantseniaRoom.elementAt(7).displayName.toString());

    print(participantseniaRoom.elementAt(8).displayName.toString());
    print(participantseniaRoom.elementAt(9).displayName.toString());

    print(participantseniaRoom.elementAt(10).displayName.toString());
    print(participantseniaRoom.elementAt(11).displayName.toString()); */

    //var participantseniaRoomComparision =  participantseniaRoom.elementAt(index).id.contains(roomPatrticipantsChat.elementAt(index).id);

    //print('participantseniaRoomComparision');
    //print(participantseniaRoomComparision.toString());

    var jonaChat = roomPatrticipantsChat.elementAt(0);
    var jonaGrupoENia = participantseniaRoom.elementAt(4);

    print('jonaChat');
    print(jonaChat.displayName.toString());
    print('jonaGrupoENia');
    print(jonaGrupoENia.displayName.toString());

    var isTheSameUser = jonaChat.id == jonaGrupoENia.id;

    print('Es el mismo usuario?');
    print(isTheSameUser.toString());

/*     var estanLosIds = roomPatrticipantsChat
        .where((User userChat) => participantseniaRoom
            .where((User userEniaGroup) => userEniaGroup.id.contains(userChat.id))
            ))
        .map((obj) {
      print('${obj.id}');
      return obj;
    }).toList(); */

    var index;

    List resultado;

    for (index = 0; index <= participantseniaRoom.length - 1; index++) {
      //print('participantseniaRoom For Loop Called $index Times');
      //print(participantseniaRoom.elementAt(index).displayName);
      var estanLosIds = roomPatrticipantsChat
          .where((User userChat) =>
              participantseniaRoom.elementAt(index).id.contains(userChat.id))
          .map((userInBothLists) {
        print('${userInBothLists.id}');
        return userInBothLists;
      });

     // resultado.add(estanLosIds);
    }

    print('resultado');
    print(resultado.toString());

    print('SALIO CHECK VIDEO CALL XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); */

    if (room.membership == Membership.invite) {
      SimpleDialogs(context).tryRequestWithLoadingDialog(room.join());
    }

    var typingText = '';
    var typingUsers = room.typingUsers;
    typingUsers.removeWhere((User u) => u.id == client.userID);

    if (typingUsers.length == 1) {
      typingText = L10n.of(context).isTyping;
      if (typingUsers.first.id != room.directChatMatrixID) {
        typingText =
            L10n.of(context).userIsTyping(typingUsers.first.calcDisplayname());
      }
    } else if (typingUsers.length == 2) {
      typingText = L10n.of(context).userAndUserAreTyping(
          typingUsers.first.calcDisplayname(),
          typingUsers[1].calcDisplayname());
    } else if (typingUsers.length > 2) {
      typingText = L10n.of(context).userAndOthersAreTyping(
          typingUsers.first.calcDisplayname(),
          (typingUsers.length - 1).toString());
    }

    return Scaffold(
      appBar: AppBar(
        leading: selectMode
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () => setState(() => selectedEvents.clear()),
              )
            : null,
        titleSpacing: 0,
        title: selectedEvents.isEmpty
            ? StreamBuilder<Object>(
                stream: Matrix.of(context)
                    .client
                    .onPresence
                    .stream
                    .where((p) => p.senderId == room.directChatMatrixID),
                builder: (context, snapshot) {
                  return ListTile(
                    leading: Avatar(room.avatar, room.displayname),
                    contentPadding: EdgeInsets.zero,
                    onTap: room.isDirectChat && room.directChatPresence == null
                        ? null
                        : room.isDirectChat
                            ? null
                            : () => Navigator.of(context).push(
                                  AppRoute.defaultRoute(
                                    context,
                                    ChatDetails(room),
                                  ),
                                ),
                    title: Text(
                        room.getLocalizedDisplayname(
                            MatrixLocals(L10n.of(context))),
                        maxLines: 1),
                    subtitle: typingText.isEmpty
                        ? Text(
                            room.getLocalizedStatus(context),
                            maxLines: 1,
                          )
                        : Row(
                            children: <Widget>[
                              Icon(Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                  size: 13),
                              SizedBox(width: 4),
                              Text(
                                typingText,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  );
                })
            : Text(L10n.of(context)
                .numberSelected(selectedEvents.length.toString())),
        actions: selectMode
            ? <Widget>[
                if (selectedEvents.length == 1 &&
                    selectedEvents.first.status > 0 &&
                    selectedEvents.first.senderId == client.userID)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        editEvent = selectedEvents.first;
                        sendController.text = editEvent
                            .getDisplayEvent(timeline)
                            .getLocalizedBody(MatrixLocals(L10n.of(context)),
                                withSenderNamePrefix: false, hideReply: true);
                        selectedEvents.clear();
                      });
                      inputFocus.requestFocus();
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () => copyEventsAction(context),
                ),
                if (canRedactSelectedEvents)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => redactEventsAction(context),
                  ),
              ]
            : <Widget>[ChatSettingsPopupMenu(room, !room.isDirectChat)],
      ),
      floatingActionButton: showScrollDownButton
          ? Padding(
              padding: const EdgeInsets.only(bottom: 56.0),
              child: FloatingActionButton(
                child: Icon(Icons.arrow_downward,
                    color: Theme.of(context).primaryColor),
                onPressed: () => _scrollController.jumpTo(0),
                foregroundColor: Theme.of(context).textTheme.bodyText2.color,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                mini: true,
              ),
            )
          : null,
      body: Stack(
        children: <Widget>[
          if (Matrix.of(context).wallpaper != null)
            Opacity(
              opacity: 0.66,
              child: Image.file(
                Matrix.of(context).wallpaper,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Column(
            children: <Widget>[
              ConnectionStatusHeader(),
              Expanded(
                child: FutureBuilder<bool>(
                  future: getTimeline(context),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (room.notificationCount != null &&
                        room.notificationCount > 0 &&
                        timeline != null &&
                        timeline.events.isNotEmpty &&
                        Matrix.of(context).webHasFocus) {
                      room.sendReadReceipt(timeline.events.first.eventId);
                    }

                    final filteredEvents = getFilteredEvents();

                    return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: max(
                              0,
                              (MediaQuery.of(context).size.width -
                                      AdaptivePageLayout.defaultMinWidth *
                                          3.5) /
                                  2),
                        ),
                        reverse: true,
                        itemCount: filteredEvents.length + 2,
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int i) {
                          return i == filteredEvents.length + 1
                              ? _loadingHistory
                                  ? Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(),
                                    )
                                  : _canLoadMore
                                      ? FlatButton(
                                          child: Text(
                                            L10n.of(context).loadMore,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          onPressed: requestHistory,
                                        )
                                      : Container()
                              : i == 0
                                  ? AnimatedContainer(
                                      height: seenByText.isEmpty ? 0 : 24,
                                      duration: seenByText.isEmpty
                                          ? Duration(milliseconds: 0)
                                          : Duration(milliseconds: 300),
                                      alignment:
                                          filteredEvents.first.senderId ==
                                                  client.userID
                                              ? Alignment.topRight
                                              : Alignment.topLeft,
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor
                                              .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          seenByText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                        bottom: 8,
                                      ),
                                    )
                                  : AutoScrollTag(
                                      key: ValueKey(i - 1),
                                      index: i - 1,
                                      controller: _scrollController,
                                      child: Message(filteredEvents[i - 1],
                                          onAvatarTab: (Event event) {
                                            sendController.text +=
                                                ' ${event.senderId}';
                                          },
                                          onSelect: (Event event) {
                                            if (!event.redacted) {
                                              if (selectedEvents
                                                  .contains(event)) {
                                                setState(
                                                  () => selectedEvents
                                                      .remove(event),
                                                );
                                              } else {
                                                setState(
                                                  () =>
                                                      selectedEvents.add(event),
                                                );
                                              }
                                              selectedEvents.sort(
                                                (a, b) => a.originServerTs
                                                    .compareTo(
                                                        b.originServerTs),
                                              );
                                            }
                                          },
                                          scrollToEventId: (String eventId) =>
                                              _scrollToEventId(eventId,
                                                  context: context),
                                          longPressSelect:
                                              selectedEvents.isEmpty,
                                          selected: selectedEvents
                                              .contains(filteredEvents[i - 1]),
                                          timeline: timeline,
                                          nextEvent: i >= 2
                                              ? filteredEvents[i - 2]
                                              : null),
                                    );
                        });
                  },
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: (editEvent == null &&
                        replyEvent == null &&
                        selectedEvents.length == 1)
                    ? 56
                    : 0,
                child: Material(
                  color: Theme.of(context).secondaryHeaderColor,
                  child: Builder(builder: (context) {
                    if (!(editEvent == null &&
                        replyEvent == null &&
                        selectedEvents.length == 1)) {
                      return Container();
                    }
                    var emojis = List<String>.from(AppEmojis.emojis);
                    final allReactionEvents = selectedEvents.first
                        .aggregatedEvents(timeline, RelationshipTypes.Reaction)
                        ?.where((event) =>
                            event.senderId == event.room.client.userID &&
                            event.type == 'm.reaction');

                    allReactionEvents.forEach((event) {
                      try {
                        emojis.remove(event.content['m.relates_to']['key']);
                      } catch (_) {}
                    });
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: emojis.length,
                      itemBuilder: (c, i) => InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          SimpleDialogs(context).tryRequestWithLoadingDialog(
                            room.sendReaction(
                              selectedEvents.first.eventId,
                              emojis[i],
                            ),
                          );
                          setState(() => selectedEvents.clear());
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            emojis[i],
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: editEvent != null || replyEvent != null ? 56 : 0,
                child: Material(
                  color: Theme.of(context).secondaryHeaderColor,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => setState(() {
                          replyEvent = null;
                          editEvent = null;
                        }),
                      ),
                      Expanded(
                        child: replyEvent != null
                            ? ReplyContent(replyEvent, timeline: timeline)
                            : _EditContent(
                                editEvent?.getDisplayEvent(timeline)),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Theme.of(context).secondaryHeaderColor,
                thickness: 1,
              ),
              room.canSendDefaultMessages && room.membership == Membership.join
                  ? Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: selectMode
                            ? <Widget>[
                                Container(
                                  height: 56,
                                  child: FlatButton(
                                    onPressed: () =>
                                        forwardEventsAction(context),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.keyboard_arrow_left),
                                        Text(L10n.of(context).forward),
                                      ],
                                    ),
                                  ),
                                ),
                                selectedEvents.length == 1
                                    ? selectedEvents.first
                                                .getDisplayEvent(timeline)
                                                .status >
                                            0
                                        ? Container(
                                            height: 56,
                                            child: FlatButton(
                                              onPressed: () => replyAction(),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(L10n.of(context).reply),
                                                  Icon(Icons
                                                      .keyboard_arrow_right),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 56,
                                            child: FlatButton(
                                              onPressed: () =>
                                                  sendAgainAction(timeline),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(L10n.of(context)
                                                      .tryToSendAgain),
                                                  SizedBox(width: 4),
                                                  Icon(Icons.send, size: 16),
                                                ],
                                              ),
                                            ),
                                          )
                                    : Container(),
                              ]
                            : <Widget>[
                                if (inputText.isEmpty)
                                  Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    child: PopupMenuButton<String>(
                                      icon: Icon(Icons.add),
                                      onSelected: (String choice) async {
                                        if (choice == 'file') {
                                          sendFileAction(context);
                                        } else if (choice == 'image') {
                                          sendImageAction(context);
                                        }
                                        if (choice == 'video') {
                                          sendVideoAction(context);
                                        }
                                        if (choice == 'camera') {
                                          openCameraAction(context);
                                        }
                                        if (choice == 'voice') {
                                          voiceMessageAction(context);
                                        }
                                        if (choice == 'frequent') {
                                          frequentMessageAction(context);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'file',
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              child: Icon(Icons.attachment),
                                            ),
                                            title:
                                                Text(L10n.of(context).sendFile),
                                            contentPadding: EdgeInsets.all(0),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'video',
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.teal,
                                              foregroundColor: Colors.white,
                                              child: Icon(Icons.ondemand_video),
                                            ),
                                            title: Text(
                                                L10n.of(context).sendVideo),
                                            contentPadding: EdgeInsets.all(0),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'image',
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              child: Icon(Icons.image),
                                            ),
                                            title: Text(
                                                L10n.of(context).sendImage),
                                            contentPadding: EdgeInsets.all(0),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'frequent',
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.amber,
                                              foregroundColor: Colors.white,
                                              child: Icon(Icons.textsms),
                                            ),
                                            title: Text(L10n.of(context)
                                                .frequentMessages),
                                            contentPadding: EdgeInsets.all(0),
                                          ),
                                        ),
                                        if (PlatformInfos.isMobile)
                                          PopupMenuItem<String>(
                                            value: 'camera',
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.purple,
                                                foregroundColor: Colors.white,
                                                child: Icon(Icons.camera_alt),
                                              ),
                                              title: Text(
                                                  L10n.of(context).openCamera),
                                              contentPadding: EdgeInsets.all(0),
                                            ),
                                          ),
                                        if (PlatformInfos.isMobile)
                                          PopupMenuItem<String>(
                                            value: 'voice',
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                child: Icon(Icons.mic),
                                              ),
                                              title: Text(L10n.of(context)
                                                  .voiceMessage),
                                              contentPadding: EdgeInsets.all(0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                // ENIA dont allow to encrypt conversation in order to audit the program
                                /* Container(
                                  height: 56,
                                  alignment: Alignment.center,
                                  child: EncryptionButton(room),
                                ), */
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: InputBar(
                                      room: room,
                                      minLines: 1,
                                      maxLines: kIsWeb ? 1 : 8,
                                      autofocus: !PlatformInfos.isMobile,
                                      keyboardType: !PlatformInfos.isMobile
                                          ? TextInputType.text
                                          : TextInputType.multiline,
                                      onSubmitted: (String text) {
                                        send();
                                        FocusScope.of(context)
                                            .requestFocus(inputFocus);
                                      },
                                      focusNode: inputFocus,
                                      controller: sendController,
                                      decoration: InputDecoration(
                                        hintText:
                                            L10n.of(context).writeAMessage,
                                        hintMaxLines: 1,
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (String text) {
                                        typingCoolDown?.cancel();
                                        typingCoolDown =
                                            Timer(Duration(seconds: 2), () {
                                          typingCoolDown = null;
                                          currentlyTyping = false;
                                          room.sendTypingInfo(false);
                                        });
                                        typingTimeout ??=
                                            Timer(Duration(seconds: 30), () {
                                          typingTimeout = null;
                                          currentlyTyping = false;
                                        });
                                        if (!currentlyTyping) {
                                          currentlyTyping = true;
                                          room.sendTypingInfo(true,
                                              timeout: Duration(seconds: 30)
                                                  .inMilliseconds);
                                        }
                                        // Workaround for a current desktop bug
                                        if (!PlatformInfos.isBetaDesktop) {
                                          setState(() => inputText = text);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                if (PlatformInfos.isMobile && inputText.isEmpty)
                                  Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: Icon(Icons.mic),
                                      onPressed: () =>
                                          voiceMessageAction(context),
                                    ),
                                  ),
                                if (!PlatformInfos.isMobile ||
                                    inputText.isNotEmpty)
                                  Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () => send(),
                                    ),
                                  ),
                              ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditContent extends StatelessWidget {
  final Event event;

  _EditContent(this.event);

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Container();
    }
    return Row(
      children: <Widget>[
        Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        Container(width: 15.0),
        Text(
          event?.getLocalizedBody(
                MatrixLocals(L10n.of(context)),
                withSenderNamePrefix: false,
                hideReply: true,
              ) ??
              '',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText2.color,
          ),
        ),
      ],
    );
  }
}
