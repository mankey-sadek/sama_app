import 'package:flutter/material.dart';

import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

enum AccountType { individual, business }

class AccountTypeScreen extends StatefulWidget {
  final SignalingService signalingService;
  final WebRTCService webrtcService;

  const AccountTypeScreen({
    super.key,
    required this.signalingService,
    required this.webrtcService,
  });

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  AccountType _selected = AccountType.individual;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'قبل ما نبدأ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'هتستخدم سَما كإيه؟ تقدر تغيّر ده لاحقًا من الإعدادات.',
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              _AccountChoiceCard(
                title: 'حساب فردي',
                description: 'لاستخدامي الشخصي — مكالمات ورسائل ومشاركة موقع',
                icon: Icons.person_outline_rounded,
                selected: _selected == AccountType.individual,
                onTap: () => setState(() => _selected = AccountType.individual),
              ),
              const SizedBox(height: 12),
              _AccountChoiceCard(
                title: 'حساب شركة',
                description: 'لفريق عمل — لوحة تحكم إدارية وفوترة موحّدة للموظفين',
                icon: Icons.apartment_rounded,
                selected: _selected == AccountType.business,
                onTap: () => setState(() => _selected = AccountType.business),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.seriesBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          accountType: _selected,
                          signalingService: widget.signalingService,
                          webrtcService: widget.webrtcService,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'متابعة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChoiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AccountChoiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.seriesBlue.withOpacity(0.12) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.seriesBlue : AppColors.gridline),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.surface1, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.seriesBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
