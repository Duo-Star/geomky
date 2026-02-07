import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationRail].

void main() => runApp(const NavigationRailExampleApp());

class NavigationRailExampleApp extends StatelessWidget {
  const NavigationRailExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavRailExample());
  }
}

class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = true;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(12), // 设置边距
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // 向下对齐
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.savings),
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(Size(50, 50)),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.savings),
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(Size(50, 50)),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('selectedIndex: $_selectedIndex'),
                  const SizedBox(height: 20),
                  Text('Label type: ${labelType.name}'),
                  const SizedBox(height: 10),
                  SegmentedButton<NavigationRailLabelType>(
                    segments: const <ButtonSegment<NavigationRailLabelType>>[
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.none,
                        label: Text('None'),
                      ),
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.selected,
                        label: Text('Selected'),
                      ),
                      ButtonSegment<NavigationRailLabelType>(
                        value: NavigationRailLabelType.all,
                        label: Text('All'),
                      ),
                    ],
                    selected: <NavigationRailLabelType>{labelType},
                    onSelectionChanged:
                        (Set<NavigationRailLabelType> newSelection) {
                          setState(() {
                            labelType = newSelection.first;
                          });
                        },
                  ),
                  const SizedBox(height: 20),
                  Text('Group alignment: $groupAlignment'),
                  const SizedBox(height: 10),
                  SegmentedButton<double>(
                    segments: const <ButtonSegment<double>>[
                      ButtonSegment<double>(value: -1.0, label: Text('Top')),
                      ButtonSegment<double>(value: 0.0, label: Text('Center')),
                      ButtonSegment<double>(value: 1.0, label: Text('Bottom')),
                    ],
                    selected: <double>{groupAlignment},
                    onSelectionChanged: (Set<double> newSelection) {
                      setState(() {
                        groupAlignment = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(showLeading ? 'Hide Leading' : 'Show Leading'),
                    value: showLeading,
                    onChanged: (bool value) {
                      setState(() {
                        showLeading = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      showTrailing ? 'Hide Trailing' : 'Show Trailing',
                    ),
                    value: showTrailing,
                    onChanged: (bool value) {
                      setState(() {
                        showTrailing = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
