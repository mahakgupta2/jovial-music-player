import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymusicplayer_new/presentation/signup_or_signin.dart';
import 'package:mymusicplayer_new/SettingsPage.dart';
import 'package:mymusicplayer_new/whatsnew.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymusicplayer_new/audio_manager.dart';

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

  String extractNameFromEmail(String email) {
    if (email.isEmpty) return "Guest";

    String username = email.split('@')[0];
    username = username.replaceAll(RegExp(r'[0-9]'), '');
    username = username.replaceAll(RegExp(r'[_\.]'), ' ');

    return username
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "")
        .join(" ");
  }

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
              // PROFILE HEADER SECTION
              Row(
                children: [
                  // PROFILE AVATAR
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.grey[900],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Change Profile Picture',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.photo, color: Colors.purple),
                                    ),
                                    title: const Text(
                                      "Choose from Gallery",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker()
                                          .pickImage(source: ImageSource.gallery, imageQuality: 70);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _imageFile = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.purple),
                                    ),
                                    title: const Text(
                                      "Take a Photo",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker()
                                          .pickImage(source: ImageSource.camera, imageQuality: 70);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _imageFile = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // NAME AND EMAIL
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getDisplayName(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "No email",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // MENU ITEMS
              _buildMenuItem(
                context,
                icon: Icons.flash_on,
                title: "What's new",
                subtitle: "Check latest updates",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WhatsNewPage(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: "Settings and privacy",
                subtitle: "Manage your account",
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

              // LOGOUT BUTTON
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: const [
                                Icon(Icons.logout, color: Colors.red, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  "Confirm Logout",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            content: const Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();

                                  // 🔥 STOP AUDIO ON LOGOUT
                                  await AudioManager().stopAudio();

                                  await FirebaseAuth.instance.signOut();

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
                                        content: Text("✅ Logged out successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white24),

              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Music Player App v1.0",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        Color iconColor = Colors.white,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap ?? () => debugPrint("Tapped on $title"),
      ),
    );
  }
}