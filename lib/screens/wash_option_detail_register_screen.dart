import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/wash_option_detail_model.dart';
import '../services/wash_option_service.dart';

/// WashOptionDetail 저장 — 상위 MST(`woptMstIdx`)에 종속
class WashOptionDetailRegisterScreen extends StatefulWidget {
  final int busMstIdx;
  final int woptMstIdx;
  final WashOptionDetailModel? initial;

  const WashOptionDetailRegisterScreen({
    super.key,
    required this.busMstIdx,
    required this.woptMstIdx,
    this.initial,
  });

  bool get isEditMode => initial != null;

  @override
  State<WashOptionDetailRegisterScreen> createState() =>
      _WashOptionDetailRegisterScreenState();
}

class _WashOptionDetailRegisterScreenState
    extends State<WashOptionDetailRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _optionNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _seqController = TextEditingController();
  final _value1Controller = TextEditingController();
  final _value2Controller = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final o = widget.initial;
    if (o != null) {
      _optionNameController.text = o.optionName ?? '';
      _vehicleTypeController.text = o.vehicleType ?? '';
      _seqController.text = '${o.seq}';
      if (o.value1 != null) _value1Controller.text = '${o.value1}';
      if (o.value2 != null) _value2Controller.text = '${o.value2}';
    } else {
      _seqController.text = '1';
    }
  }

  @override
  void dispose() {
    _optionNameController.dispose();
    _vehicleTypeController.dispose();
    _seqController.dispose();
    _value1Controller.dispose();
    _value2Controller.dispose();
    super.dispose();
  }

  int? _parseOptInt(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t.replaceAll(',', ''));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final seq = int.tryParse(_seqController.text.trim());
    if (seq == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정렬순서는 숫자로 입력하세요')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final svc = context.read<WashOptionService>();
      final v1 = _parseOptInt(_value1Controller.text);
      final v2 = _parseOptInt(_value2Controller.text);
      final ok = widget.isEditMode
          ? await svc.updateDetail(
                woptDtlIdx: widget.initial!.woptDtlIdx,
                busMstIdx: widget.busMstIdx,
                optionName: _optionNameController.text,
                vehicleType: _vehicleTypeController.text,
                seq: seq,
                value1: v1,
                value2: v2,
              )
          : await svc.saveDetail(
                woptMstIdx: widget.woptMstIdx,
                busMstIdx: widget.busMstIdx,
                optionName: _optionNameController.text,
                vehicleType: _vehicleTypeController.text,
                seq: seq,
                value1: v1,
                value2: v2,
              );
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '옵션(DTL) 수정' : '옵션(DTL) 등록'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _optionNameController,
              decoration: const InputDecoration(
                labelText: '옵션명',
                hintText: '예: 살균',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '옵션명을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vehicleTypeController,
              decoration: const InputDecoration(
                labelText: '차종',
                hintText: '예: 중형',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '차종을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _seqController,
              decoration: const InputDecoration(
                labelText: '정렬순서 (seq)',
                hintText: '예: 2',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '정렬순서를 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _value1Controller,
              decoration: const InputDecoration(
                labelText: '소요시간 (value1, 분)',
                hintText: '예: 80',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _value2Controller,
              decoration: const InputDecoration(
                labelText: '가격 (value2, 원)',
                hintText: '예: 25000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditMode ? '수정 저장' : '등록'),
            ),
          ],
        ),
      ),
    );
  }
}
