import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sticky_headers/sticky_headers.dart';

import './images.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Headers Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Sticky Headers Example',
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: <Widget>[
            ListTile(
              title: const Text('Example 1 - Headers and Content'),
              onTap: () => navigateTo(context, (context) => Example1()),
            ),
            ListTile(
              title: const Text('Example 2 - Animated Headers with Content'),
              onTap: () => navigateTo(context, (context) => Example2()),
            ),
            ListTile(
              title: const Text('Example 3 - Headers overlapping the Content'),
              onTap: () => navigateTo(context, (context) => Example3()),
            ),
            ListTile(
              title: const Text('Example 4 - Example using scroll controller'),
              onTap: () => navigateTo(context, (context) => Example4()),
            ),
          ],
        ).toList(growable: false),
      ),
    );
  }

  navigateTo(BuildContext context, builder(BuildContext context)) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }
}

class Example1 extends StatelessWidget {
  const Example1({
    Key key,
    this.controller,
  }) : super(key: key);

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 1',
      child: ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.grey[300],
            child: StickyHeader(
              controller: controller, // Optional
              header: Container(
                height: 50.0,
                color: Colors.blueGrey[700],
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Header #$index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              content: Container(
                child: Image.network(imageForIndex(index), fit: BoxFit.cover, width: double.infinity, height: 200.0),
              ),
            ),
          );
        },
      ),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class Example2 extends StatelessWidget {
  const Example2({
    Key key,
    this.controller,
  }) : super(key: key);

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 2',
      child: ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.grey[300],
            child: StickyHeaderBuilder(
              controller: controller, // Optional
              builder: (BuildContext context, double stuckAmount) {
                stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                return Container(
                  height: 50.0,
                  color: Color.lerp(Colors.blue[700], Colors.red[700], stuckAmount),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Header #$index',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Offstage(
                        offstage: stuckAmount <= 0.0,
                        child: Opacity(
                          opacity: stuckAmount,
                          child: IconButton(
                            icon: Icon(Icons.favorite, color: Colors.white),
                            onPressed: () =>
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Favorite #$index'))),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              content: Container(
                child: Image.network(imageForIndex(index), fit: BoxFit.cover, width: double.infinity, height: 200.0),
              ),
            ),
          );
        },
      ),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class Example3 extends StatelessWidget {
  const Example3({
    Key key,
    this.controller,
  }) : super(key: key);

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 3',
      child: ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.grey[300],
            child: StickyHeaderBuilder(
              overlapHeaders: true,
              controller: controller, // Optional
              builder: (BuildContext context, double stuckAmount) {
                stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                return Container(
                  height: 50.0,
                  color: Colors.grey[900].withOpacity(0.6 + stuckAmount * 0.4),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Header #$index',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              content: Container(
                child: Image.network(
                  imageForIndex(index),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class ScaffoldWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const ScaffoldWrapper({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'app_bar',
          child: AppBar(
            title: Text(title),
            elevation: 0.0,
          ),
        ),
      ),
      body: child,
    );
  }
}

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> {
  final controller = ScrollController();

  final _tabs = <String, WidgetBuilder>{};

  @override
  void initState() {
    super.initState();
    _tabs.addAll({
      'Example 1': (context) => Example1(controller: controller),
      'Example 2': (context) => Example2(controller: controller),
      'Example 3': (context) => Example3(controller: controller),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          controller: controller,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverAppBar(
                  title: const Text('Example 4'),
                  pinned: true,
                  expandedHeight: 150.0,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: <Tab>[
                      ..._tabs.entries.map<Tab>((MapEntry<String, WidgetBuilder> entry) {
                        return Tab(text: entry.key);
                      }),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              ..._tabs.entries.map<Widget>((MapEntry<String, WidgetBuilder> entry) {
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Builder(
                    builder: (BuildContext context) {
                      return KeyedSubtree(
                        key: PageStorageKey<String>(entry.key),
                        child: entry.value(context),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
