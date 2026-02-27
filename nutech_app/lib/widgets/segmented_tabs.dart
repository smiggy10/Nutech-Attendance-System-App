import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.teal, width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: leftLabel,
              selected: isLeftSelected,
              onTap: onLeft,
              isLeft: true,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: rightLabel,
              selected: !isLeftSelected,
              onTap: onRight,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isLeft,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(isLeft ? 10 : 0),
        right: Radius.circular(isLeft ? 0 : 10),
      ),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppTheme.teal : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isLeft ? 9 : 0),
            right: Radius.circular(isLeft ? 0 : 9),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppTheme.teal,
          ),
        ),
      ),
    );
  }
}
