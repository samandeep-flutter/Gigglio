import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/my_text_field_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../model/utils/color_resources.dart';
import '../../model/utils/utils.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controller.dart';
import '../widgets/base_widget.dart';

class AddPost extends GetView<HomeController> {
  const AddPost({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.newPost),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: true,
      ),
      child: PopScope(
        onPopInvokedWithResult: controller.fromPost,
        child: ListView(
          children: [
            const SizedBox(height: Dimens.sizeLarge),
            const ImageWidget(),
            const SizedBox(height: Dimens.sizeLarge),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeLarge),
              child: Column(
                children: [
                  SizedBox(
                    height: context.height * .4,
                    child: CustomTextField(
                      title: 'Write a Caption...',
                      expands: true,
                      // maxLines: 5,
                      capitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      controller: controller.captionContr,
                    ),
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  Obx(() => LoadingButton(
                      width: double.infinity,
                      isLoading: controller.isPostLoading.value,
                      onPressed: controller.addPost,
                      child: const Text(StringRes.post))),
                  const SizedBox(height: Dimens.sizeDefault),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ImageWidget extends GetView<HomeController> {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return Obx(() {
      return Container(
          height: 200,
          margin: const EdgeInsets.only(left: Dimens.sizeLarge),
          child: ListView(
              padding: const EdgeInsets.only(right: Dimens.sizeDefault),
              scrollDirection: Axis.horizontal,
              children: [
                ...controller.postImages.map((e) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.sizeMedSmall,
                            Dimens.sizeMedSmall, Dimens.sizeSmall, 0),
                        child: Image.file(e),
                      ),
                      IconButton(
                          style: IconButton.styleFrom(
                              elevation: 5,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              iconSize: 16,
                              backgroundColor: ColorRes.tertiaryContainer,
                              foregroundColor: ColorRes.onTertiaryContainer),
                          onPressed: () => controller.postImages.remove(e),
                          icon: const Icon(Icons.clear))
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: Dimens.sizeMedSmall),
                  child: InkWell(
                    onTap: controller.pickImages,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Dimens.borderDefault),
                    ),
                    child: Container(
                        width: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: scheme.textColorLight.withOpacity(.1),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Dimens.borderDefault),
                            )),
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
                )
              ]));
    });
  }
}
