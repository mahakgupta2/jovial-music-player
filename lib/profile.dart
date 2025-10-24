import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymusicplayer_new/presentation/signup_or_signin.dart';
import 'package:mymusicplayer_new/SettingsPage.dart';
import 'package:mymusicplayer_new/whatsnew.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String getInitial() {
    if (user?.displayName?.isNotEmpty ?? false) {
      return user!.displayName![0].toUpperCase();
    } else if (user?.email?.isNotEmpty ?? false) {
      return user!.email![0].toUpperCase();
    }
    return "U";
  }

  // ✅ Extract clean name from email
  String extractNameFromEmail(String email) {
    if (email.isEmpty) return "Guest";

    // Take only before '@'
    String username = email.split('@')[0];

    // Remove digits
    username = username.replaceAll(RegExp(r'[0-9]'), '');

    // Replace underscore/dots with spaces
    username = username.replaceAll(RegExp(r'[_\.]'), ' ');

    // Capitalize each word
    return username
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "")
        .join(" ");
  }

  // ✅ Show only extracted name
  String getDisplayName() {
    if (user == null) return "Unknown User";
    String email = user!.email ?? "";
    return user!.displayName ?? extractNameFromEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔰 Profile Avatar with tap
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading:
                              const Icon(Icons.photo, color: Colors.white),
                              title: const Text("Choose from Gallery",
                                  style: TextStyle(color: Colors.white)),
                              onTap: () async {
                                Navigator.pop(context);
                                final pickedFile = await ImagePicker()
                                    .pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70);
                                if (pickedFile != null) {
                                  setState(() {
                                    _imageFile = File(pickedFile.path);
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              title: const Text("Take a Photo",
                                  style: TextStyle(color: Colors.white)),
                              onTap: () async {
                                Navigator.pop(context);
                                final pickedFile = await ImagePicker()
                                    .pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 70);
                                if (pickedFile != null) {
                                  setState(() {
                                    _imageFile = File(pickedFile.path);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.purple,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (user?.photoURL != null
                      ? NetworkImage(user!.photoURL!) as ImageProvider
                      : null),
                  child: (user?.photoURL == null && _imageFile == null)
                      ? Text(
                    getInitial(),
                    style: const TextStyle(
                        fontSize: 24, color: Colors.white),
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  getDisplayName(), // ✅ Only clean name
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  user?.email ?? "No email",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // 🆕 What's New
              _buildMenuItem(
                context,
                icon: Icons.flash_on,
                title: "What's new",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WhatsNewPage(),
                    ),
                  );
                },
              ),

              // ⚙️ Settings
              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: "Settings and privacy",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // 🚪 Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.black,
                          title: const Text("Confirm Logout",
                              style: TextStyle(color: Colors.yellow)),
                          content: const Text(
                            "Are you sure you want to logout?",
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("No",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();

                                // ✅ Clear Firebase session
                                await FirebaseAuth.instance.signOut();

                                // ✅ Clear SharedPreferences
                                final prefs =
                                await SharedPreferences.getInstance();
                                await prefs.clear();

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupOrSignin(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Logged out successfully")),
                                  );
                                }
                              },
                              child: const Text("Yes",
                                  style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout",
                      style: TextStyle(color: Colors.yellow)),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: Colors.white24),

              // 📌 Footer
              const Center(
                child: Text(
                  "Music Player App",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap ?? () => debugPrint("Tapped on $title"),
    );
  }
}
