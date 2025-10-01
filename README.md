# Little Light - A Multi-Role Donation Platform 💙

Welcome to the official repository for **Little Light**, a comprehensive, role-based donation platform designed to connect those in need with those who can help. Built with Flutter, this application provides a seamless and secure ecosystem for donors, requesters, and delivery personnel, all managed through a powerful admin panel. This project was developed as a Final Year Project.

<p align="center">
  <img src="assets/readme_images/8.png" width="300" alt="Home Screen">
</p>

---

## ✨ Core Idea & Mission

The mission of **Little Light** is to bring "Light in the darkness" by creating a transparent, efficient, and user-friendly platform for charitable giving. The app addresses the challenge of connecting donors with verified requesters and managing the logistics of donation pickup and delivery, ensuring that help reaches those who need it most.

---

## 🔑 Key Features

- **Four Unique User Roles:** A complete system with separate interfaces and functionalities for Donors, Requesters, Delivery Personnel, and Admins.
- **Multiple Donation Categories:** Supports donations of Food, Clothes, Books, and Financial aid for categories like Education, Weddings, and Medical expenses.
- **Real-time Communication:** In-app chat with voice messaging capabilities to facilitate smooth communication between users.
- **Live GPS Tracking:** Donors and requesters can track the delivery personnel in real-time on a map.
- **Secure Payments:** Integrated with Stripe, Easypaisa, and JazzCash for secure financial donations.
- **Real-time Notifications:** Push notifications powered by OneSignal keep users updated on their request and donation statuses.
- **Comprehensive Admin Panel:** A full-featured web panel for complete control over users, donations, requests, and system settings.
- **Reporting & Analytics:** Users can view detailed reports of their donation history and impact.

---

## 🛠️ Technology Stack

- **Framework:** **Flutter** - For a beautiful, high-performance, cross-platform experience on Android & iOS.
- **Backend:** **Firebase** (Firestore, Authentication, Storage) - For a scalable, real-time backend.
- **State Management:** **Provider**
- **Payment Gateways:** **Stripe**, **Easypaisa**, **JazzCash**
- **Mapping & Geolocation:** **Google Maps API**
- **Push Notifications:** **OneSignal**
- **UI/UX Design:** **Figma**

---

## 📸 Application Walkthrough (Screenshots)

A visual tour of the "Little Light" mobile application, showcasing the journey of each user role.

### 1. Onboarding & Authentication
A simple and secure entry point for all users.
<p align="center">
  <img src="assets/readme_images/1.png" width="200" alt="Splash Screen">
  <img src="assets/readme_images/7.png" width="200" alt="Onboarding 1">
  <img src="assets/readme_images/23.png" width="200" alt="Onboarding 2">
  <img src="assets/readme_images/2.png" width="200" alt="Login Screen">
  <img src="assets/readme_images/3.png" width="200" alt="Sign Up Screen">
</p>

---

### 2. The Donor's Journey 💖
Donors can easily contribute items or funds, view requests, and track their impact.

#### Donor Dashboard & Donation Process
<p align="center">
  <img src="assets/readme_images/8.png" width="200" alt="Donor Home">
  <img src="assets/readme_images/11.png" width="200" alt="Donation Categories">
  <img src="assets/readme_images/14.png" width="200" alt="Donation Forms">
  <img src="assets/readme_images/15.png" width="200" alt="Food Donation Form">
</p>
<p align="center">
  <img src="assets/readme_images/16.png" width="200" alt="Financial Support Categories">
  <img src="assets/readme_images/17.png" width="200" alt="Financial Donation Form">
  <img src="assets/readme_images/33.png" width="200" alt="Stripe Payment">
</p>

#### Viewing & Responding to Requests
Donors can see a list of active requests, view details on a map, and initiate a chat.
<p align="center">
  <img src="assets/readme_images/18.png" width="200" alt="View Requesters List">
  <img src="assets/readme_images/12.png" width="200" alt="Food Requesters">
  <img src="assets/readme_images/13.png" width="200" alt="Requester Details & Map">
</p>

#### Pickup & Donation History
Donors can schedule a pickup for their items and view a detailed history of their contributions.
<p align="center">
  <img src="assets/readme_images/19.png" width="200" alt="Create Pickup Request">
  <img src="assets/readme_images/21.png" width="200" alt="Donation History">
  <img src="assets/readme_images/38.jpg" width="200" alt="Donation Report">
</p>

---

### 3. The Requester's Journey 🙏
Requesters can create and track requests for various needs.

<p align="center">
  <img src="assets/readme_images/35.jpg" width="200" alt="Requester Dashboard">
  <img src="assets/readme_images/24.png" width="200" alt="Requester Profile">
  <img src="assets/readme_images/25.png" width="200" alt="Create Request Form">
</p>
<p align="center">
  <img src="assets/readme_images/26.png" width="200" alt="Request Submitted Popup">
  <img src="assets/readme_images/27.png" width="200" alt="Track Request Status">
</p>

---

### 4. The Delivery Personnel's Journey 🛵
Delivery personnel manage pickups and drop-offs with live GPS tracking.

<p align="center">
  <img src="assets/readme_images/29.png" width="200" alt="Delivery Onboarding">
  <img src="assets/readme_images/30.png" width="200" alt="Delivery Dashboard">
  <img src="assets/readme_images/28.png" width="200" alt="Live Delivery Tracking">
  <img src="assets/readme_images/36.jpg" width="200" alt="Live Delivery Tracking 2">
</p>

---

### 5. Common Features for All Users
Features like chat, notifications, and profile editing are available to all roles.

<p align="center">
  <img src="assets/readme_images/20.png" width="200" alt="Inbox Screen">
  <img src="assets/readme_images/41.jpg" width="200" alt="Inbox List">
  <img src="assets/readme_images/31.png" width="200" alt="Chat Screen 1">
</p>
<p align="center">
  <img src="assets/readme_images/32.png" width="200" alt="Chat Screen 2">
  <img src="assets/readme_images/40.jpg" width="200" alt="Chat Screen 3">
  <img src="assets/readme_images/22.png" width="200" alt="Notifications">
</p>
<p align="center">
  <img src="assets/readme_images/9.png" width="200" alt="User Profile">
  <img src="assets/readme_images/10.png" width="200" alt="Edit User Profile Form">
  <img src="assets/readme_images/42.jpg" width="200" alt="Edit User Profile Form 2">
  <img src="assets/readme_images/43.jpg" width="200" alt="User Profile Settings">
</p>

---

### 6. Admin Panel
A separate Flutter Web application provides full administrative control.

<p align="center">
  <img src="assets/readme_images/44.png" width="200" alt="Admin Dashboard">
  <img src="assets/readme_images/45.png" width="200" alt="Admin Manage Users">
  <img src="assets/readme_images/34.png" width="200" alt="Admin Reports">
</p>

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

1.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Environment:**
    - Add your Firebase configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
    - Create a file `lib/api_key.dart` for sensitive keys (Google Maps, Stripe, etc.) and add it to `.gitignore`.

4.  **Run the App:**
    ```bash
    flutter run
    ```