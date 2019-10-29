import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bicolit/utils/translations.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bicolit/screens/login.dart';
import 'package:bicolit/screens/registerOne.dart';
import 'package:bicolit/screens/registerTwo.dart';
// import 'package:bicolit/screens/registerThree.dart';
// import 'package:bicolit/screens/registerFour.dart';
//import 'package:bicolit/screens/newsFeed.dart';
//import 'package:bicolit/screens/profile.dart';
//import 'package:bicolit/screens/notfound_page.dart';

class App extends StatelessWidget {
  final materialApp = MaterialApp(
      title: UIData.appName,
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: UIData.quickFont,
        cursorColor: Colors.black,
        textSelectionColor: Colors.black.withOpacity(0.2),
        textSelectionHandleColor: Colors.black,
        dialogBackgroundColor: Colors.black,
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
      // initialRoute: UIData.notFoundRoute,

      //routes
      routes: <String, WidgetBuilder>{
        UIData.loginRoute: (BuildContext context) => Login(),
        UIData.registerOneRoute: (BuildContext context) => RegisterOne(),
        UIData.registerTwoRoute: (BuildContext context) => RegisterTwo(),
        // UIData.registerThreeRoute: (BuildContext context) => RegisterThree(),
        // UIData.registerFourRoute: (BuildContext context) => RegisterFour(),
        //UIData.newsFeedRoute: (BuildContext context) => NewsFeed(),
        //UIData.profileRoute: (BuildContext context) => Profile(),
      },
      // onUnknownRoute: (RouteSettings rs) => new MaterialPageRoute(
      //   builder: (context) => new NotFoundPage(
      //     appTitle: UIData.coming_soon,
      //     icon: FontAwesomeIcons.solidSmile,
      //     title: UIData.coming_soon,
      //     message: "Under Development",
      //     iconColor: Colors.green,
      //   )
      // )
  );

  @override
  Widget build(BuildContext context) {
    return materialApp;
  }
}
