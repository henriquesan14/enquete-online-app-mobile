import 'dart:convert';

import 'package:enquete_online_app_mobile/models/enquete.dart';
import 'package:enquete_online_app_mobile/models/paginated_result.dart';
import 'package:enquete_online_app_mobile/services/api_client.dart';

class EnqueteService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedResult<EnqueteViewModel>> getEnquetes(int pageNumber, int pageSize) async {
    final response = await _apiClient.get('enquetes', queryParams: {'pageNumber': pageNumber, 'pageSize': pageSize});

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginatedResult<EnqueteViewModel>.fromJson(
        json,
        (item) => EnqueteViewModel.fromJson(item),
      );
    } else {
      throw Exception('Erro ao carregar enquetes: ${response.statusCode}');
    }
  }

  Future<EnqueteViewModel> getEnqueteById(String id) async {
    final response = await _apiClient.get('enquetes/$id');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EnqueteViewModel.fromJson(
        json
      );
    } else {
      throw Exception('Erro ao carregar enquete: ${response.statusCode}');
    }
  }

  Future<String> addVoto(String enqueteId, String opcaoEnqueteId) async {
    final response = await _apiClient.post('votos', body: {'enqueteId': enqueteId, 'opcaoEnqueteId': opcaoEnqueteId});

    if (response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Erro ao carregar enquetes: ${response.statusCode}');
    }
  }


}