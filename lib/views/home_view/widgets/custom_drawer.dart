import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_flags/country_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomotodo/core/models/pomotodo_user.dart';
import 'package:pomotodo/core/providers/dark_theme_provider.dart';
import 'package:pomotodo/core/providers/drawer_image_provider.dart';
import 'package:pomotodo/core/providers/locale_provider.dart';
import 'package:pomotodo/l10n/app_l10n.dart';
import 'package:pomotodo/utils/constants/constants.dart';
import 'package:pomotodo/views/edit_password_view/edit_password.view.dart';
import 'package:pomotodo/core/service/firebase_service.dart';
import 'package:pomotodo/views/home_view/widgets/custom_switch.dart';
import 'package:pomotodo/views/home_view/widgets/settings.dart' as settings;
import 'package:pomotodo/views/pomodoro_settings_view/pomodoro_settings.view.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _authService = AuthService();
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  late DrawerImageProvider drawerImageProvider;
  late LocaleModel localeProvider;

  @override
  void initState() {
    super.initState();
    drawerImageProvider =
        Provider.of<DrawerImageProvider>(context, listen: false);
    localeProvider = Provider.of<LocaleModel>(context, listen: false);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => drawerImageProvider.getURL(context, null));
  }

  @override
  Widget build(BuildContext context) {
    // var deneme = FirebaseAuth.instance.currentUser!.providerData
    //     .map((e) => e.providerId).contains('google.com');
    // print('deneme: $deneme');
    var user = users.doc(context.read<PomotodoUser>().userId);
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.745,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              image: const DecorationImage(
                image: AssetImage("assets/images/header.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 50.0,
                  child: Consumer<DrawerImageProvider>(
                    builder: (context, value, child) {
                      return drawerImageProvider.downloadUrl != null
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: drawerImageProvider.downloadUrl!,
                              imageBuilder: (context, imageProvider) {
                                return ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(50),
                                    child: Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                );
                              },
                              placeholder: (context, url) {
                                return ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(20),
                                    child: const CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : ClipOval(
                              child: SizedBox.fromSize(
                                size: const Size.fromRadius(70),
                                child: Image.asset(
                                  'assets/images/person.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                    },
                  ),
                ),
                StreamBuilder(
                    stream: user.snapshots(),
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return Text(L10n.of(context)!.somethingWrong);
                      } else if (asyncSnapshot.hasData &&
                          !asyncSnapshot.data!.exists) {
                        return Text(
                          L10n.of(context)!.uSelectPic,
                          overflow: TextOverflow.clip,
                          maxLines: 3,
                        );
                      } else if (asyncSnapshot.connectionState ==
                          ConnectionState.active) {
                        return Text(
                          "${asyncSnapshot.data.data()["name"]}"
                          " ${asyncSnapshot.data.data()["surname"]}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.normal),
                        );
                      }
                      return Text(L10n.of(context)!.loading);
                    }),
              ],
            ),
          ),
          settings.Settings(
            settingIcon: Icons.account_circle,
            title: settingTitle(context, L10n.of(context)!.accSettings),
            subtitle: L10n.of(context)!.uEditProfile,
            tap: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
          const Divider(thickness: 1),
          Visibility(
            visible: !context.read<PomotodoUser>().loginProviderData!,
            child: Column(
              children: [
                settings.Settings(
                  settingIcon: Icons.password,
                  subtitle: L10n.of(context)!.uChangePassword,
                  title:
                      settingTitle(context, L10n.of(context)!.changePassword),
                  tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditPasswordView()));
                  },
                ),
                const Divider(thickness: 1),
              ],
            ),
          ),
          settings.Settings(
              settingIcon: Icons.notifications,
              subtitle: L10n.of(context)!.uEditNotification,
              title:
                  settingTitle(context, L10n.of(context)!.notificationSettings),
              tap: () {}),
          const Divider(thickness: 1),
          settings.Settings(
              settingIcon: Icons.watch,
              subtitle: L10n.of(context)!.uEditPomodoro,
              title: settingTitle(context, L10n.of(context)!.pomodoroTitle),
              tap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PomodoroSettingsView()));
              }),
          const Divider(thickness: 1),
          settings.Settings(
              settingIcon: Icons.logout,
              subtitle: L10n.of(context)!.logOutAcc,
              title: settingTitle(context, L10n.of(context)!.logOut),
              tap: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: L10n.of(context)!.alertTitleLogOut,
                  text: L10n.of(context)!.alertSubtitleLogOut,
                  confirmBtnText: L10n.of(context)!.alertApprove,
                  cancelBtnText: L10n.of(context)!.alertReject,
                  confirmBtnColor: Theme.of(context).errorColor,
                  onConfirmBtnTap: () async => await _authService.signOut(),
                  onCancelBtnTap: () => Navigator.of(context).pop(false),
                );
              }),
          const Divider(thickness: 1),
          CustomSwitch(
            switchValue: themeChange.darkTheme,
            switchOnChanged: (bool? value) {
              themeChange.darkTheme = value!;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  localeProvider.set(const Locale('tr', 'TR'));
                },
                child: CountryFlags.flag(
                  'tr',
                  height: 40,
                  width: 40,
                  borderRadius: 8,
                ),
              ),
              InkWell(
                onTap: () {
                  localeProvider.set(const Locale('en', 'US'));
                },
                child: CountryFlags.flag(
                  'us',
                  height: 40,
                  width: 40,
                  borderRadius: 8,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Text settingTitle(BuildContext context, String textTitle) => Text(
        textTitle,
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(fontWeight: FontWeight.w400, fontSize: 18),
      );
}
