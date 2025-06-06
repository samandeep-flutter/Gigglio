import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/goto_post_bloc.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/home_view/post_tile.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';

class GotoPost extends StatefulWidget {
  final String doc;
  const GotoPost(this.doc, {super.key});

  @override
  State<GotoPost> createState() => _GotoPostState();
}

class _GotoPostState extends State<GotoPost> {
  @override
  void initState() {
    final bloc = context.read<GotoPostBloc>();
    bloc.add(GotoPostInitial(widget.doc));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
          centerTitle: false,
          title: const Text(StringRes.appName),
          backgroundColor: scheme.background,
          titleTextStyle: Utils.defTitleStyle.copyWith(
            fontWeight: FontWeight.bold,
          )),
      child: SingleChildScrollView(
        child: BlocBuilder<GotoPostBloc, GoToPostState>(
          builder: (context, state) {
            if (state.loading) return const PostTileShimmer();
            return PostTile(state.post!, reload: reload);
          },
        ),
      ),
    );
  }

  void reload() {
    final bloc = context.read<GotoPostBloc>();
    bloc.add(GotoPostInitial(widget.doc));
  }
}
