import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

import './images.dart';

void main() => runApp(new ExampleApp());

class ExampleApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			title: 'Sticky Headers Example',
			theme: new ThemeData(
				primarySwatch: Colors.blueGrey,
			),
			home: new MainScreen(),
		);
	}
}

class MainScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new ScaffoldWrapper(
			title: 'Sticky Headers Example',
			child: new ListView(
				children: ListTile.divideTiles(
					context: context,
					tiles: <Widget>[
						new ListTile(
							title: const Text('Example 1 - Headers and Content'),
							onTap: () => navigateTo(context, (context) => new Example1()),
						),
						new ListTile(
							title: const Text('Example 2 - Animated Headers with Content'),
							onTap: () => navigateTo(context, (context) => new Example2()),
						),
						new ListTile(
							title: const Text('Example 3 - Headers overlapping the Content'),
							onTap: () => navigateTo(context, (context) => new Example3()),
						),
					],
				).toList(growable: false),
			),
		);
	}

	navigateTo(BuildContext context, builder(BuildContext context)) {
		Navigator.of(context).push(new MaterialPageRoute(builder: builder));
	}
}

class Example1 extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new ScaffoldWrapper(
			title: 'Example 1',
			child: new ListView.builder(itemBuilder: (context, index) {
				return new Material(
					color: Colors.grey[300],
					child: new StickyHeader(
						header: new Container(
							height: 50.0,
							color: Colors.blueGrey[700],
							padding: new EdgeInsets.symmetric(horizontal: 16.0),
							alignment: Alignment.centerLeft,
							child: new Text('Header #$index',
								style: const TextStyle(color: Colors.white),
							),
						),
						content: new Container(
							child: new Image.network(imageForIndex(index), fit: BoxFit.cover,
								width: double.infinity, height: 200.0),
						),
					),
				);
			}),
		);
	}

	String imageForIndex(int index) {
		return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
	}
}

class Example2 extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new ScaffoldWrapper(
			title: 'Example 2',
			child: new ListView.builder(itemBuilder: (context, index) {
				return new Material(
					color: Colors.grey[300],
					child: new StickyHeaderBuilder(
						builder: (BuildContext context, double stuckAmount) {
							stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
							return new Container(
								height: 50.0,
								color: Color.lerp(Colors.blue[700], Colors.red[700], stuckAmount),
								padding: new EdgeInsets.symmetric(horizontal: 16.0),
								alignment: Alignment.centerLeft,
								child: new Row(
									children: <Widget>[
										new Expanded(
											child: new Text('Header #$index',
												style: const TextStyle(color: Colors.white),
											),
										),
										new Offstage(
											offstage: stuckAmount <= 0.0,
											child: new Opacity(
												opacity: stuckAmount,
												child: new IconButton(
													icon: new Icon(Icons.favorite, color: Colors.white),
													onPressed: () =>
														Scaffold.of(context).showSnackBar(
															new SnackBar(content: new Text('Favorite #$index'))
														),
												),
											),
										),
									],
								),
							);
						},
						content: new Container(
							child: new Image.network(imageForIndex(index), fit: BoxFit.cover,
								width: double.infinity, height: 200.0),
						),
					),
				);
			}),
		);
	}

	String imageForIndex(int index) {
		return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
	}
}

class Example3 extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new ScaffoldWrapper(
			title: 'Example 3',
			child: new ListView.builder(itemBuilder: (context, index) {
				return new Material(
					color: Colors.grey[300],
					child: new StickyHeaderBuilder(
						overlapHeaders: true,
						builder: (BuildContext context, double stuckAmount) {
							stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
							return new Container(
								height: 50.0,
								color: Colors.grey[900].withOpacity(0.6 + stuckAmount * 0.4),
								padding: new EdgeInsets.symmetric(horizontal: 16.0),
								alignment: Alignment.centerLeft,
								child: new Text('Header #$index',
									style: const TextStyle(color: Colors.white),
								),
							);
						},
						content: new Container(
							child: new Image.network(imageForIndex(index), fit: BoxFit.cover,
								width: double.infinity, height: 200.0),
						),
					),
				);
			}),
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
		return new Scaffold(
			appBar: new PreferredSize(
				preferredSize: new Size.fromHeight(kToolbarHeight),
				child: new Hero(
					tag: 'app_bar',
					child: new AppBar(
						title: new Text(title),
						elevation: 0.0,
					),
				),
			),
			body: child,
		);
	}
}
