import 'package:flutter/material.dart';

enum ConnectionType { satellite, wifi, cellular }

enum CallQualityLabel { excellent, fair, poor }

/// موديل مبسّط لجهة اتصال — في النسخة الحقيقية هيجي من الـ Backend API
/// (جدول جهات الاتصال المرتبط بحساب المستخدم أو المؤسسة).
class Contact {
  final String id;
  final String name;
  final String initial;
  final ConnectionType connectionType;
  final CallQualityLabel quality;
  final String lastCallLabel;
  final Color avatarColor;

  const Contact({
    required this.id,
    required this.name,
    required this.initial,
    required this.connectionType,
    required this.quality,
    required this.lastCallLabel,
    required this.avatarColor,
  });
}

/// بيانات وهمية (Mock) لعرض تصميم الشاشة الرئيسية قبل ربطها بالـ Backend الحقيقي.
final List<Contact> mockContacts = <Contact>[
  const Contact(
    id: 'ahmed',
    name: 'أحمد رفعت',
    initial: 'أ',
    connectionType: ConnectionType.satellite,
    quality: CallQualityLabel.excellent,
    lastCallLabel: '10:42',
    avatarColor: Color(0xFF9085E9),
  ),
  const Contact(
    id: 'shipping-co',
    name: 'شركة الشحن البحري',
    initial: 'ش',
    connectionType: ConnectionType.satellite,
    quality: CallQualityLabel.fair,
    lastCallLabel: 'أمس',
    avatarColor: Color(0xFF3987E5),
  ),
  const Contact(
    id: 'yasmin',
    name: 'ياسمين علي',
    initial: 'ي',
    connectionType: ConnectionType.wifi,
    quality: CallQualityLabel.excellent,
    lastCallLabel: 'أمس',
    avatarColor: Color(0xFF199E70),
  ),
  const Contact(
    id: 'field-team',
    name: 'فريق العمل الميداني',
    initial: 'ف',
    connectionType: ConnectionType.satellite,
    quality: CallQualityLabel.excellent,
    lastCallLabel: 'الإثنين',
    avatarColor: Color(0xFFEB6834),
  ),
];
