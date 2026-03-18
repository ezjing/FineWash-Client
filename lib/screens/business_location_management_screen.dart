import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/business_detail_model.dart';
import '../models/business_master_model.dart';
import '../services/business_service.dart';
import 'business_location_detail_screen.dart';
import 'business_location_register_screen.dart';
import 'business_room_register_screen.dart';

class BusinessLocationManagementScreen extends StatefulWidget {
  const BusinessLocationManagementScreen({super.key});

  @override
  State<BusinessLocationManagementScreen> createState() =>
      _BusinessLocationManagementScreenState();
}

class _BusinessLocationManagementScreenState
    extends State<BusinessLocationManagementScreen> {
  /// 펼쳐진 사업장 마스터 인덱스 (null이면 모두 접힘)
  int? _expandedBusMstIdx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBusinesses());
  }

  void _toggleExpand(int busMstIdx) {
    setState(() {
      _expandedBusMstIdx = _expandedBusMstIdx == busMstIdx ? null : busMstIdx;
    });
  }

  Future<void> _loadBusinesses() async {
    final businessService = context.read<BusinessService>();
    await businessService.searchLogic1();
  }

  Future<void> _openAddRoomScreen(BuildContext context, int busMstIdx) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessRoomRegisterScreen(busMstIdx: busMstIdx),
      ),
    );
    if (saved == true && mounted) {
      _loadBusinesses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('사업장 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BusinessLocationRegisterScreen(),
                ),
              ).then((_) {
                _loadBusinesses();
              });
            },
          ),
        ],
      ),
      body: Consumer<BusinessService>(
        builder: (context, businessService, _) {
          if (businessService.isLoading && businessService.businesses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final locations = businessService.businesses;
          return locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '등록된 사업장이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BusinessLocationRegisterScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('사업장 등록'),
                      ),
                      SizedBox(height: mediaQuery.padding.bottom),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + mediaQuery.padding.bottom,
                  ),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final business = locations[index];
                    final isExpanded = _expandedBusMstIdx == business.busMstIdx;
                    return _LocationCard(
                      business: business,
                      isExpanded: isExpanded,
                      onMasterTap: () => _toggleExpand(business.busMstIdx),
                      onEditTap: (busMstIdx) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusinessLocationRegisterScreen(
                              locationId: busMstIdx,
                            ),
                          ),
                        ).then((_) {
                          _loadBusinesses();
                        });
                      },
                      onAddRoomTap: (busMstIdx) =>
                          _openAddRoomScreen(context, busMstIdx),
                      onDetailTap: (busMstIdx, busDtlIdx) async {
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusinessLocationDetailScreen(
                              locationId: busMstIdx,
                              roomId: busDtlIdx,
                            ),
                          ),
                        );
                        if (saved == true && mounted) {
                          _loadBusinesses();
                        }
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final BusinessMasterModel business;
  final bool isExpanded;
  final VoidCallback onMasterTap;
  final void Function(int busMstIdx)? onEditTap;
  final void Function(int busMstIdx)? onAddRoomTap;
  final void Function(int busMstIdx, int busDtlIdx) onDetailTap;

  const _LocationCard({
    required this.business,
    required this.isExpanded,
    required this.onMasterTap,
    this.onEditTap,
    this.onAddRoomTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final details = business.businessDetails;
    final roomCount = details.length;
    final businessTypeLabel = switch (business.businessType) {
      'OUT' => '출장',
      'PARTNER' => '제휴',
      _ => '-',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MST 카드: 탭 시 펼침/접힘
          InkWell(
            onTap: onMasterTap,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(0),
            ),
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
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          business.address ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        business.phone ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        businessTypeLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.meeting_room,
                        label: '룸',
                        value: '$roomCount개',
                      ),
                      _StatItem(
                        icon: Icons.business,
                        label: '사업자번호',
                        value: business.businessNumber ?? '-',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // DTL 리스트: 펼쳐졌을 때만 표시
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '룸 목록',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              onAddRoomTap?.call(business.busMstIdx),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('룸 추가'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (details.isNotEmpty)
                    ...details.map(
                      (detail) => _DetailTile(
                        detail: detail,
                        onTap: () =>
                            onDetailTap(business.busMstIdx, detail.busDtlIdx),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// DTL(룸) 한 줄 - 탭 시 상세 화면으로 이동
class _DetailTile extends StatelessWidget {
  final BusinessDetailModel detail;
  final VoidCallback onTap;

  const _DetailTile({required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  detail.roomName ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (detail.isActive)
                Text(
                  '활성',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                )
              else
                Text(
                  '비활성',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
