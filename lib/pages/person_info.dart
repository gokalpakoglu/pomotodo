import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/task.dart';
import 'package:flutter_application_1/project_theme_options.dart';
import 'package:flutter_application_1/service/i_auth_service.dart';
import 'package:provider/provider.dart';

class PersonInfo extends StatelessWidget with ProjectThemeOptions {
  PersonInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<IAuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: ProjectThemeOptions().systemTheme,
        backgroundColor: ProjectThemeOptions().backGroundColor,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => TaskView()),
                  ModalRoute.withName("/Task"));
            }),
      ),
      body: Column(
        children: const [
          TaskAdded(
            title: "Profil İsmi",
            subtitle: "Profilinizi düzenleyebilirsiniz",
            //onTap: () {},
          ),
          TaskAdded(
            title: "Şifreyi Değiştir",
            subtitle: "Şifrenizi Değiştirebilirsiniz",
            //onTap: () {},
          ),
          TaskAdded(
            title: "Bildirim Ayarı",
            subtitle:
                "Bu kısımda almak istediğiniz bildirimleri seçebilirsiniz",
            //onTap: () {},
          ),
          TaskAdded(
            title: "Pomodoro Ayarı",
            subtitle:
                "Bu kısımda pomodoro ve ara dakikalarını,sayısını değiştirebilirsiniz",
            //onTap: () {},
          ),
          TaskAdded(
            title: "Çıkış Yap",
            subtitle: "Hesaptan çıkış yapın",
            // onTap: () async {
            //   await _authService.signOut();
            // },
          ),
          // SizedBox(
          //     width: 400,
          //     height: 60,
          //     child: ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //             shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20))),
          //         onPressed: () async {
          //           await _authService.signOut();
          //         },
          //         child: const Text("Çıkış Yap"))),
        ],
      ),
    );
  }
}
