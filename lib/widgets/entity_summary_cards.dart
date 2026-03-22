import 'package:flutter/material.dart';
import '../models/business_detail_model.dart';
import '../models/business_master_model.dart';
import '../models/wash_option_detail_model.dart';
import '../models/wash_option_master_model.dart';
import '../utils/app_colors.dart';
import 'summary_card_frame.dart';
import 'summary_info_row.dart';
import 'summary_stat_item.dart';

String _formatThousands(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

/// 사업장 마스터 카드
class BusinessMasterSummaryCard extends StatelessWidget {
  final BusinessMasterModel business;
  final VoidCallback onCardTap;
  final void Function(int busMstIdx)? onEditTap;
  final void Function(int busMstIdx)? onDeleteTap;

  const BusinessMasterSummaryCard({
    super.key,
    required this.business,
    required this.onCardTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final roomCount = business.businessDetails.length;
    final depositLine = business.depositYn == 'Y'
        ? '예약금 ${_formatThousands(business.depositAmount ?? 0)}원'
        : '예약금 미사용';
    final businessTypeLabel = switch (business.businessType) {
      'OUT' => '출장',
      'PARTNER' => '제휴',
      _ => '-',
    };
    return SummaryCardFrame(
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      business.companyName ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (onEditTap != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => onEditTap!(business.busMstIdx),
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '사업장 정보 수정',
                    ),
                  if (onDeleteTap != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onDeleteTap!(business.busMstIdx),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '사업장 삭제',
                    ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SummaryIconInfoRow(
                icon: Icons.location_on,
                text: business.address ?? '-',
              ),
              const SizedBox(height: 8),
              SummaryIconInfoRow(
                icon: Icons.phone,
                text: business.phone ?? '-',
                expandText: false,
              ),
              const SizedBox(height: 8),
              SummaryIconInfoRow(
                icon: Icons.category,
                text: businessTypeLabel,
                expandText: false,
              ),
              const SizedBox(height: 8),
              SummaryIconInfoRow(
                icon: Icons.savings_outlined,
                text: depositLine,
                expandText: false,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SummaryStatItem(
                      icon: Icons.meeting_room,
                      label: '룸',
                      value: '$roomCount개',
                    ),
                  ),
                  Expanded(
                    child: SummaryStatItem(
                      icon: Icons.business,
                      label: '사업자번호',
                      value: business.businessNumber ?? '-',
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

/// 룸(DTL) 카드
/// [onCardTap]이 null이면 카드 탭·우측 화살표 없음(목록 전용).
class BusinessRoomSummaryCard extends StatelessWidget {
  final BusinessDetailModel room;
  final VoidCallback? onCardTap;
  final void Function(int busDtlIdx) onEditTap;
  final void Function(int busDtlIdx)? onDeleteTap;

  const BusinessRoomSummaryCard({
    super.key,
    required this.room,
    this.onCardTap,
    required this.onEditTap,
    this.onDeleteTap,
  });

  String get _periodLine {
    final parts = [room.startDate, room.endDate].whereType<String>().toList();
    if (parts.isEmpty) return '미설정';
    return parts.join(' ~ ');
  }

  String get _priceStatPlaceholder => room.isActive ? '운영중' : '중지';

  @override
  Widget build(BuildContext context) {
    return SummaryCardFrame(
      child: _wrapRoomCardTap(
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.roomName ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEditTap(room.busDtlIdx),
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(8),
                    ),
                    tooltip: '룸 수정',
                  ),
                  if (onDeleteTap != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onDeleteTap!(room.busDtlIdx),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '룸 삭제',
                    ),
                  if (onCardTap != null)
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SummaryIconInfoRow(
                icon: Icons.toggle_on,
                text: room.isActive ? '활성' : '비활성',
              ),
              const SizedBox(height: 8),
              SummaryIconInfoRow(
                icon: Icons.calendar_today,
                text: _periodLine,
              ),
              const SizedBox(height: 8),
              SummaryIconInfoRow(
                icon: Icons.tag,
                text: '룸 ID · ${room.busDtlIdx}',
                expandText: false,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SummaryStatItem(
                    icon: Icons.meeting_room,
                    label: '룸',
                    value: room.roomName ?? '-',
                  ),
                  SummaryStatItem(
                    icon: Icons.flag,
                    label: '상태',
                    value: _priceStatPlaceholder,
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

Widget _wrapRoomCardTap({
  required VoidCallback? onTap,
  required Widget child,
}) {
  if (onTap == null) return child;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: child,
  );
}

String _formatWon(int? v) {
  if (v == null) return '-';
  if (v == 0) return '0원';
  return '${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
}

/// WashOptionMaster + 하위 DTL 목록
class WashOptionMasterCard extends StatefulWidget {
  final WashOptionMasterModel master;
  final VoidCallback onEditMaster;
  final VoidCallback onDeleteMaster;
  final VoidCallback onAddDetail;
  final void Function(WashOptionDetailModel d) onEditDetail;
  final void Function(WashOptionDetailModel d) onDeleteDetail;

  const WashOptionMasterCard({
    super.key,
    required this.master,
    required this.onEditMaster,
    required this.onDeleteMaster,
    required this.onAddDetail,
    required this.onEditDetail,
    required this.onDeleteDetail,
  });

  @override
  State<WashOptionMasterCard> createState() => _WashOptionMasterCardState();
}

class _WashOptionMasterCardState extends State<WashOptionMasterCard> {
  bool _detailExpanded = true;

  void _toggleDetailSection() {
    setState(() => _detailExpanded = !_detailExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final master = widget.master;
    return SummaryCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        master.optionName ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: widget.onEditMaster,
                      tooltip: 'MST 수정',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onDeleteMaster,
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      tooltip: 'MST 삭제',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SummaryIconInfoRow(
                  icon: Icons.directions_car,
                  text: master.vehicleType ?? '-',
                ),
                const SizedBox(height: 8),
                SummaryIconInfoRow(
                  icon: Icons.sort,
                  text: '순서 ${master.seq}',
                  expandText: false,
                ),
                const SizedBox(height: 8),
                SummaryIconInfoRow(
                  icon: Icons.timer_outlined,
                  text: '${master.value1 ?? '-'}분',
                  expandText: false,
                ),
                const SizedBox(height: 8),
                SummaryIconInfoRow(
                  icon: Icons.payments,
                  text: _formatWon(master.value2),
                  expandText: false,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryStatItem(
                      icon: Icons.timer,
                      label: '소요(분)',
                      value: '${master.value1 ?? '-'}',
                    ),
                    SummaryStatItem(
                      icon: Icons.sell,
                      label: '가격',
                      value: _formatWon(master.value2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _detailExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: _toggleDetailSection,
                  tooltip: _detailExpanded ? '세부 옵션 접기' : '세부 옵션 펼치기',
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _toggleDetailSection,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '세부 옵션 (${master.details.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: widget.onAddDetail,
                  tooltip: '세부 옵션 추가',
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _detailExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (master.details.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              '등록된 세부 옵션이 없습니다. 위 + 버튼으로 세부 옵션을 추가하세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...master.details.map(
                          (d) => _WashOptionDetailTile(
                            detail: d,
                            onEdit: () => widget.onEditDetail(d),
                            onDelete: () => widget.onDeleteDetail(d),
                          ),
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _WashOptionDetailTile extends StatelessWidget {
  final WashOptionDetailModel detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WashOptionDetailTile({
    required this.detail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.optionName ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.vehicleType ?? '-'} · 순서 ${detail.seq} · ${detail.value1 ?? '-'}분 · ${_formatWon(detail.value2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                tooltip: 'DTL 수정',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                tooltip: 'DTL 삭제',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
