import 'package:benevolent_crm_app/app/modules/campaign_summary/controllers/campaign_summary_controller.dart';
import 'package:benevolent_crm_app/app/modules/campaign_summary/views/widgets/campaign_filter_bottom_sheet.dart';
import 'package:benevolent_crm_app/app/themes/app_color.dart';
import 'package:benevolent_crm_app/app/themes/text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CampaignSummaryView extends GetView<CampaignSummaryController> {
  const CampaignSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Summary'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),

        // -------------------------
        // FILTER BUTTON RIGHT SIDE
        // -------------------------
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              Get.bottomSheet(
                CampaignFilterBottomSheet(),
                isScrollControlled: true,
              );
            },
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }
        }

        if (controller.campaignSummaryData.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.getCampaignSummaryReport();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSelectedFilters(),
                          const Expanded(
                            child: Center(child: Text("No Data Available")),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getCampaignSummaryReport();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSelectedFilters(),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildListSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // -------------------------
  // CHART SECTION
  // -------------------------
  Widget _buildChartSection() {
    final data = controller.campaignSummaryData;
    final total = data.fold<int>(0, (sum, item) => sum + (item.noOfLeads ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Lead Distribution", style: TextStyles.Text18700),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                sections: data.map((item) {
                  final value = item.noOfLeads ?? 0;
                  final color = _parseColor(item.colorCode);
                  final percentage = total > 0 ? (value / total) * 100 : 0.0;

                  return PieChartSectionData(
                    value: value.toDouble(),
                    color: color,
                    title: percentage > 5
                        ? "${percentage.toStringAsFixed(1)}%"
                        : "",
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // LIST SECTION
  // -------------------------
  Widget _buildListSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.campaignSummaryData.length,
      itemBuilder: (context, index) {
        final item = controller.campaignSummaryData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _parseColor(item.colorCode),
              radius: 8,
            ),
            title: Text(
              item.statusName ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              "${item.noOfLeads}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedFilters() {
    return Obx(() {
      final campaigns = controller.selectedCampaigns;
      final sources = controller.selectedSources;
      final fromDate = controller.fromDate.value;
      final toDate = controller.toDate.value;

      if (campaigns.isEmpty && sources.isEmpty && fromDate == null) {
        return const SizedBox.shrink();
      }

      final List<Widget> chips = [];

      // Campaigns
      for (var id in campaigns) {
        final campaign = controller.filtersController.campaignList
            .firstWhereOrNull((c) => c.id == id);
        if (campaign != null) {
          chips.add(
            _buildFilterChip(campaign.name, () {
              controller.selectedCampaigns.remove(id);
              controller.getCampaignSummaryReport();
            }),
          );
        }
      }

      // Sources
      for (var id in sources) {
        final source = controller.filtersController.sourceList.firstWhereOrNull(
          (s) => s.id == id,
        );
        if (source != null) {
          chips.add(
            _buildFilterChip(source.name, () {
              controller.selectedSources.remove(id);
              controller.getCampaignSummaryReport();
            }),
          );
        }
      }

      // Date Range
      if (fromDate != null && toDate != null) {
        final dateStr =
            "${fromDate.toString().split(' ')[0]} - ${toDate.toString().split(' ')[0]}";
        chips.add(
          _buildFilterChip(dateStr, () {
            controller.fromDate.value = null;
            controller.toDate.value = null;
            controller.getCampaignSummaryReport();
          }),
        );
      }

      if (chips.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: c,
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hexColor.replaceAll("#", "0xFF")));
    } catch (_) {
      return Colors.grey;
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 14, 70, 85),
        highlightColor: const Color.fromARGB(255, 14, 70, 85),
        child: Column(
          children: [
            // Filter chips placeholder
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 16),
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Chart placeholder
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            // List items placeholder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
