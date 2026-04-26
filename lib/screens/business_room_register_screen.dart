import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/business_service.dart';

class BusinessRoomRegisterScreen extends StatefulWidget {
  final int busMstIdx;
  final int? busDtlIdx;
  final String? initialRoomName;
  final String? initialActiveYn;
  final String? initialStartDate;
  final String? initialEndDate;

  const BusinessRoomRegisterScreen({
    super.key,
    required this.busMstIdx,
    this.busDtlIdx,
    this.initialRoomName,
    this.initialActiveYn,
    this.initialStartDate,
    this.initialEndDate,
  });

  bool get isEditMode => busDtlIdx != null;

  @override
  State<BusinessRoomRegisterScreen> createState() =>
      _BusinessRoomRegisterScreenState();
}

class _BusinessRoomRegisterScreenState
    extends State<BusinessRoomRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _roomNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  bool _activeYn = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roomNameController.text = widget.initialRoomName ?? '';
    _startDateController.text = widget.initialStartDate ?? '';
    _endDateController.text = widget.initialEndDate ?? '';
    _activeYn = (widget.initialActiveYn ?? 'Y') == 'Y';
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final initialDate = _tryParseYmd(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000, 1, 1),
      lastDate: lastDate ?? DateTime(2100, 12, 31),
    );
    if (picked == null) return;
    controller.text = _formatYmd(picked);
    setState(() {});
  }

  static String _formatYmd(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  static DateTime? _tryParseYmd(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final start = _tryParseYmd(_startDateController.text);
    final end = _tryParseYmd(_endDateController.text);
    if (start != null && end != null && end.isBefore(start)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('종료일자는 시작일자 이후여야 합니다')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final businessService = context.read<BusinessService>();
      final roomName = _roomNameController.text.trim();
      final startDate = _startDateController.text.trim().isEmpty
          ? null
          : _startDateController.text.trim();
      final endDate = _endDateController.text.trim().isEmpty
          ? null
          : _endDateController.text.trim();
      final activeYn = _activeYn ? 'Y' : 'N';

      final ok = widget.isEditMode
          ? (await businessService.updateRoom(
                  busDtlIdx: widget.busDtlIdx!,
                  roomName: roomName,
                  activeYn: activeYn,
                  startDate: startDate,
                  endDate: endDate,
                )) !=
                null
          : await businessService.addRoom(
              busMstIdx: widget.busMstIdx,
              roomName: roomName,
              activeYn: activeYn,
              startDate: startDate,
              endDate: endDate,
            );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode ? '룸이 수정되었습니다' : '룸이 추가되었습니다'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode ? '룸 수정에 실패했습니다' : '룸 추가에 실패했습니다'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? '룸 수정' : '룸 추가')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _roomNameController,
                    decoration: const InputDecoration(
                      labelText: '룸 이름',
                      hintText: '예: 세차실 1호',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return '룸 이름을 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('활성화'),
                    subtitle: Text(_activeYn ? 'Y' : 'N'),
                    value: _activeYn,
                    onChanged: _isLoading
                        ? null
                        : (v) => setState(() => _activeYn = v),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: '시작일자',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    readOnly: true,
                    onTap: _isLoading
                        ? null
                        : () {
                            final end = _tryParseYmd(_endDateController.text);
                            _pickDate(
                              controller: _startDateController,
                              lastDate: end,
                            );
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: '종료일자',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    readOnly: true,
                    onTap: _isLoading
                        ? null
                        : () {
                            final start = _tryParseYmd(
                              _startDateController.text,
                            );
                            _pickDate(
                              controller: _endDateController,
                              firstDate: start,
                            );
                          },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveRoom,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.isEditMode ? '수정 저장' : '등록 저장'),
                  ),
                  SizedBox(height: mediaQuery.padding.bottom),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
