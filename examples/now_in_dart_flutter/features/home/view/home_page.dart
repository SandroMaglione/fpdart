import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:now_in_dart_flutter/core/presentation/assets_path.dart';
import 'package:now_in_dart_flutter/core/presentation/lazy_indexed_stack.dart';
import 'package:now_in_dart_flutter/core/presentation/responsive.dart';
import 'package:now_in_dart_flutter/features/detail/dart_detail/presentation/view/dart_changelog_page.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/presentation/view/flutter_detail_page.dart';
import 'package:now_in_dart_flutter/features/home/cubit/home_cubit.dart';
import 'package:vector_graphics/vector_graphics.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileView(),
      tabletOrDesktop: TabletOrDesktopView(),
    );
  }
}

class MobileView extends StatelessWidget {
  const MobileView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    const pages = <Widget>[DartChangelogPage(), FlutterDetailPage()];

    final selectedTabIndex = context.select<HomeCubit, int>(
      (HomeCubit cubit) => cubit.state.index,
    );
    return Scaffold(
      body: LazyIndexedStack(
        index: selectedTabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        selectedIndex: selectedTabIndex,
        onDestinationSelected: context.read<HomeCubit>().setTab,
      ),
    );
  }
}

class TabletOrDesktopView extends StatelessWidget {
  const TabletOrDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    const pages = <Widget>[DartChangelogPage(), FlutterDetailPage()];

    final selectedTabIndex = context.select<HomeCubit, int>(
      (HomeCubit cubit) => cubit.state.index,
    );
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: _railDestinations,
            selectedIndex: selectedTabIndex,
            useIndicator: true,
            labelType: NavigationRailLabelType.selected,
            groupAlignment: 0,
            onDestinationSelected: context.read<HomeCubit>().setTab,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: LazyIndexedStack(
              index: selectedTabIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

final _destinations = <NavigationDestination>[
  const NavigationDestination(
    icon: SvgPicture(
      AssetBytesLoader(AssetsPath.dartIcon),
      width: 24,
      height: 24,
    ),
    label: 'Dart',
  ),
  const NavigationDestination(
    icon: SvgPicture(
      AssetBytesLoader(AssetsPath.flutterIcon),
      width: 24,
      height: 24,
    ),
    label: 'Flutter',
  ),
];

final _railDestinations = <NavigationRailDestination>[
  NavigationRailDestination(
    icon: SvgPicture.asset(
      AssetsPath.dartIcon,
      width: 24,
      height: 24,
    ),
    label: const Text('Dart'),
  ),
  NavigationRailDestination(
    icon: SvgPicture.asset(
      AssetsPath.flutterIcon,
      width: 24,
      height: 24,
    ),
    label: const Text('Flutter'),
  ),
];
