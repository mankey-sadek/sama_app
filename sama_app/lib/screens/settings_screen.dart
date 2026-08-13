import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final String phoneNumber;

  const SettingsScreen({super.key, required this.phoneNumber});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _adaptiveQuality = true;
  bool _shareLocation = false;
  bool _autoReconnect = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface1,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gridline),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: AppColors.seriesBlue, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.phoneNumber, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    const Text('خطة فردية — Pro', style: TextStyle(color: AppColors.seriesAqua, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.seriesBlue.withOpacity(0.18), AppColors.seriesViolet.withOpacity(0.18)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gridline),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حساب شركة؟', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  'حوّل حسابك إلى Business عشان تضيف فريقك وتدير الفوترة والصلاحيات من لوحة تحكم واحدة.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            title: const Text('إشعارات المكالمات', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
            activeColor: AppColors.seriesBlue,
          ),
          SwitchListTile(
            value: _adaptiveQuality,
            onChanged: (v) => setState(() => _adaptiveQuality = v),
            title: const Text('جودة صوت تكيفية للشبكة الضعيفة', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
            activeColor: AppColors.seriesBlue,
          ),
          SwitchListTile(
            value: _shareLocation,
            onChanged: (v) => setState(() => _shareLocation = v),
            title: const Text('مشاركة الموقع أثناء المكالمة', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
            activeColor: AppColors.seriesBlue,
          ),
          SwitchListTile(
            value: _autoReconnect,
            onChanged: (v) => setState(() => _autoReconnect = v),
            title: const Text('إعادة اتصال تلقائي عند الانقطاع', style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
            activeColor: AppColors.seriesBlue,
          ),
        ],
      ),
    );
  }
}
