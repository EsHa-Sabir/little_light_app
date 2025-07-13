import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../backend/user/user_provider.dart';
import '../../widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  /// Text Editing Controllers:
  var usernameController=new TextEditingController();
  var aboutController=new TextEditingController();
  var countryController=new TextEditingController();
  var phoneController=new TextEditingController();
  var addressController=new TextEditingController();
  /// Get Id:
  String? userId;
  /// Upload Image:
  String? uploadedImageUrl;
  /// Image File:
  File? imageFile;
  /// For Loading Purpose:
  bool isUpdate=false;
@override
void initState() {
  super.initState();
  /// Get Current User Id From Firebase Auth:
  userId = FirebaseAuth.instance.currentUser?.uid;
  /// Fetch user data and pre-fill controllers:
  if (userId != null) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserData(userId!,context).then((_) {
      final userData = userProvider.userData;
      setState(() {
        usernameController.text = userData?['username'] ?? '';
        aboutController.text = userData?['about'] ?? '';
        phoneController.text = userData?['mobile'] ?? '';
        countryController.text = userData?['country'] ?? '';
        addressController.text = userData?['address'] ?? '';
        uploadedImageUrl = userData?['image'];
      });
    });
  }
}
/// Show Photo Options:
void showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Title:
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  "Upload Profile Picture",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins"
                  ),
                ),
              ),
              /// Divider:
              Divider(),
              /// Pick from Gallery:
              ListTile(
                leading: Icon(
                Icons.photo,
                color: Colors.blue),
                title: Text(
                  "Select from Gallery" ,
                style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins"
        ),),
                onTap: () {
                  /// Close Bottom Sheet
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
              ),
              /// Take Photo From Camera:
              ListTile(
                leading: Icon(
                Icons.camera_alt,
                 color: Colors.green),
                title: Text(
                  "Take a Photo",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins"
                ),),
                onTap: () {
                  /// Close Bottom Sheet
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
              ),
              /// Delete Picture
              ListTile(
                leading: Icon(
                    Icons.delete_forever,
                    color: Colors.red),
                title: Text(
                  "Delete Picture",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins"
                ),),
                onTap: () {
                  /// Close Bottom Sheet
                  Navigator.pop(context);
                  deleteProfilePicture();
                },
              ),
              /// Cancel Option
              ListTile(
                leading: Icon(
                    Icons.close,
                    color: Colors.grey),
                title: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins"
                ),),
                onTap: () {
                  /// Close Bottom Sheet
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
/// Upload Profile Images In Cloudinary:
Future<String?> uploadImageToCloudinary(File image) async {
    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dq1wxrgb5/image/upload";
    const uploadPreset = "profile_image";
    try {
      final request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        return data['secure_url']; // Cloudinary image URL
      } else {
        showToast(message: "Image upload failed. Try again.",context: context);
        return null;
      }
    } catch (e) {
      showToast(message: "Error: $e",context: context);
      return null;
    }
  }

/// Delete Profile Picture:
  Future<void> deleteProfilePicture() async {
    if (userId == null || uploadedImageUrl == null) {
      showToast(message: "No image to delete.",context: context);
      return;
    }
    try {
      /// Remove the image URL from Firestore:
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.deleteImage(
          userId: userId!,
          image: null,
          username: usernameController.text,
          about: aboutController.text,
          mobile: phoneController.text,
          country: countryController.text,
          address: addressController.text,context: context
      );
      /// Update the state to reflect the changes:
      setState(() {
        uploadedImageUrl = null;
        imageFile = null;
      });
      showToast(message: "Profile picture deleted successfully.",context: context);
    } catch (e) {
      showToast(message: "Error deleting image: $e",context: context);
    }
  }







  /// Select Image Function:
  void selectImage(ImageSource source) async{
    XFile? pickFile= await ImagePicker().pickImage(source: source);
    if (pickFile != null) {
      String fileExtension = pickFile.path.split('.').last.toLowerCase(); // Get file extension
      if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
        cropImage(File(pickFile.path));
      } else {
        showToast(message: "Invalid file format! Please select a JPG, PNG, or GIF image.",context: context);
      }
    }
  }
  /// CropImage Function:
  void cropImage(File file) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
      /// Upload image to Cloudinary and get the URL
      final imageUrl = await uploadImageToCloudinary(imageFile!);
      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl;
        });
      }
    }
  }

  @override

  Widget build(BuildContext context) {
  /// User Provider:
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    /// Media Query:
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      /// Appbar:
      appBar: AppBar(
        title: Text("Edit Profile",),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.02),
              /// Image:
              Stack(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundImage: uploadedImageUrl != null
                        ? NetworkImage(uploadedImageUrl!)
                        : (imageFile != null ? FileImage(imageFile!) : null),
                    child: imageFile == null && uploadedImageUrl == null
                        ? Icon(Icons.person, size: screenWidth * 0.15, color: Colors.white)
                        : null,
                    backgroundColor: Color(0xFF9CCDF2),
                  ),
                  Positioned(
                    bottom: 0,
                    right: screenWidth * 0.02,
                    child: InkWell(
                      onTap: () {
                        showPhotoOptions(context);
                      },
                      child: CircleAvatar(
                        radius: screenWidth * 0.05,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          radius: screenWidth * 0.04,
                          child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: screenWidth * 0.05),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              /// Username:
              Center(
                child: CustomTextField(controller: usernameController, icon: Icons.person_outline, label: 'Username',onChanged: (value){

                },),
              ),
              SizedBox(height: screenHeight * 0.02),
              /// About:
              CustomTextField(controller: aboutController, icon: Icons.info_outline, label: 'About', maxLines: 3,onChanged: (value){}),
              SizedBox(height: screenHeight * 0.02),
              /// Phone:
              CustomTextField(controller: phoneController, icon: Icons.phone_outlined, label: 'Mobile',onChanged: (value){}),
              SizedBox(height: screenHeight * 0.02),
              /// Country:
              CustomTextField(controller: countryController, icon: Icons.language, label: 'Country',onChanged: (value){}),
              SizedBox(height: screenHeight * 0.02),
              /// Address:
              CustomTextField(controller: addressController, icon: Icons.house_outlined, label: 'Address',onChanged: (value){}),
              SizedBox(height: screenHeight * 0.03),
              /// Button
              SizedBox(
                width: 270,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() { isUpdate = true; });
                    if (userId != null) {
                      await userProvider.updateUserData(
                          userId: userId!,
                          username: usernameController.text,
                          about: aboutController.text,
                          mobile: phoneController.text,
                          country: countryController.text,
                          address: addressController.text,
                          image: uploadedImageUrl,
                          context: context
                      );
                    }
                    setState(() { isUpdate = false; });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CCCF2),
                    minimumSize: Size(double.infinity,50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: isUpdate
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Update", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500,color: Colors.white,fontFamily: "Poppins")),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
