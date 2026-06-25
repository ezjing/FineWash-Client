import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/wash_option_detail_model.dart';
import '../models/wash_option_master_model.dart';
import '../services/wash_option_service.dart';
import '../widgets/empty_state_message.dart';
import '../widgets/entity_summary_cards.dart';

/// 사업장 상세 — 세차 옵션 관리 탭
class WashOptionTabContent extends StatelessWidget {
  final void Function(WashOptionMasterModel master) onEditMaster;
  final void Function(WashOptionMasterModel master) onDeleteMaster;
  final void Function(WashOptionMasterModel master) onAddDetail;
  final void Function(WashOptionDetailModel detail) onEditDetail;
  final void Function(WashOptionDetailModel detail) onDeleteDetail;

  const WashOptionTabContent({
    super.key,
    required this.onEditMaster,
    required this.onDeleteMaster,
    required this.onAddDetail,
    required this.onEditDetail,
    required this.onDeleteDetail,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Consumer<WashOptionService>(
      builder: (context, washService, _) {
        if (washService.isLoading && washService.masters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final masters = washService.masters;
        if (masters.isEmpty) {
          return EmptyStateMessage(
            icon: Icons.tune_outlined,
            title: '등록된 세차 옵션(MST)이 없습니다',
            subtitle: '앱바 + 로 MST를 추가한 뒤, 카드에서 DTL을 추가할 수 있습니다.',
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          itemCount: masters.length,
          itemBuilder: (context, index) {
            final m = masters[index];
            return WashOptionMasterCard(
              master: m,
              onEditMaster: () => onEditMaster(m),
              onDeleteMaster: () => onDeleteMaster(m),
              onAddDetail: () => onAddDetail(m),
              onEditDetail: onEditDetail,
              onDeleteDetail: onDeleteDetail,
            );
          },
        );
      },
    );
  }
}
