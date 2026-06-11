import 'package:flutter/material.dart';
import '../../features/subjects/model/subject_model.dart';

class SubjectChip extends StatelessWidget {
  final Subject subject;
  final bool small;

  const SubjectChip({super.key, required this.subject, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: subject.displayColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subject.displayColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        subject.name,
        style: TextStyle(
          color: subject.displayColor,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
