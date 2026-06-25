import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/business_detail_model.dart';
import '../models/wash_option_detail_model.dart';
import '../models/wash_option_master_model.dart';
import '../services/business_service.dart';
import '../services/wash_option_service.dart';
import '../widgets/business_room_tab_content.dart';
import '../widgets/wash_option_tab_content.dart';
import 'business_room_register_screen.dart';
import 'wash_option_detail_register_screen.dart';
import 'wash_option_master_register_screen.dart';

class BusinessLocationDetailScreen extends StatefulWidget {
  /// 사업장 마스터 인덱스 (수정 등에 사용)
  final int locationId;

  const BusinessLocationDetailScreen({super.key, required this.locationId});

  @override
  State<BusinessLocationDetailScreen> createState() =>
      _BusinessLocationDetailScreenState();
}

class _BusinessLocationDetailScreenState
    extends State<BusinessLocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final businessService = context.read<BusinessService>();
    final washService = context.read<WashOptionService>();
    washService.clear();
    businessService.clearCurrentBusiness();
    await businessService.getBusinessDetail(widget.locationId);
    await washService.searchLogic1(widget.locationId, showLoading: false);
  }

  Future<void> _onAppBarAdd() async {
    if (_tabController.index == 0) {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BusinessRoomRegisterScreen(busMstIdx: widget.locationId),
        ),
      );
      if (saved == true && mounted) {
        await _loadDetail();
      }
    } else {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WashOptionMasterRegisterScreen(busMstIdx: widget.locationId),
        ),
      );
      if (saved == true && mounted) {
        await context.read<WashOptionService>().searchLogic1(
          widget.locationId,
          showLoading: false,
        );
      }
    }
  }

  Future<void> _openRoomEdit(BusinessDetailModel room) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessRoomRegisterScreen(
          busMstIdx: widget.locationId,
          busDtlIdx: room.busDtlIdx,
          initialRoomName: room.roomName,
          initialActiveYn: room.activeYn,
          initialStartDate: room.startDate,
          initialEndDate: room.endDate,
        ),
      ),
    );
    if (saved == true && mounted) await _loadDetail();
  }

  Future<void> _confirmDeleteRoom(BusinessDetailModel room) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('룸 삭제'),
        content: Text('"${room.roomName ?? '-'}" 룸을 삭제하시겠습니까?'),
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
    final deleted = await context.read<BusinessService>().deleteRoom(
      busDtlIdx: room.busDtlIdx,
    );
    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('룸이 삭제되었습니다')));
      await _loadDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('룸 삭제에 실패했습니다')));
    }
  }

  Future<void> _openWashMasterEdit(WashOptionMasterModel m) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WashOptionMasterRegisterScreen(
          busMstIdx: widget.locationId,
          initial: m,
        ),
      ),
    );
    if (saved == true && mounted) {
      await context.read<WashOptionService>().searchLogic1(
        widget.locationId,
        showLoading: false,
      );
    }
  }

  Future<void> _confirmDeleteWashMaster(WashOptionMasterModel m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('옵션(MST) 삭제'),
        content: Text(
          '"${m.optionName ?? '-'}" 및 하위 옵션(DTL)이 모두 삭제됩니다. 계속할까요?',
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
    final deleted = await context.read<WashOptionService>().deleteMaster(
      woptMstIdx: m.woptMstIdx,
      busMstIdx: widget.locationId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(deleted ? '삭제되었습니다' : '삭제에 실패했습니다')));
  }

  Future<void> _openWashDetailAdd(WashOptionMasterModel m) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WashOptionDetailRegisterScreen(
          busMstIdx: widget.locationId,
          woptMstIdx: m.woptMstIdx,
        ),
      ),
    );
    if (saved == true && mounted) {
      await context.read<WashOptionService>().searchLogic1(
        widget.locationId,
        showLoading: false,
      );
    }
  }

  Future<void> _openWashDetailEdit(WashOptionDetailModel d) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WashOptionDetailRegisterScreen(
          busMstIdx: widget.locationId,
          woptMstIdx: d.woptMstIdx,
          initial: d,
        ),
      ),
    );
    if (saved == true && mounted) {
      await context.read<WashOptionService>().searchLogic1(
        widget.locationId,
        showLoading: false,
      );
    }
  }

  Future<void> _confirmDeleteWashDetail(WashOptionDetailModel d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('옵션(DTL) 삭제'),
        content: Text('"${d.optionName ?? '-'}" 항목을 삭제하시겠습니까?'),
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
    final deleted = await context.read<WashOptionService>().deleteDetail(
      woptDtlIdx: d.woptDtlIdx,
      busMstIdx: widget.locationId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(deleted ? '삭제되었습니다' : '삭제에 실패했습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BusinessService>(
          builder: (context, businessService, _) {
            if (businessService.currentBusiness != null) {
              return Text(
                businessService.currentBusiness!.companyName ?? '사업장',
              );
            }
            return const Text('로딩 중...');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: _tabController.index == 0 ? '룸 추가' : '옵션 추가',
            onPressed: _onAppBarAdd,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '룸 관리'),
            Tab(text: '옵션 관리'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BusinessRoomTabContent(
            onEditTap: _openRoomEdit,
            onDeleteTap: _confirmDeleteRoom,
          ),
          WashOptionTabContent(
            onEditMaster: _openWashMasterEdit,
            onDeleteMaster: _confirmDeleteWashMaster,
            onAddDetail: _openWashDetailAdd,
            onEditDetail: _openWashDetailEdit,
            onDeleteDetail: _confirmDeleteWashDetail,
          ),
        ],
      ),
    );
  }
}
