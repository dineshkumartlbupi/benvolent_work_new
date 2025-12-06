import 'package:benevolent_crm_app/app/themes/app_color.dart';
import 'package:benevolent_crm_app/app/themes/text_styles.dart';
import 'package:benevolent_crm_app/app/utils/helpers.dart';
import 'package:benevolent_crm_app/app/utils/hyper_links/hyper_links.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/call_constants.dart';
import '../modal/converted_call_model.dart';

class ConvertedCallCard extends StatelessWidget {
  final ConvertedCall call;
  final bool showAccept;

  const ConvertedCallCard({
    super.key,
    required this.call,
    this.showAccept = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        call.name,
                        style: TextStyles.Text18700.copyWith(),
                      ),
                    ),
                  ],
                ),
// ytest
                const SizedBox(height: 6),

                // Email
                Text(
                  call.email,
                  style: TextStyles.Text13500,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Agent + Campaign
                _infoRow(Icons.person, call.agent, Colors.pink),
                const SizedBox(height: 6),
                _infoRow(Icons.campaign_outlined, call.campaign, Colors.green),

                const SizedBox(height: 10),

                // Divider + Status
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(call.status),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionIcon(
                      bg: const Color.fromARGB(255, 42, 100, 64),
                      icon: FontAwesomeIcons.whatsapp,
                      onTap: () => HyperLinksNew.openWhatsApp(
                        call.phone,
                        'Hi ${call.name},',
                      ),
                    ),
                    _actionIcon(
                      bg: Colors.white,
                      border: Border.all(color: Colors.black26),
                      icon: Icons.email_outlined,
                      iconColor: Colors.red.shade700,
                      onTap: () =>
                          HyperLinksNew.openEmail(call.email, call.name),
                    ),
                    _actionIcon(
                      bg: Colors.white,
                      border: Border.all(color: Colors.black26),
                      icon: Icons.copy_rounded,
                      iconColor: Colors.grey.shade800,
                      onTap: () => Helpers.copyClipboard(
                        'Name: ${call.name}\nPhone: ${call.phone}\nEmail: ${call.email}\nCampaign: ${call.campaign}',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              right: 0,
              child: InkWell(
                onTap: () => HyperLinksNew.openDialer(call.phone),
                borderRadius: BorderRadius.circular(50),
                child: const Icon(
                  Icons.call,
                  size: 28,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!showAccept) return card;

    // Add Accept Ribbon
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          left: 0,
          right: 0,
          bottom: -14,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Accept',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Helpers ----
  Widget _infoRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final lowerStatus = status.toLowerCase();
    final color =
        CallConstants.statusColors[lowerStatus] ??
        CallConstants.defaultStatusColor;
    final icon =
        CallConstants.statusIcons[lowerStatus] ??
        CallConstants.defaultStatusIcon;

    if (status.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _actionIcon({
    required Color bg,
    Border? border,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
      ),
    );
  }
}
