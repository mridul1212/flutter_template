import 'package:flutter/material.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/logno_tab_widgets.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_widgets.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_banner.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_selector.dart';

class LognoPage extends StatefulWidget {
  const LognoPage({super.key});

  @override
  State<LognoPage> createState() => _LognoPageState();
}

class _LognoPageState extends State<LognoPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লগ্ন / শুভ মুহূর্ত'),
        actions: const [PonjikaYearSelector()],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'পূজা লগ্ন'),
            Tab(text: 'বিয়ে লগ্ন'),
            Tab(text: 'বেয়ে'),
            Tab(text: 'হাইলাইট'),
          ],
        ),
      ),
      body: Column(
        children: [
          const PonjikaYearBanner(),
          Expanded(
            child: PonjikaLoadBody(
              builder: (context, data) {
                final logno = data.logno;
                return TabBarView(
                  key: ValueKey<int>(data.year),
                  controller: _tabs,
                  children: [
                    LognoSectionTab(section: logno.puja, showTimings: true),
                    LognoSectionTab(section: logno.marriage),
                    LognoSectionTab(section: logno.beye),
                    LognoHighlightsSection(year: data.year, highlights: logno.monthlyHighlights),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
