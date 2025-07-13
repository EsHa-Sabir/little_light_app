import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/admin/navbar/navbar.dart';
import 'package:fyp_project/screens/donation/navbar/navbar.dart';
import 'package:fyp_project/screens/requesters/navBar.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:fyp_project/screens/volunteer/home.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


/// FirebaseAuthServices:
class FirebaseAuthServices{
  /// FirebaseAuth and Firestore Object:
  final FirebaseAuth _auth= FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var verificationId='';

/// SignUp Function:
  Future<bool> signupUser({required String username, required String email, required String password, required String mobile, required String role,required BuildContext context}) async {
    try {
      /// Create user in Firebase Authentication:
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      /// Send verification email after user registration
      User? user = userCredential.user;
      var playerId = await OneSignal.User.pushSubscription.id;
      print('player id: $playerId');
      if (user != null) {
        await user.sendEmailVerification();

        /// Add User in Firestore:
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'mobile': mobile,
          'role': role,
          'image': null,
          'playerId':playerId

        });
        showToast(message: "You have been successfully registered.",context: context);
        return true;
      } else {
        showToast(message: "User registration failed.",context: context);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: "The email address is already in use.",context: context);
      }
      else {
        showToast(message: "An error occurred: ${e.code.toString()}",context: context);
      }
      return false;
    } catch (e) {
      showToast(message: "Something went wrong. Please try again.",context: context);
      print("Error: $e");
      return false;
    }
  }
  /// Login Function:
  Future<void> loginUser({required BuildContext context, required String email, required String password}) async {
    try {
      /// Login with Firebase Authentication:
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      /// Fetch user data from Firestore for role based login:
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists) {
        String role = userDoc['role'];
        /// Navigate based on role:
        if (role == 'Donor') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => DonorNavigationBar()));
        }
        else if (role == 'Volunteer') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => VolunteerScreen()));
        }
        else if (role == 'Requester') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => RequesterNavBar()));
        } else if (role == 'Admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => AdminNavigationBar()));
        }

      } else {
        showToast(message: "Role not found", context: context);// Return error message
      }
    } on FirebaseAuthException catch (e) {
      if(e.code=='user-not-found'
          ||e.code=='wrong-password'
          ||e.code == 'invalid-email'
          ||e.code=="invalid-credential"){
        showToast(message: "Invalid Email or Password", context: context);
      }
      else {
        showToast(message: "An error occurred: ${e.code.toString()} ", context: context);
      }

    }
  }
/// Function to send password Reset Email:
  Future<bool> sendPasswordResetEmailDirect(String email,BuildContext context) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty){
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      showToast(message: "Password reset email sent successfully.",context: context);
      return true;
      }
      else{
        showToast(message: "No user found for this email",context: context);
        return false;
      }
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(message: "No user found with this email.",context: context);
      }
      else if (e.code == 'invalid-email') {
        showToast(message: "Invalid email format.",context: context);
      }
      else {
        showToast(message: "An error occurred: ${e.message}",context: context);
      }
      return false;
    } catch (e) {
      showToast(message: "Something went wrong. Please try again.",context: context);
      return false;
    }
  }
  /// Delete all user messages function:
  Future<void> _deleteUserMessages(String userId) async {
    try {
      /// Delete messages sent by the user
      QuerySnapshot sentMessages = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId)
          .get();
      for (var doc in sentMessages.docs) {
        await doc.reference.delete();
      }
      /// Delete messages received by the user
      QuerySnapshot receivedMessages = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .get();
      for (var doc in receivedMessages.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception("Failed to delete messages: $e");
    }
  }
  /// Delete Firestore data:
  Future<void> _deleteUserData(String userId) async {
    try {
      /// Delete user document
      await _firestore.collection('users').doc(userId).delete();
      /// Delete messages
      await _deleteUserMessages(userId);
    } catch (e) {
      throw Exception("Failed to delete user data: $e");
    }
  }
  /// Delete Firebase Auth account:
  Future<void> deleteAccount(String password,BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        /// Re-authenticate user:
        final email = user.email!;
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        /// Delete Firestore data
        await _deleteUserData(user.uid);
        /// Delete Firebase Auth account
        await user.delete();
        showToast(message: "User delete successfully",context: context);
      } else {
        showToast(message: "No user is currently signed in.",context: context);
      }
    } catch (e) {
      showToast(message: "Account deletion failed: $e",context: context);
    }
  }

}
