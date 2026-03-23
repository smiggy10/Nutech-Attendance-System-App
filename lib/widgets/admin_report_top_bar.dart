import 'package:flutter/material.dart';

/// Top bar for admin report screens: circular back (`<`) and optional export icon only.
class AdminReportTopBar extends StatelessWidget {
  const AdminReportTopBar({
    super.key,
    required this.onBack,
    this.onExport,
    this.exportBusy = false,
  });

  final VoidCallback onBack;
  final VoidCallback? onExport;
  final bool exportBusy;

  static Color get _circleFill => Colors.black.withOpacity(0.10);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          _RoundGrayButton(
            onPressed: onBack,
            child: const Text(
              '<',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2C2C),
                height: 1,
              ),
            ),
          ),
          const Spacer(),
          if (onExport != null)
            _RoundGrayButton(
              onPressed: exportBusy ? null : onExport,
              child: exportBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF2C2C2C),
                      ),
                    )
                  : const Icon(
                      Icons.file_download_outlined,
                      size: 22,
                      color: Color(0xFF2C2C2C),
                    ),
            ),
        ],
      ),
    );
  }
}

class _RoundGrayButton extends StatelessWidget {
  const _RoundGrayButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminReportTopBar._circleFill,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: child),
        ),
      ),
    );
  }
}
