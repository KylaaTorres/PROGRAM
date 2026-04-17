import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    String name = await LocalStorage.getString('profile_name');
    String email = await LocalStorage.getString('profile_email');

    if (!mounted) return;

    setState(() {
      nameController.text = name.isEmpty ? 'User Name' : name;
      emailController.text = email.isEmpty ? 'Email' : email;
    });
  }

  Future<void> saveProfile() async {
    await LocalStorage.saveString('profile_name', nameController.text);
    await LocalStorage.saveString('profile_email', emailController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundColor: Color(0xFF2E2E2E),
                    child: Icon(
                      Icons.person,
                      size: 110,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              TextField(
                controller: emailController,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white),
              const SizedBox(height: 22),
              InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Row(
                  children: [
                    const SizedBox(width: 24),
                    const Icon(Icons.logout, color: Colors.white, size: 34),
                    const SizedBox(width: 10),
                    Text(
                      'Log out',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF2B2B),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
