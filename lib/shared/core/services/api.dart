import 'package:http/http.dart' as http;
import '../core.dart';

class ClientApiService {
  final String _baseUrl = ClientApiConstants.baseUrl;

  Future<void> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}