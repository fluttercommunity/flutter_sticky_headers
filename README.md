[![Flutter Community: sticky_headers](https://fluttercommunity.dev/_github/header/sticky_headers)](https://github.com/fluttercommunity/community)

# Flutter Sticky Headers

[![pub package](https://img.shields.io/pub/v/sticky_headers.svg)](https://pub.dartlang.org/packages/sticky_headers)

Lets you place headers on scrollable content that will stick to the top of the container
whilst the content is scrolled.

## Usage
You can place a `StickyHeader` or `StickyHeaderBuilder`
inside any scrollable content, such as:  `ListView`, `GridView`, `CustomScrollView`,
`SingleChildScrollView` or similar.

Depend on it:
```yaml
dependencies:
  sticky_headers: "^0.1.8"
```

Import it:
```dart
import 'package:sticky_headers/sticky_headers.dart';
```

Use it:
```dart
class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(itemBuilder: (context, index) {
      return new StickyHeader(
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
      );
    });
  }
}
```


## Examples

### Example 1 - Headers and Content
![Demo 1](https://github.com/slightfoot/flutter_sticky_headers/raw/gh-pages/demo1.gif)

### Example 2 - Animated Headers with Content
![Demo 2](https://github.com/slightfoot/flutter_sticky_headers/raw/gh-pages/demo2.gif)

### Example 3 - Headers overlapping the Content
![Demo 3](https://github.com/slightfoot/flutter_sticky_headers/raw/gh-pages/demo3.gif)

## Bugs/Requests
If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull request are also welcome.
