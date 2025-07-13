import 'package:flutter/material.dart';
import 'package:fyp_project/backend/firebase_service/firebase_auth_services.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:fyp_project/screens/registration/login.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/signup_prompt.dart';
import '../../widgets/social_divider.dart';


class ForgetPasswordViaEmailScreen extends StatefulWidget {
  const ForgetPasswordViaEmailScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordViaEmailScreen> createState() => _ForgetPasswordViaEmailScreenState();
}

class _ForgetPasswordViaEmailScreenState extends State<ForgetPasswordViaEmailScreen> {
  /// Controllers:
  var emailController=TextEditingController();
  /// For Validation:
  final _formKey = GlobalKey<FormState>();
  /// For Loading Indicator:
  bool _isSubmit=false;

  @override
  Widget build(BuildContext context) {

    return
      Scaffold(
        /// Appbar:
        appBar: customAppBarForLogin(
            "Forget Password?",
            'assets/images/login/lock.png',
            false,
            context
        ),
        /// Body:
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  /// Forget Password Image:
                  Center(
                    child: Image.asset(
                      'assets/images/login/forgot_password.png',
                      width: screenWidth * 0.75,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  /// Text:
                  Center(
                    child: Text(
                      "Don't worry! Please enter the email address",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.035,
                        color: const Color(0xFF5B5B5B),
                        letterSpacing: 0.07,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  /// Text:
                  Center(
                    child: Text(
                      "associated with your account.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.035,
                        color: const Color(0xFF5B5B5B),
                        letterSpacing: 0.07,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.07),
                  /// Form:
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// Email Field:
                        CustomTextField(
                          controller: emailController,
                          icon: Icons.email_outlined,
                          label: 'via Email',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        /// Submit Button:
                        SizedBox(
                          width: 270,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSubmit = true;
                                });
                                /// Call the password reset email function
                                await FirebaseAuthServices().sendPasswordResetEmailDirect(
                                    emailController.text,
                                    context
                                );
                                emailController.clear();

                                setState(() {
                                  _isSubmit = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9CCCF2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015), // Responsive padding
                            ),
                            child: _isSubmit
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  /// Divider:
                  SocialDivider(),
                  SizedBox(height: screenHeight * 0.04),
                  /// Back Button:
                  SignupPrompt(
                    prompt: 'Back',
                    text: "",
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen())
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
  }






  }