import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mymusicplayer_new/presentation/signup_or_signin.dart';
import 'package:mymusicplayer_new/SettingsPage.dart';
import 'package:mymusicplayer_new/whatsnew.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymusicplayer_new/audio_manager.dart';
import 'music_player_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  File? _imageFile;

  String getInitial() {
    String name = getDisplayName();
    return name.isNotEmpty ? name[0].toUpperCase() : "U";
  }

  String extractNameFromEmail(String email) {
    if (email.isEmpty) return "Guest";

    String username = email.split('@')[0];
    username = username.replaceAll(RegExp(r'[0-9]'), '');
    username = username.replaceAll('_', ' ').replaceAll('.', ' ');
    username = username.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
    );

    List<String> words =
    username.split(' ').where((e) => e.isNotEmpty).toList();

    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String getDisplayName() {
    if (user == null) return "Unknown User";
    return extractNameFromEmail(user!.email ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ✅ STACK for MiniPlayer
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= PROFILE HEADER =================
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.purple,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null) as ImageProvider?,
                              child: (_imageFile == null &&
                                  user?.photoURL == null)
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
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDisplayName(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? "No email",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  _buildMenuItem(
                    icon: Icons.flash_on,
                    title: "What's new",
                    subtitle: "Check latest updates",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WhatsNewPage()),
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.settings,
                    title: "Settings and privacy",
                    subtitle: "Manage your account",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),

                  const Spacer(),

                  // ================= LOGOUT =================
                  Center(
                    child: TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout",
                          style:
                          TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const Center(
                    child: Text(
                      "Music Player App v1.0",
                      style:
                      TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= MINI PLAYER =================
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE PICKER =================
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.purple),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text("Take a Photo",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT FUNCTION =================
  Future<void> _logout() async {
    await AudioManager().stopAudio();

    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignupOrSignin()),
          (_) => false,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle!,
            style:
            const TextStyle(color: Colors.grey, fontSize: 12))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}
