import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/edit_profile_bloc.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/loading_widgets.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/presentation/widgets/my_cached_image.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/utils.dart';
import '../widgets/my_text_field_widget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    final bloc = context.read<EditProfileBloc>();
    bloc.add(EditProfileInitial());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditProfileBloc>();
    final scheme = context.scheme;

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.editProfile),
          titleTextStyle: Utils.defTitleStyle,
          centerTitle: true,
        ),
        child: ListView(
          children: [
            SizedBox(height: context.height * .05),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () => imagePicker(context),
                borderRadius: BorderRadius.circular(Dimens.circularBoder),
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.sizeSmall),
                  child: BlocBuilder<EditProfileBloc, EditProfileState>(
                      buildWhen: (pr, cr) {
                    final imageUrl = pr.imageUrl != cr.imageUrl;
                    final loading = pr.imageLoading != cr.imageLoading;
                    return imageUrl || loading;
                  }, builder: (context, state) {
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        MyCachedImage(state.imageUrl,
                            isAvatar: true, avatarRadius: 80),
                        if (state.imageLoading)
                          DecoratedBox(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black45),
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(80),
                              child: const Align(
                                alignment: Alignment.center,
                                child: SizedBox.square(
                                  dimension: Dimens.sizeMidLarge,
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: scheme.background),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.textColor),
                            padding: const EdgeInsets.all(Dimens.sizeSmall),
                            margin: const EdgeInsets.all(Dimens.sizeExtraSmall),
                            child: Icon(Icons.edit, color: scheme.onPrimary),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: Dimens.sizeMidLarge),
            Text(
              StringRes.editProfileDesc,
              style: TextStyle(color: scheme.textColorLight),
            ),
            const SizedBox(height: Dimens.sizeLarge),
            Form(
              key: bloc.editFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    title: 'Display Name',
                    capitalization: TextCapitalization.words,
                    controller: bloc.nameController,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  CustomTextField(
                    title: 'Bio',
                    capitalization: TextCapitalization.words,
                    maxLines: 4,
                    controller: bloc.bioContr,
                    backgroundColor: Colors.transparent,
                    defaultBorder: true,
                  ),
                ],
              ),
            ),
            BlocListener<EditProfileBloc, EditProfileState>(
              listenWhen: (pr, cr) => pr.success != cr.success,
              listener: (context, state) {
                if (state.success) context.pop();
              },
              child: SizedBox(height: context.height * .05),
            ),
            BlocBuilder<EditProfileBloc, EditProfileState>(
              buildWhen: (pr, cr) => pr.profileLoading != cr.profileLoading,
              builder: (context, state) {
                return LoadingButton(
                    width: double.infinity,
                    isLoading: state.profileLoading,
                    onPressed: () => bloc.add(EditProfileSubmit()),
                    child: const Text(StringRes.submit));
              },
            ),
            const SizedBox(height: Dimens.sizeLarge),
          ],
        ));
  }

  void imagePicker(BuildContext context) {
    final bloc = context.read<EditProfileBloc>();

    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
              actions: const [],
              actionPadding: EdgeInsets.zero,
              title: StringRes.pickFrom,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      context.pop();
                      bloc.add(EditProfileImage(ImageSource.gallery));
                    },
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text(StringRes.gallery),
                  ),
                  ListTile(
                    onTap: () {
                      context.pop();
                      bloc.add(EditProfileImage(ImageSource.camera));
                    },
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text(StringRes.camera),
                  ),
                ],
              ));
        });
  }
}
