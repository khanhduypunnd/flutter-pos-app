import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../../shared/core/theme/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void showCreateCustomerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const CustomerDialog(),
  );
}

class CustomerDialog extends StatefulWidget {
  const CustomerDialog({super.key});

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String password = '000000';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            hintColor: Colors.blueAccent,
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      String formattedDate = selectedDate.toIso8601String().split('T')[0];
      _dobController.text = formattedDate;
    }
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

  String generateGanId(int currentId) {
    final String formattedId = currentId.toString().padLeft(6, '0');
    return 'C$formattedId';
  }

  Future<void> saveCurrentId(int currentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentId', currentId);
  }

  Future<int> loadCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentId') ?? 1;
  }

  void _addCustomer() async {

    int currentId = await loadCurrentId();

    String newCustomerId = generateGanId(currentId);

    String fullName = '${_lastNameController.text} ${_firstNameController.text}';

    try {
      final customer = {
        'cid': newCustomerId,
        'name': fullName,
        'dateOfBirth': _dobController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'password': password
      };

      print('Dữ liệu JSON: ${json.encode(customer)}');


      final url = Uri.parse('https://dacntt1-api-server-5uchxlkka-haonguyen9191s-projects.vercel.app/api/customers/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(customer),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        showCustomToast(context, 'Tạo khách hàng thành công!');
        _clearForm();
      } else {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message']
            : 'Lỗi không xác định';
        showCustomToast(context, 'Lỗi: $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi gửi dữ liệu: $e');
      }
      showCustomToast(context, 'Có lỗi xảy ra: $e');
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tạo khách hàng mới",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.titleColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              hintText: "Họ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: "Tên",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên';
                            }
                            return null;
                          },

                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              hintText: "Ngày sinh",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn ngày sinh';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: "Số điện thoại",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: "Địa chỉ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(8)
                      ),
                      foregroundColor: Colors.red.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Hủy",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String fullName = '${_firstNameController.text} ${_lastNameController.text}';
                        final customer = {
                          'name': fullName,
                          'dateOfBirth': _dobController.text,
                          'address': _addressController.text,
                          'email': _emailController.text,
                          'phoneNumber': _phoneController.text,
                          'password': password
                        };

                        print(customer);

                        _addCustomer();
                      } else {
                        showCustomToast(context,"Vui lòng nhập đầy đủ thông tin");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text("Lưu", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
