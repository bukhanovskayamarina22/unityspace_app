import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wstore/wstore.dart';

class LoginScreenStore extends WStore {
  // TODO: add data here...

  @override
  LoginScreen get widget => super.widget as LoginScreen;
}

class LoginScreen extends WStoreWidget<LoginScreenStore> {
  const LoginScreen({
    super.key,
  });

  @override
  LoginScreenStore createWStore() => LoginScreenStore();

  @override
  Widget build(BuildContext context, LoginScreenStore store) {
    return Scaffold(
      backgroundColor: const Color(0xFF111012),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/icons/app_icon.svg',
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Пространства',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Войдите через',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 32 / 28,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'или с помощью электронной почты',
                style: TextStyle(
                  fontSize: 14,
                  height: 24 / 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minWidth: double.infinity,
                height: 40,
                elevation: 2,
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/email');
                },
                child: const Text(
                  'Ввести емайл',
                  style: TextStyle(
                    color: Color(0xFF111012),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
