import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/business_detail_model.dart';
import '../services/business_service.dart';
import '../widgets/empty_state_message.dart';
import '../widgets/entity_summary_cards.dart';

/// 사업장 상세 — 룸 관리 탭
class BusinessRoomTabContent extends StatelessWidget {
  final void Function(BusinessDetailModel room) onEditTap;
  final void Function(BusinessDetailModel room) onDeleteTap;

  const BusinessRoomTabContent({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Consumer<BusinessService>(
      builder: (context, businessService, _) {
        if (businessService.isLoading &&
            businessService.currentBusiness == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final business = businessService.currentBusiness;
        if (business == null) {
          return const Center(child: Text('사업장 정보를 찾을 수 없습니다.'));
        }

        final details = business.businessDetails;
        if (details.isEmpty) {
          return EmptyStateMessage(
            icon: Icons.meeting_room_outlined,
            title: '등록된 룸이 없습니다',
            subtitle: '앱바의 + 버튼으로 룸을 추가하세요.',
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          itemCount: details.length,
          itemBuilder: (context, index) {
            final detail = details[index];
            return BusinessRoomSummaryCard(
              room: detail,
              onEditTap: (_) => onEditTap(detail),
              onDeleteTap: (_) => onDeleteTap(detail),
            );
          },
        );
      },
    );
  }
}
