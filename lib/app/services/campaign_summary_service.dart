import 'package:benevolent_crm_app/app/modules/campaign_summary/models/campaign_summary_model.dart';
import 'package:benevolent_crm_app/app/services/api/api_client.dart';
import 'package:benevolent_crm_app/app/services/api/api_end_points.dart';
import 'package:benevolent_crm_app/app/utils/error_handler.dart';
import 'package:dio/dio.dart';


class CampaignSummaryService {
  final ApiClient _apiClient;

  CampaignSummaryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<CampaignSummaryResponse> getCampaignSummaryReport({
    String? campaignIds,
    String? sourceIds,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final data = {
        "campaign_ids": campaignIds ?? "",
        "source_ids": sourceIds ?? "",
        "from_date": fromDate ?? "",
        "to_date": toDate ?? "",
      };
      
      final response = await _apiClient.get(
        ApiEndPoints.CAMPAIGN_SUMMARY_REPORT_URL,
        data: data,
      );
      return CampaignSummaryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e) {
      rethrow;
    }
  }
}