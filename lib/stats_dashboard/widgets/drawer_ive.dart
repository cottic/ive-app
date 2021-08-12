import 'package:fluffychat/components/dialogs/simple_dialogs.dart';
import 'package:fluffychat/stats_dashboard/dashboard_menu_screen.dart';
import 'package:fluffychat/utils/app_route.dart';
import 'package:fluffychat/views/archive.dart';
import 'package:fluffychat/views/maps_enia_menu.dart';
import 'package:fluffychat/views/settings.dart';
import 'package:fluffychat/views/situaciones_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:fluffychat/components/matrix.dart';

class DrawerIle extends StatelessWidget {
  const DrawerIle({
    Key key,
  }) : super(key: key);

  void _drawerTapAction(Widget view, BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute.defaultRoute(
        context,
        view,
      ),
      (r) => r.isFirst,
    );
  }

  void logoutAction(BuildContext context) async {
    if (await SimpleDialogs(context).askConfirmation() == false) {
      return;
    }
    var matrix = Matrix.of(context);
    await SimpleDialogs(context)
        .tryRequestWithLoadingDialog(matrix.client.logout());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              onTap: () => _drawerTapAction(SituacionFormView(), context),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.insert_chart),
              title: Text(L10n.of(context).statsTitle),
              onTap: () => _drawerTapAction(StatsEniaMenuView(), context),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.map),
              title: Text(L10n.of(context).mapsTitle),
              onTap: () => _drawerTapAction(MapsEniaMenuView(), context),
            ),
            Divider(height: 1),

            ListTile(
              leading: Icon(Icons.archive),
              title: Text(L10n.of(context).archive),
              onTap: () => _drawerTapAction(Archive(), context),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(L10n.of(context).settings),
              onTap: () => _drawerTapAction(SettingsView(), context),
            ),
            // Invitar contactos, no disponible en version 1
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.share),
              title: Text(L10n.of(context).inviteContact),
              onTap: () {
                _drawerTapAction(SituacionFormView(), context);
              },
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
    );
  }
}
