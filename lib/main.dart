import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fyp_project/backend/user/check_user.dart';
import 'package:fyp_project/screens/notification/notification.dart';
import 'package:fyp_project/screens/registration/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'backend/user/user_provider.dart';
import 'package:flutter/services.dart';


Future<void> main() async {
  /// Set System Status Bar and Nav Bar Color:
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark, ));
  /// Firebase SetUp:
  final start = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"]??"";
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env["ONE_SIGNAL_INITIALIZE"]??"");
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addClickListener((event) {
    var screen = event.notification.additionalData?['screen'];
    var userId = event.notification.additionalData?['userId'];
    if (screen == "notification_screen" && userId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationScreen(userId: userId),
        ),
      );
    }
  });
  runApp(
    /// Provide User Data on All Screen:
      MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()), // Add UserProvider
    ],
    child: MyApp()));
  print("App started in ${DateTime.now().difference(start).inMilliseconds} ms");
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,

        scrollBehavior: ScrollBehavior().copyWith(overscroll: false),
      theme:ThemeData(
          /// Overall app color
          primaryColor: Color(0xFF9CCDF2),
          /// Overall app body color:
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
           /// Appbar theme:
           appBarTheme:AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
             centerTitle: true,
             elevation: 0
        ),
        /// Text selection Theme:
          textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black, // Cursor color
          selectionColor: Color(0xFF9CCDF2).withOpacity(0.5), // Text selection highlight color
          selectionHandleColor: Color(0xFF9CCDF2), // Handles color for text selection
        ),

      ),
      debugShowCheckedModeBanner: false,
      home: RoleBasedRedirect(),
    );
  }
}

