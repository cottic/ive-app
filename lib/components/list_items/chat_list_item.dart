import 'package:bot_toast/bot_toast.dart';
import 'package:famedlysdk/famedlysdk.dart';
import '../../stats_dashboard/models/situacion_model.dart';
import 'package:fluffychat/utils/matrix_locals.dart';
import 'package:fluffychat/views/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:pedantic/pedantic.dart';

import '../../utils/app_route.dart';
import '../../utils/date_time_extension.dart';
import '../../views/chat.dart';
import '../avatar.dart';
import '../dialogs/send_file_dialog.dart';
import '../dialogs/simple_dialogs.dart';
import '../matrix.dart';
import '../theme_switcher.dart';

class ChatListItem extends StatelessWidget {
  final Situacion situacion;
  final bool activeChat;
  final bool selected;
  final Function onForget;
  final Function onTap;
  final Function onLongPress;

  const ChatListItem(this.situacion,
      {this.activeChat = false,
      this.selected = false,
      this.onTap,
      this.onLongPress,
      this.onForget});

  void clickAction(BuildContext context) async {
    if (onTap != null) return onTap();
  }

  @override
  Widget build(BuildContext context) {
    var dniStr = situacion.personaDni.toString();
    var fechaStr = situacion.personaConsultaFecha.toString();
    var semanasStr = situacion.semanasGestacion.toString();

    return Center(
      child: Material(
        color: chatListItemColor(context, activeChat, selected),
        child: ListTile(
          onLongPress: onLongPress,
          leading: Avatar(Uri.parse(''),
              situacion.consultaSituacion.toUpperCase()), // LOGO
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  situacion.personaApellido.toUpperCase() +
                      ' ' +
                      situacion.personaNombre.toUpperCase() +
                      ' ' +
                      dniStr, // TITULO DEL ITEM
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              /* situacion.isFavourite
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        size: 16,
                      ),
                    )
                  : Container(),
              isMuted
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 16,
                      ),
                    )
                  : Container(), */
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  fechaStr.substring(0, 10), // FEcha
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  'semanas de gestación: ' +
                      semanasStr +
                      ' - ' +
                      'causal: ' +
                      situacion.consultaCausal, // SUBTITULO
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              /* situacion.notificationCount > 0
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 20,
                      decoration: BoxDecoration(
                        color: situacion.highlightCount > 0
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          situacion.notificationCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Text(' '),*/
            ],
          ),
          onTap: () => clickAction(context),
        ),
      ),
    );
  }
}
