import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/business_service.dart';
import '../widgets/entity_summary_cards.dart';
import '../widgets/empty_state_message.dart';
import 'business_location_detail_screen.dart';
import 'business_location_register_screen.dart';

class BusinessLocationManagementScreen extends StatefulWidget {
  const BusinessLocationManagementScreen({super.key});

  @override
  State<BusinessLocationManagementScreen> createState() =>
      _BusinessLocationManagementScreenState();
}

class _BusinessLocationManagementScreenState
    extends State<BusinessLocationManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBusinesses());
  }

  Future<void> _loadBusinesses() async {
    final businessService = context.read<BusinessService>();
    await businessService.searchLogic1();
  }

  Future<void> _confirmDeleteBusiness({
    required String companyName,
    required int busMstIdx,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('사업장 삭제'),
        content: Text(
          '"$companyName" 사업장과 룸·세차 옵션 정보가 모두 삭제됩니다. 계속할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final deleted = await context.read<BusinessService>().deleteBusiness(
            busMstIdx: busMstIdx,
          );
      if (!mounted) return;
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사업장이 삭제되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사업장 삭제에 실패했습니다')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
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
              ? EmptyStateMessage(
                  icon: Icons.business_outlined,
                  title: '등록된 사업장이 없습니다',
                  subtitle: '앱바의 + 버튼으로 사업장을 추가하세요.',
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
                    return BusinessMasterSummaryCard(
                      business: business,
                      onCardTap: () async {
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusinessLocationDetailScreen(
                              locationId: business.busMstIdx,
                            ),
                          ),
                        );
                        if (saved == true && mounted) {
                          _loadBusinesses();
                        }
                      },
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
                      onDeleteTap: (busMstIdx) => _confirmDeleteBusiness(
                        companyName: business.companyName ?? '사업장',
                        busMstIdx: busMstIdx,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
