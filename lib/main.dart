import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      const scrollOffset = 250.0;

      controller.jumpTo(250);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollViewTestWidget(controller: controller);
  }
}

class NestedScrollViewTestWidget extends StatelessWidget {
  const NestedScrollViewTestWidget({Key? key, required this.controller}) : super(key: key);

  final ScrollController controller;

  static const itemExtent = 48.0;

  @override
  Widget build(BuildContext context) {
    const tabs = <String>['Tab 1', 'Tab 2'];

    final nestedScrollView = NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(
              children: [
                const SliverPinnedHeader(child: Padding(padding: EdgeInsets.all(16), child: Text('Bar 1'))),
                const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32), child: Text('Text 1'))),
                SliverPinnedHeader(
                    child: Material(color: Colors.green, child: TabBar(tabs: tabs.map((t) => Tab(text: t)).toList()))),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        children: tabs.map((String name) {
          return Material(
            color: Colors.red,
            child: Builder(
              builder: (BuildContext context) {
                return RefreshIndicator(
                  edgeOffset: NestedScrollView.sliverOverlapAbsorberHandleFor(context).layoutExtent ?? 0,
                  onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
                  child: CustomScrollView(
                    controller: controller,
                    key: PageStorageKey<String>(name),
                    slivers: <Widget>[
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      ),
                      SliverFillRemaining(
                        // hasScrollBody: false,
                        child: Center(child: Text(name)),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );

    return MaterialApp(
      home: DefaultTabController(
        length: tabs.length,
        child: Scaffold(body: nestedScrollView),
      ),
    );
  }
}
