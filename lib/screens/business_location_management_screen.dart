import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
  // TODO: 실제 API 연동 시 서비스에서 가져오기
  final List<Map<String, dynamic>> _locations = [
    {
      'id': 1,
      'name': '강남 세차장',
      'address': '서울시 강남구 테헤란로 123',
      'phone': '02-1234-5678',
      'reservationCount': 45,
      'revenue': 1250000,
    },
    {
      'id': 2,
      'name': '홍대 세차장',
      'address': '서울시 마포구 홍익로 456',
      'phone': '02-2345-6789',
      'reservationCount': 32,
      'revenue': 890000,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                // TODO: 목록 새로고침
              });
            },
          ),
        ],
      ),
      body: _locations.isEmpty
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
                          builder: (_) => const BusinessLocationRegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('사업장 등록'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return _LocationCard(
                  location: location,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessLocationDetailScreen(
                          locationId: location['id'] as int,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final VoidCallback onTap;

  const _LocationCard({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
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
                      location['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location['address'] as String,
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
                  Icon(Icons.phone,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    location['phone'] as String,
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
                    icon: Icons.calendar_today,
                    label: '예약',
                    value: '${location['reservationCount']}건',
                  ),
                  _StatItem(
                    icon: Icons.payments,
                    label: '매출',
                    value:
                        '${(location['revenue'] as int).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
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
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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
