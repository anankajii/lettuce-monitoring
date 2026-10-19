import 'package:flutter/material.dart';

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2D57C)),
      ),
      child: const Row(
        children: [
          Icon(Icons.construction_rounded, size: 19, color: Color(0xFF8B6810)),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Mode UI demo — data dan fungsi belum terhubung.',
              style: TextStyle(color: Color(0xFF6F5410), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
