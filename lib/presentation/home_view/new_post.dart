import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/presentation/widgets/my_text_field_widget.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/utils.dart';
import '../../business_logic/home_bloc/new_post_bloc.dart';
import '../widgets/base_widget.dart';
import '../widgets/loading_widgets.dart';

class NewPost extends StatelessWidget {
  const NewPost({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewPostBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.newPost),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: true,
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: Dimens.sizeSmall),
        children: [
          const ImageWidget(),
          const SizedBox(height: Dimens.sizeLarge),
          SizedBox(
            height: context.height * .4,
            child: CustomTextField(
              title: 'Write a Caption...',
              expands: true,
              margin: Utils.paddingHoriz(Dimens.sizeDefault),
              capitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              controller: bloc.captionContr,
            ),
          ),
          BlocListener<NewPostBloc, NewPostState>(
              listenWhen: (pr, cr) => pr.success != cr.success,
              listener: (context, state) {
                if (state.success) context.pop();
              },
              child: const SizedBox(height: Dimens.sizeLarge)),
          BlocBuilder<NewPostBloc, NewPostState>(buildWhen: (pr, cr) {
            final loading = pr.postLoading != cr.postLoading;
            final images = pr.postImages != cr.postImages;
            return loading || images;
          }, builder: (context, state) {
            return LoadingButton(
                width: double.infinity,
                isLoading: state.postLoading,
                enable: state.postImages.isNotEmpty,
                margin: Utils.paddingHoriz(Dimens.sizeDefault),
                onPressed: () => bloc.add(NewPostSubmit()),
                child: const Text(StringRes.post));
          }),
          const SizedBox(height: Dimens.sizeDefault)
        ],
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewPostBloc>();
    final scheme = context.scheme;

    return SizedBox(
        height: context.height * .25,
        child: ListView(
            padding: Utils.paddingHoriz(Dimens.sizeDefault),
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimens.sizeSmall),
                child: InkWell(
                  onTap: () => bloc.add(NewPostPickImages()),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(Dimens.borderDefault),
                  ),
                  child: Container(
                      width: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.backgroundDark,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            StringRes.addPhotos,
                            style: TextStyle(color: scheme.textColorLight),
                          ),
                          const SizedBox(height: Dimens.sizeDefault),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: scheme.surface,
                            child: Icon(Icons.add, color: scheme.disabled),
                          ),
                        ],
                      )),
                ),
              ),
              BlocBuilder<NewPostBloc, NewPostState>(
                  buildWhen: (pr, cr) => pr.postImages != cr.postImages,
                  builder: (context, state) {
                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.postImages.length,
                        itemBuilder: (context, index) {
                          final item = state.postImages[index];
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(Dimens.sizeSmall),
                                child: Image.file(item),
                              ),
                              IconButton(
                                  style: IconButton.styleFrom(
                                      elevation: Dimens.sizeExtraSmall,
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      iconSize: 16,
                                      backgroundColor: ColorRes.onTertiary,
                                      foregroundColor: ColorRes.tertiary),
                                  onPressed: () =>
                                      bloc.add(NewPostRemovePicked(index)),
                                  icon: const Icon(Icons.clear))
                            ],
                          );
                        });
                  }),
            ]));
  }
}
