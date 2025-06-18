import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/view_requests_bloc.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../data/utils/utils.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/shimmer_widget.dart';

class ViewRequests extends StatefulWidget {
  const ViewRequests({super.key});

  @override
  State<ViewRequests> createState() => _ViewRequestsState();
}

class _ViewRequestsState extends State<ViewRequests> {
  @override
  void initState() {
    final bloc = context.read<ViewRequestsBloc>();
    bloc.add(ViewRequestInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.viewRequests),
        titleTextStyle: Utils.defTitleStyle,
      ),
      child: BlocBuilder<ViewRequestsBloc, ViewRequestState>(
          buildWhen: (pr, cr) => pr.isLoading != cr.isLoading,
          builder: (context, state) {
            if (state.isLoading) return const FriendsRequests();
            if (state.requests.isEmpty) {
              return const ToolTipWidget(title: StringRes.noRequestsDesc);
            }

            return ListView.builder(
                padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final req = state.requests[index];
                  return ListTile(
                    contentPadding: Utils.paddingHoriz(Dimens.sizeLarge),
                    leading: MyAvatar(req.image, isAvatar: true, id: req.id),
                    title: Text(req.displayName),
                    subtitle: Text(req.email,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitleTextStyle: context.subtitleTextStyle,
                    trailing: _TrailingWidget(id: req.id),
                  );
                });
          }),
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final String id;
  const _TrailingWidget({required this.id});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViewRequestsBloc>();

    return BlocBuilder<ViewRequestsBloc, ViewRequestState>(
        buildWhen: (pr, cr) => pr.reqAccepted != cr.reqAccepted,
        builder: (context, state) {
          return LoadingButton(
              defWidth: true,
              compact: true,
              border: Dimens.borderSmall,
              enable: !state.reqAccepted.contains(id),
              onPressed: () => bloc.add(RequestAccepted(id)),
              child: state.reqAccepted.contains(id)
                  ? const Text(StringRes.accepted)
                  : const Text(StringRes.accept));
        });
  }
}
