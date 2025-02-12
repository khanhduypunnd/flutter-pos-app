import 'package:http/http.dart' as http;
import '../core.dart';

class ApiService {
  final String apiUrlOrder = '${ApiConstants.baseUrl}/orders';
  final String apiUrlProduct = '${ApiConstants.baseUrl}/products';
  final String apiUrlCustomer = '${ApiConstants.baseUrl}/customers';
  final String apiUrlStaff = '${ApiConstants.baseUrl}/staffs';
  final String apiUrlStaffRegister = '${ApiConstants.baseUrl}/staffs/register';
  final String apiUrlGiftCode = '${ApiConstants.baseUrl}/giftCodes';
  final String apiUrlGan = '${ApiConstants.baseUrl}/gan';
}