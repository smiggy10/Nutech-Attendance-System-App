import 'package:flutter/material.dart';

import '../../../models/site_location.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/segmented_tabs.dart';

class SitePage extends StatefulWidget {
  const SitePage({super.key});

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
    final title1 = _offices ? 'SELECT' : 'SELECT';
    final title2 = _offices ? 'OFFICE' : 'PROJECT SITES';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title1, style: Theme.of(context).textTheme.headlineMedium),
          Text(title2, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),

          SegmentedTabs(
            leftLabel: 'Offices',
            rightLabel: 'Project Sites',
            isLeftSelected: _offices,
            onLeft: () => setState(() => _offices = true),
            onRight: () => setState(() => _offices = false),
          ),

          const SizedBox(height: 18),
          ...(_offices ? _officesList : _sitesList).map((s) => _SiteCard(site: s)),
        ],
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site});

  final SiteLocation site;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Since the actual photos weren't provided, we use a placeholder.
            SizedBox(
              height: 110,
              child: Image.asset(
                site.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                site.subtitle,
                                style: const TextStyle(color: AppTheme.muted),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
