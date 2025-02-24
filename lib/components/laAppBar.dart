import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/utils/utils.dart';

import '../laTheme.dart';
import '../routes.dart';
import 'laIcon.dart';

class LAAppBar extends AppBar {
  LAAppBar(
      {Key? key,
      required BuildContext context,
      required String title,
      String? projectIcon,
      bool showLaIcon = false,
      NamedBeamLocation? backLocation,
      bool showBack = false,
      List<Widget>? actions,
      Widget? leading,
      IconData? titleIcon,
      bool loading = false,
      VoidCallback? onBack,
      String? tooltip,
      VoidCallback? beforeBack})
      : super(
            /*
            // This breaks the Navigation
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),*/
            key: key,
            toolbarHeight: kToolbarHeight * 1.2,
            actions: actions == null
                ? List<Widget>.empty(growable: true)
                : actions +
                    <Widget>[
                      Container(margin: const EdgeInsets.only(right: 20.0))
                    ],
            leading: leading,
            bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 1.0),
                child: loading
                    ? const LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: LAColorTheme.laPaletteAccent,
                      )
                    : Container()),
            title: SizedBox(
              height: kToolbarHeight * 1.2,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                if (showBack)
                  IconButton(
                      tooltip: "Back",
                      icon: const Icon(Icons.arrow_back,
                          size: 28, color: Colors.black),
                      onPressed: () {
                        if (beforeBack != null) beforeBack();
                        if (backLocation != null) {
                          BeamerCond.of(context, backLocation);
                        } else {
                          try {
                            context.beamBack();
                          } catch (e) {
                            print('Error in beam back');
                            print(e);
                            BeamerCond.of(context, HomeLocation());
                          }
                        }
                        if (onBack != null) onBack();
                      }),
                if (showLaIcon)
                  IconButton(
                      tooltip: "Homepage",
                      icon:
                          const Icon(LAIcon.la, size: 34, color: Colors.white),
                      onPressed: () {
                        BeamerCond.of(context, HomeLocation());
                      }),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      if (projectIcon != null && !AppUtils.isDemo())
                        const SizedBox(width: 8),
                      if (projectIcon != null && !AppUtils.isDemo())
                        ImageIcon(NetworkImage(AppUtils.proxyImg(projectIcon)),
                            color: Colors.white, size: 26),
                      if (projectIcon != null && !AppUtils.isDemo())
                        const SizedBox(width: 8),
                      if (titleIcon != null)
                        Icon(titleIcon, size: 26, color: Colors.white),
                      if (titleIcon != null) const SizedBox(width: 8),
                      tooltip != null
                          ? Tooltip(
                              message: "Version: $tooltip",
                              child: _title(title))
                          : _title(title)
                    ]))
              ]),
            ));

  static Text _title(String title) {
    return Text(title,
        style: GoogleFonts.signika(
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400)));
  }
}
