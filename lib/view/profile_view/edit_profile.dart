import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/profile_controller.dart';
import '../../model/utils/dimens.dart';
import '../../services/theme_services.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/my_text_field_widget.dart';
import '../widgets/top_widgets.dart';

class EditProfile extends GetView<ProfileController> {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.editProfile),
          centerTitle: true,
        ),
        child: PopScope(
          onPopInvokedWithResult: controller.fromEditProfile,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeExtraLarge),
                InkWell(
                  onTap: () => controller.imagePicker(context),
                  borderRadius: BorderRadius.circular(Dimens.circularBoder),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.sizeSmall),
                    child: Obx(() => Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            MyCachedImage(
                              controller.imageUrl.value,
                              isAvatar: true,
                              avatarRadius: 80,
                            ),
                            if (controller.isImageLoading.value)
                              DecoratedBox(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black26,
                                ),
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(80),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: SizedBox.square(
                                      dimension: 32,
                                      child: CircularProgressIndicator(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.background,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[800],
                                ),
                                padding: const EdgeInsets.all(Dimens.sizeSmall),
                                margin:
                                    const EdgeInsets.all(Dimens.sizeExtraSmall),
                                child:
                                    const Icon(Icons.edit, color: Colors.white),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
                const SizedBox(height: Dimens.sizeMidLarge),
                Text(
                  StringRes.editProfileDesc,
                  style: TextStyle(color: scheme.textColorLight),
                ),
                const SizedBox(height: Dimens.sizeLarge),
                Form(
                  key: controller.editFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        title: 'Display Name',
                        capitalization: TextCapitalization.words,
                        controller: controller.nameController,
                      ),
                      const SizedBox(height: Dimens.sizeLarge),
                      CustomTextField(
                        title: 'Bio',
                        capitalization: TextCapitalization.words,
                        maxLines: 4,
                        controller: controller.bioContr,
                        backgroundColor: Colors.transparent,
                        defaultBorder: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.height * .1),
                Obx(() => LoadingButton(
                    width: double.infinity,
                    isLoading: controller.isProfileLoading.value,
                    onPressed: controller.editProfile,
                    child: const Text(StringRes.submit))),
                const SizedBox(height: Dimens.sizeLarge),
              ],
            ),
          ),
        ));
  }
}
