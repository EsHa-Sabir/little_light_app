import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:http/http.dart' as http;
/// Provide Payment Service:
class PaymentService {
  /// Create Intent:
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency,BuildContext context) async {
    try {
      if (int.parse(amount) < 200) {
        showToast(message: "Amount must be at least 200 PKR",context: context);
        return null;
      }
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount) * 100)).toString(),
        'currency': currency,
      'payment_method_types[]': 'card',
      };

      Map<String, String> headers = {
        'Authorization': 'Bearer ${dotenv.env["STRIPE_AUTHORIZATION"]}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        showToast(message: "Payment Intent Failed: ${response.body}",context: context);
        print("Error:  ${response.body}");

        return null;
      }
    } catch (e) {
      showToast(message: "Error: $e",context: context);
      print("Error:$e");
      return null;
    }
  }
}
