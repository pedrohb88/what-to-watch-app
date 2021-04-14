import 'package:flutter/material.dart';
import 'package:what_to_watch/app_body.dart';
import 'package:what_to_watch/app_localizations.dart';
import 'package:what_to_watch/app_settings.dart';
import 'language_dropdown.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _buildLoader() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
      ),
      body: AppBody(
        child: Center(
          child: ListView(
            children: <Widget>[
              SettingsListTile(
                vertical: true,
                icon: Icons.language,
                label: AppLocalizations.of(context).translate('language'),
                inputField: LanguageDropdown(),
              ),
            ],
          ),
        ),
      ),
    );

    return Consumer<AppSettings>(
      builder: (context, appSettings, child) {
        if (appSettings.isLoading) {
          return Stack(
            children: <Widget>[
              scaffold,
              _buildLoader(),
            ],
          );
        } else {
          return scaffold;
        }
      },
    );
  }
}

class SettingsListTile extends StatelessWidget {
  String label;
  IconData icon;
  Widget inputField;

  bool vertical;

  final _iconPadding = EdgeInsets.only(right: 8.0);
  final _marginBottom = EdgeInsets.only(bottom: 16.0);

  SettingsListTile({
    @required this.label,
    @required this.icon,
    @required this.inputField,
    this.vertical = false,
  })  : assert(label != null),
        assert(icon != null),
        assert(inputField != null);

  @override
  Widget build(BuildContext context) {
    if (!vertical) {
      return Container(
        margin: _marginBottom,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: _iconPadding,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                Text(label),
              ],
            ),
            inputField,
          ],
        ),
      );
    } else {
      return Container(
        margin: _marginBottom,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: _iconPadding,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
                Text(label),
              ],
            ),
            inputField,
          ],
        ),
      );
    }
  }
}
