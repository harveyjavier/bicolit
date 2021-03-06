import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bicolit/utils/translations.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bicolit/screens/login.dart';
import 'package:bicolit/screens/register_one.dart';
import 'package:bicolit/screens/register_two.dart';
import 'package:bicolit/screens/news_feed.dart';
import 'package:bicolit/screens/profile.dart';
import 'package:bicolit/screens/about.dart';
import 'package:bicolit/screens/edit_education.dart';
import 'package:bicolit/screens/edit_experience.dart';
import 'package:bicolit/screens/notfound_page.dart';

class App extends StatelessWidget {
  final materialApp = MaterialApp(
      title: UIData.appName,
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: UIData.quickFont,
        cursorColor: Colors.black,
        textSelectionColor: Colors.black.withOpacity(0.2),
        textSelectionHandleColor: Colors.black,
        dialogBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      home: Login(),
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", "US"),
        const Locale("hi", "IN"),
      ],
      //initialRoute: UIData.notFoundRoute,

      //routes
      routes: <String, WidgetBuilder>{
        UIData.loginRoute: (BuildContext context) => Login(),
        UIData.registerOneRoute: (BuildContext context) => RegisterOne(),
        UIData.registerTwoRoute: (BuildContext context) => RegisterTwo(),
        UIData.newsFeedRoute: (BuildContext context) => NewsFeed(),
        UIData.profileRoute: (BuildContext context) => Profile(),
        UIData.aboutRoute: (BuildContext context) => About(),
        UIData.editEducationRoute: (BuildContext context) => EditEducation(),
        UIData.editExperienceRoute: (BuildContext context) => EditExperience(),
      },
      onUnknownRoute: (RouteSettings rs) => new MaterialPageRoute(
        builder: (context) => new NotFoundPage(
          appTitle: UIData.coming_soon,
          icon: FontAwesomeIcons.solidSmile,
          title: UIData.coming_soon,
          message: "Under Development",
          iconColor: Colors.green,
        )
      )
  );

  @override
  Widget build(BuildContext context) {
    return materialApp;
  }
}
