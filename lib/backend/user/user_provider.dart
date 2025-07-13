import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/toast_message.dart';

class UserProvider with ChangeNotifier {
  /// Firebase Auth and Firestore Object:
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  /// Getter to access user data:
  Map<String, dynamic>? get userData => _userData;
  /// Fetch user data from Firestore:
  Future<void> fetchUserData(String uid,BuildContext context) async {
    if (uid.isNotEmpty) {
      try {
        /// Get data from firestore:
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          _userData = userDoc.data();
          /// Notify all listeners that user data has changed:
          notifyListeners();
        } else {
          showToast(message: "User data not found.",context: context);
        }
      } catch (e) {
        showToast(message: "Error fetching user data: $e",context: context);
      }
    } else {
      showToast(message: "User is not logged in.",context: context);
    }
  }
  /// Update user data in Firestore and locally:
  Future<void> updateUserData({required String userId, required String username, required String? about, required String mobile, required String country, required String address, required String? image,required BuildContext context}) async {
    try {
      /// Update date in firestore:
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        "username": username,
        "about": about,
        "mobile": mobile,
        "country": country,
        "address": address,
        "image": image,
      });
      /// Update the local copy of user data:
      _userData = {
        "username": username,
        "about": about,
        "mobile": mobile,
        "country": country,
        "address": address,
        "image": image,
      };
    /// Notify listeners about the update:
      notifyListeners();
      showToast(message: "Update Successfully",context: context);
    } catch (e) {
      showToast(message: "An Error Occurred: $e",context: context);
    }

  }
  /// Delete User Image In Firestore:
  Future<void> deleteImage({required String userId, required String? image, required String username, required String about, required String mobile, required String country, required String address,required BuildContext context}) async {
    try {
      /// Uodate Image from firestore:
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        "image": image,
        "username": username,
        "about": about,
        "mobile": mobile,
        "country": country,
        "address": address,
      });
      /// Update the local copy of user data:
      _userData = {
        "image": image,
        "username": username,
        "about": about,
        "mobile": mobile,
        "country": country,
        "address": address,
      };
      /// Notify listeners about the update:
      notifyListeners();
    } catch (e) {
      showToast(message: "An Error Occurred: $e",context: context);
    }

  }
  /// Update email function:
  Future<void> updateEmail(String newEmail, String password,BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        /// Check if the new email format is valid
        if (!newEmail.contains('@') || !newEmail.contains('.')) {
          showToast(message: "Invalid email format.",context: context);
          return;
        }
        /// Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        /// Verify before updating the email
        await user.verifyBeforeUpdateEmail(newEmail);
        /// Update email in Firestore after verification
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
            _userData?['email']=newEmail;
        showToast(message: "Email update initiated. Please verify the new email.",context: context);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            showToast(message: "You need to log in again to update your email.",context: context);
            break;
          case 'email-already-in-use':
            showToast(message: "This email is already in use.",context: context);
            break;
          case 'invalid-email':
            showToast(message: "The email address is badly formatted.",context: context);
            break;
          case 'operation-not-allowed':
            showToast(message: "Email updates are not allowed for this Firebase project.",context: context);
            break;
          default:
            showToast(message: "Error updating email: ${e.message}",context: context);
        }
      } else {
        showToast(message: "Unknown error: $e",context: context);
      }
      print(e); // Log the error for debugging
    }
  }
  /// Update password function:
  Future<void> updatePassword(String currentPassword, String newPassword,BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        /// Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        /// Update the password
        await user.updatePassword(newPassword);
        showToast(message: "Password updated successfully.",context: context);
      } else {
        showToast(message: "No user is currently signed in.",context: context);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            showToast(message: "The current password is incorrect.",context: context);
            break;
          case 'user-not-found':
            showToast(message: "No user found for this email.",context: context);
            break;
          case 'invalid-credential':
            showToast(message: "The provided credentials are invalid or expired.",context: context);
            break;
          case 'requires-recent-login':
            showToast(
              message:
              "You need to log in again to perform this sensitive operation.",context: context
            );
            break;
          default:
            showToast(message: "Error updating password: ${e.message}",context: context);
        }
      } else {
        showToast(message: "Unknown error: $e",context: context);
      }
      print(e); // Log the error for debugging
    }
  }

  }






