import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/staff.dart';
import '../shared/core/services/api.dart';

class LoginModel extends ChangeNotifier{
  final ApiService uriAPIService = ApiService();

  List<Staff> listStaff = [];

  bool isLoading = false;

  String? token;
  String? errorMessage;

  Future<Map<String, dynamic>?> login(BuildContext context, String email, String password) async {
    isLoading = true;
    notifyListeners();

    final String apiUrl = uriAPIService.apiUrlStaff;

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      print(data);

      if (response.statusCode == 200) {
        token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token!);

        isLoading = false;
        notifyListeners();

        print(data['customer']);
        return data['customer'];
      } else {
        errorMessage = data['error'] ?? "Đăng nhập thất bại";
        isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      showCustomToast(context, 'Đăng nhập thất bại');
      errorMessage = "Lỗi kết nối đến server";
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    context.go('/login');

    notifyListeners();
  }



  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

}