import 'package:flutter/material.dart';

import '../../../models/site_location.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/segmented_tabs.dart';

class SitePage extends StatefulWidget {
  // 1. Accept the callback from HomeShell
  const SitePage({super.key, required this.onSiteSelected});

  final Function(String) onSiteSelected;

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  bool _offices = true;

  final _officesList = const [
    SiteLocation(
      title: 'Office A',
      subtitle: 'Marawoy, Lipa City',
      imageAsset: 'assets/images/offices/office1.jpg',
    ),
    SiteLocation(
      title: 'Office B',
      subtitle: 'Inosluban, Lipa City',
      imageAsset: 'assets/images/offices/office2.jpg',
    ),
    SiteLocation(
      title: 'Office C',
      subtitle: 'Lima, Lipa City',
      imageAsset: 'assets/images/offices/office3.jpg',
    ),
  ];

  final _sitesList = const [
    SiteLocation(
      title: 'Project Site A',
      subtitle: 'Marawoy, Lipa City',
      imageAsset: 'assets/images/sites/site1.jpg',
    ),
    SiteLocation(
      title: 'Project Site B',
      subtitle: 'Kumintang Iaba, Batangas City',
      imageAsset: 'assets/images/sites/site2.jpg',
    ),
    SiteLocation(
      title: 'Project Site C',
      subtitle: 'Lipa City',
      imageAsset: 'assets/images/sites/site3.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final title1 = 'SELECT';
    final title2 = _offices ? 'OFFICE' : 'PROJECT SITES';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title1, style: Theme.of(context).textTheme.headlineMedium),
          Text(title2,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          SegmentedTabs(
            leftLabel: 'Offices',
            rightLabel: 'Project Sites',
            isLeftSelected: _offices,
            onLeft: () => setState(() => _offices = true),
            onRight: () => setState(() => _offices = false),
          ),
          const SizedBox(height: 18),
          
          // 2. Pass the callback down to each card
          ...(_offices ? _officesList : _sitesList).map(
            (s) => _SiteCard(
              site: s,
              onConfirm: widget.onSiteSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({
    required this.site,
    required this.onConfirm,
  });

  final SiteLocation site;
  final Function(String) onConfirm;

  void _showClockInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Clock In',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Do you want to clock in at ${site.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 3. Trigger the callback with the site title
              onConfirm(site.title);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showClockInDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 110,
                child: Image.asset(
                  site.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.tealSoft,
                    child: const Icon(Icons.business, size: 40, color: AppTheme.teal),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(site.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: AppTheme.teal),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  site.subtitle,
                                  style: const TextStyle(color: AppTheme.muted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.teal),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}