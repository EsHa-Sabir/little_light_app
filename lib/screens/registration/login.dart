import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:fyp_project/screens/registration/signup.dart';
import '../../backend/firebase_service/firebase_auth_services.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/signup_prompt.dart';
import '../../widgets/social_divider.dart';
import 'forget_password_via_email.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controllers:
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  /// For Validation:
  final _formKey = GlobalKey<FormState>();
  /// For Loading Indicator:
  bool  _isLogin=false;
  /// Forgot Password Options:
  void showForgotOption(){
    showModalBottomSheet(context: context, builder: (context){
      return SafeArea(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      /// Title:
      Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          "Forgot Password?",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins"
          ),
        ),
      ),
      /// Divider:
      Divider(),
     /// Body:
      ListTile(
      leading: Icon(
      Icons.email,
      color: Colors.blue.shade200),
      title: Text(
      "Via Email" ,
      style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: "Poppins"
      ),),
      onTap: () {
                /// Close Bottom Sheet
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ForgetPasswordViaEmailScreen()));

      },
      ),
      ]
      )
      );
    },shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
    top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,);
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBarForLogin("Login", 'assets/images/login/user_icon.png', true,context),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Image (Responsive)
                SizedBox(
                  height: screenHeight * 0.3,
                  child: Center(
                    child: Image.asset(
                      'assets/images/login/login_image.png',
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                /// Email Field
                CustomTextField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Password Field
                CustomTextField(
                  controller: passwordController,
                  icon: Icons.lock_outline_rounded,
                  label: 'Password',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                SizedBox(height: screenHeight * 0.01),
                /// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.05),
                    child: InkWell(
                      onTap: () => showForgotOption(),
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Color(0x99000000),
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                /// Login Button
                SizedBox(
                  width: 270,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLogin = true);
                        await FirebaseAuthServices().loginUser(
                          email: emailController.text,
                          password: passwordController.text,
                          context: context,
                        );
                        setState(() => _isLogin = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9CCDF2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    ),
                    child: _isLogin
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                /// Divider
                SocialDivider(),
                SizedBox(height: screenHeight * 0.04),
                /// SignUp Prompt
                SignupPrompt(
                  prompt: 'Sign Up',
                  text: "You don't have an account?",
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}