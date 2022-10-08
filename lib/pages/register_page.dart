import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/service/i_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<IAuthService>(context, listen: false);
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var register = "Kayıt Ol";
    var subtitle = "Aşağıdaki alanları doldurarak kaydolabilirsiniz.🙂";
    var name = "Ad";
    var surname = "Soyad";
    var email = "Email";
    var password = "Şifre";
    var yourName = "Adınız";
    var yourSurname = "Soyadınız";
    var yourBirthday = "Doğum Tarihiniz";

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _surnameController = TextEditingController();
    final TextEditingController _birthdayController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  ModalRoute.withName("/Home"));
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.blueGrey[300])),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: ScreenPadding().screenPadding.copyWith(top: 0),
          child: Column(
            children: [
              ScreenTexts(
                  title: register,
                  theme: Theme.of(context).textTheme.headline4,
                  fontW: FontWeight.w600,
                  textPosition: TextAlign.left),
              ScreenTexts(
                  title: subtitle,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w400,
                  textPosition: TextAlign.left),
              ScreenTexts(
                  title: yourName,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w500,
                  textPosition: TextAlign.left),
              ScreenTextField(
                  textLabel: name,
                  obscure: false,
                  controller: _nameController,
                  height: 70,
                  maxLines: 1),
              ScreenTexts(
                  title: yourSurname,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w500,
                  textPosition: TextAlign.left),
              ScreenTextField(
                  textLabel: surname,
                  obscure: false,
                  controller: _surnameController,
                  height: 70,
                  maxLines: 1),
              ScreenTexts(
                  title: email,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w500,
                  textPosition: TextAlign.left),
              ScreenTextField(
                  textLabel: email,
                  obscure: false,
                  controller: _emailController,
                  height: 70,
                  maxLines: 1),
              ScreenTexts(
                  title: password,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w500,
                  textPosition: TextAlign.left),
              ScreenTextField(
                  textLabel: password,
                  obscure: true,
                  controller: _passwordController,
                  height: 70,
                  maxLines: 1),
              ScreenTexts(
                  title: yourBirthday,
                  theme: Theme.of(context).textTheme.subtitle1,
                  fontW: FontWeight.w500,
                  textPosition: TextAlign.left),
              ScreenTextField(
                onTouch: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2100));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate =
                        DateFormat('dd.MM.yyyy').format(pickedDate);
                    print(
                        formattedDate); //formatted date output using intl package =>  2021-03-16

                    _birthdayController.text =
                        formattedDate; //set output date to TextField value.

                  } else {}
                },
                con: const Icon(Icons.calendar_today),
                textLabel: yourBirthday,
                obscure: false,
                controller: _birthdayController,
                height: 70,
                maxLines: 1,
              ),
              Container(height: 30),
              SizedBox(
                  width: 400,
                  height: 60,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () async {
                        try {
                          await _authService.createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('Şifre güçsüz.');
                          } else if (e.code == 'email-already-in-use') {
                            print(
                                'Aynı e-posta adresine sahip başka bir hesap var.');
                          }
                        } catch (e) {
                          print(e);
                        }

                        CollectionReference users =
                            FirebaseFirestore.instance.collection('Users');

                        users.doc(FirebaseAuth.instance.currentUser!.uid).set({
                          'email': _emailController.text,
                          'name': _nameController.text,
                          'surname': _surnameController.text,
                          'birthday': _birthdayController.text
                        });
                      },
                      child: const Text("Kayıt Ol"))),
            ],
          ),
        ),
      ),
    );
  }
}
