
import 'package:benevolent_crm_app/app/modules/cold_calls/modals/cold_call_model.dart';
import 'package:benevolent_crm_app/app/modules/leads/modals/leads_request.dart';
import 'package:benevolent_crm_app/app/services/api/api_client.dart';

class ColdCallService {
  final ApiClient _apiClient;

  ColdCallService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ColdCallResponse> fetchColdCalls(
    int page, {
    required LeadRequestModel requestModel,
  }) async {
    final response = await _apiClient.get(
      '/coldCalls',
      queryParameters: {'page': page},
      data: requestModel.toJson(),
    );
    print("coldcalls");
    print(response);

    if (response.statusCode == 200) {
      return ColdCallResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load cold calls');
    }
  }

  Future<StatusChangeResponse> changeColdCallStatus({
    required int callId,
    required int status,
  }) async {
    // curl: POST /changeColdCallStatus/{id}  body: {"status":"23"}
    final response = await _apiClient.post(
      '/changeColdCallStatus/$callId',
      data: {'status': status.toString()},
    );
    if (response.statusCode == 200) {
      return StatusChangeResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to change status');
    }
  }

  Future<ConvertToLeadResponse> convertColdCall({
    required int callId,
    int? status,
  }) async {
    final response = await _apiClient.post(
      '/coldCallConvetToLead/$callId',
      data: status == null ? null : {'status': status.toString()},
    );
    if (response.statusCode == 200) {
      return ConvertToLeadResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to convert to lead');
    }
  }
}
