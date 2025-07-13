import 'package:flutter/material.dart';
import 'package:fyp_project/screens/registration/login.dart';
import '../../backend/firebase_service/firebase_auth_services.dart';
import '../../widgets/appbar.dart';
import '../../widgets/signup_prompt.dart';
import '../../widgets/social_divider.dart';
import '../../widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  /// Controllers:
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();

  var selectedRole;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      appBar: customAppBarForLogin(
          "Sign Up", 'assets/images/login/user_icon.png', true, context),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.12),

                  /// Username Field:
                  CustomTextField(
                    controller: usernameController,
                    icon: Icons.person_outline,
                    label: 'Username',
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a username' : null,
                    onChanged:(value) {},
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  /// Email Field:
                  CustomTextField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter an email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                    onChanged:(value) {},
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  /// Password Field:
                  CustomTextField(
                    controller: passwordController,
                    icon: Icons.lock_outline_sharp,
                    label: 'Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter password';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                    onChanged:(value) {},
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  /// Mobile Field:
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    controller: mobileController,
                    icon: Icons.phone_android,
                    label: 'Mobile',
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter phone number';
                      return null;

                    },
                    onChanged:(value) {},
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  /// Dropdown Role Field:
                  CustomTextField(
                    icon: Icons.person_outline,
                    label: 'Select Role',
                    isDropdown: true,
                    dropdownItems: ['Donor', 'Volunteer', 'Requester'],
                    onChanged: (value) => selectedRole = value,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a role' : null,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  /// Sign Up Button:
                  SizedBox(
                    width: 270, // Responsive button width
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSignUp = true);

                          final flag = await FirebaseAuthServices().signupUser(
                            email: emailController.text,
                            password: passwordController.text,
                            role: selectedRole,
                            username: usernameController.text,
                            mobile: mobileController.text,
                            context: context,
                          );

                          if (flag) {
                            emailController.clear();
                            passwordController.clear();
                            usernameController.clear();
                            mobileController.clear();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          }

                          setState(() => _isSignUp = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9CCCF2),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isSignUp
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04, // Responsive font size
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  /// Divider:
                  SocialDivider(),
                  SizedBox(height: screenHeight * 0.04),

                  /// Sign In Prompt:
                  SignupPrompt(
                    prompt: 'Sign in',
                    text: "Already have an account?",
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
