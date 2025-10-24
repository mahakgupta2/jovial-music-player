import 'package:mymusicplayer_new/common/widget/button/basic_app_button.dart';
import 'package:mymusicplayer_new/core/configs/assets/app_images.dart';
import 'package:mymusicplayer_new/core/configs/assets/app_vectors.dart';
import 'package:mymusicplayer_new/presentation/sign%20up.dart';
import 'package:mymusicplayer_new/presentation/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupOrSignin extends StatelessWidget {
  const SignupOrSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔲 App background theme

      body: Stack(
        children: [
          // 🎵 Background Image (Optional)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(AppImages.authBG),
              ),
            ),
          ),

          // 🌟 Foreground Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔊 App Logo
                  SvgPicture.asset(
                    AppVectors.logo,
                    width: 300,
                  ),
                  const SizedBox(height: 30),

                  // 🎶 App Title (Mixed Yellow + White)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Enjoy Listening To '),
                        TextSpan(
                          text: 'Jovial Music',
                          style: TextStyle(color: Colors.yellowAccent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 💬 Subtitle
                  const Text(
                    'Jovial is a joyful and seamless music experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔘 Buttons
                  Row(
                    children: [
                      // 🟡 Register (Yellow button)
                      Expanded(
                        child: BasicAppButton(
                          title: 'Register',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignupPage()),
                            );
                          },
                          backgroundColor: Colors.yellowAccent,
                          textColor: Colors.black,
                          borderRadius: 12,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // ⚪ Sign In (White button)
                      Expanded(
                        child: BasicAppButton(
                          title: 'Sign In',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SigninPage()),
                            );
                          },
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          borderRadius: 12,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
