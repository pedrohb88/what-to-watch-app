import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:what_to_watch/app_language.dart';
import 'package:what_to_watch/app_settings.dart';

class LanguageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguage>(builder: (context, appLanguage, child) {
      var dropdownItems = <DropdownMenuItem>[];
      appLanguage.supportedLocales.forEach((languageName, languageCode) {
        dropdownItems.add(
          DropdownMenuItem(
            value: languageCode,
            child: Text(
              languageName,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      });

      return Theme(
        data: ThemeData(
          canvasColor: Color(0xFF3b3939),
          textSelectionColor: Colors.white,
        ),
        child: Consumer<AppSettings>(builder: (context, appSettings, child) {
          return DropdownButton(
            //isExpanded: true,
            value: appLanguage.appLocale,
            items: dropdownItems,
            onChanged: (selectedLocale) {
              appSettings.isLoading = true;

              //dirty fix for console error
              Future.delayed(const Duration(milliseconds: 300), () async {
                await appLanguage.changeLanguage(selectedLocale);
                appSettings.isLoading = false;
              });
            },
          );
        }),
      );
    });
  }
}
