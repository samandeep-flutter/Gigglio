import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/image_resources.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/services/extension_services.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  String? _policy;

  @override
  void initState() {
    Future(_loadPolicy);
    super.initState();
  }

  Future<void> _loadPolicy() async {
    try {
      _policy = await rootBundle.loadString(AssetRes.privacyPolicy);
      setState(() {});
    } catch (e) {
      logPrint(e, 'policy');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      color: scheme.background,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: scheme.background,
          expandedHeight: 100,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text(StringRes.privacyPolicy),
            collapseMode: CollapseMode.pin,
            centerTitle: false,
          ),
        ),
        if (_policy?.isNotEmpty ?? false)
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeLarge),
            child: Html(data: _policy),
          )),
        const SliverToBoxAdapter(child: SizedBox(height: Dimens.sizeExtraLarge))
      ]),
    );
  }
}
