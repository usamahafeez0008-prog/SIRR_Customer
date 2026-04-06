import 'package:customer/constant/constant.dart';
import 'package:customer/lang/app_ar.dart';
import 'package:customer/lang/app_en.dart';
import 'package:customer/lang/app_fr.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  static Locale get currentLocale {
    if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
      return Locale(Constant.getLanguage().code.toString());
    }
    return locale;
  }

  static final locales = [
    const Locale('en'),
    const Locale('ar'),
    const Locale('fr'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enUS,
        'ar': arAR,
        'fr': frFR,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(lang));
    });
  }

/*  void changeLocale(String lang) {
    Locale? newLocale;
    if (lang.contains('_')) {
      var split = lang.split('_');
      newLocale = Locale(split[0], split[1]);
    } else {
      newLocale = Locale(lang);
    }
    
    Get.updateLocale(newLocale);
  }*/
}
