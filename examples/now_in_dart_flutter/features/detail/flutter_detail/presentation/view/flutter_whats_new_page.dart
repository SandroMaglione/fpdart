import 'package:flutter/material.dart';
import 'package:now_in_dart_flutter/core/data/id.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/application/flutter_detail_bloc.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/presentation/view/flutter_detail_common.dart';

class FlutterWhatsNewPage extends StatefulWidget {
  const FlutterWhatsNewPage({super.key});

  @override
  State<FlutterWhatsNewPage> createState() => _FlutterWhatsNewPageState();
}

class _FlutterWhatsNewPageState extends State<FlutterWhatsNewPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const FlutterDetailCommonPage(
      event: FlutterWhatsNewDetailRequested(
        EntityId.flutterWhatsNewDetail,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
