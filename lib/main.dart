import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pomotodo/core/models/pomotodo_user.dart';
import 'package:pomotodo/core/providers/drawer_image_provider.dart';
import 'package:pomotodo/core/providers/leaderboard_provider.dart';
import 'package:pomotodo/core/providers/list_update_provider.dart';
import 'package:pomotodo/core/providers/spotify_provider.dart';
import 'package:pomotodo/core/providers/task_stats_provider.dart';
import 'package:pomotodo/core/providers/tasks_provider.dart';
import 'package:pomotodo/views/archived_task_view/archived_task.view.dart';
import 'package:pomotodo/views/auth_view/auth_widget.dart';
import 'package:pomotodo/views/auth_view/auth_widget_builder.dart';
import 'package:pomotodo/views/completed_task_view/completed_task.view.dart';
import 'package:pomotodo/views/deleted_task_view/deleted_task.view.dart';
import 'package:pomotodo/views/leaderboard_view/leaderboard.view.dart';
import 'package:pomotodo/views/task_statistics/task_statistics.view.dart';
import 'package:pomotodo/views/edit_profile_view/edit_profile.view.dart';
import 'package:pomotodo/views/edit_task_view/edit_task.view.dart';
import 'package:pomotodo/views/home_view/home.view.dart';
import 'package:pomotodo/core/providers/dark_theme_provider.dart';
import 'package:pomotodo/core/service/firebase_service.dart';
import 'package:pomotodo/core/service/i_auth_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  ThemeData theme, themeDark;
  WidgetsFlutterBinding.ensureInitialized();

  Future<ThemeData> loadTheme(String path) async {
    final themeStr = await rootBundle.loadString(path);
    final themeJson = jsonDecode(themeStr);
    final theme = ThemeDecoder.decodeThemeData(themeJson)!;
    return theme;
  }

  theme = await loadTheme("assets/app_theme/appainter_theme.json");
  themeDark = await loadTheme("assets/app_theme/appainter_theme_dark.json");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var initializationSettingsAndroid =
      const AndroidInitializationSettings("google");
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        Provider<IAuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => SpotifyProvider()),
        Provider.value(value: await SharedPreferences.getInstance()),
      ],
      child: MyApp(theme: theme, themeDark: themeDark),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.theme, required this.themeDark})
      : super(key: key);
  final ThemeData theme;
  final ThemeData themeDark;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: AuthWidgetBuilder(
          onPageBuilder: (context, AsyncSnapshot<PomotodoUser?> snapShot) =>
              MaterialApp(
                  localizationsDelegates: const [
                    SfGlobalLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  navigatorObservers: [FlutterSmartDialog.observer],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('tr'),
                  ],
                  locale: const Locale('tr'),
                  builder: FlutterSmartDialog.init(),
                  initialRoute: '/',
                  routes: {
                    '/task': (context) => const HomeView(),
                    '/done': (context) => const CompletedTasksView(),
                    '/editTask': (context) => const EditTaskView(),
                    '/deleted': (context) => ChangeNotifierProvider<ListUpdate>(
                          create: (context) => ListUpdate(),
                          child: const DeletedTasksView(),
                        ),
                    '/editProfile': (context) => const EditProfileView(),
                    '/archived': (context) => const ArchivedTasksView(),
                    '/taskStatistics': (context) => ChangeNotifierProvider(
                          create: (context) => TaskStatsProvider(),
                          child: const TaskStatisticsView(),
                        ),
                    '/leaderboard': (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (context) => DrawerImageProvider(),
                            ),
                            ChangeNotifierProvider(
                              create: (context) => LeaderboardProvider(),
                            ),
                            ChangeNotifierProvider(
                              create: (context) => TaskStatsProvider(),
                            )
                          ],
                          child: const LeaderboardView(),
                        )
                  },
                  debugShowCheckedModeBanner: false,
                  theme: context.watch<DarkThemeProvider>().darkTheme
                      ? widget.themeDark
                      : widget.theme,
                  home: AuthWidget(snapShot: snapShot))),
    );
  }
}
