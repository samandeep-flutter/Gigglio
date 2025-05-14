import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/image_resources.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:go_router/go_router.dart';
import '../../business_logic/auth_bloc/signin_bloc.dart';
import '../../config/routes/routes.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    final bloc = context.read<SignInBloc>();
    bloc.add(SignInInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<SignInBloc>();

    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                StringRes.signin,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Dimens.fontTitle),
              ),
            ),
            const SizedBox(height: Dimens.sizeLarge),
            Text(
              StringRes.signinDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.textColorLight),
            ),
            const SizedBox(height: Dimens.sizeExtraLarge),
            Form(
              key: bloc.formKey,
              child: Column(
                children: [
                  MyTextField(
                    title: 'Email',
                    isEmail: true,
                    controller: bloc.emailContr,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    title: 'Password',
                    obscureText: true,
                    controller: bloc.passwordContr,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LoadingTextButton(
                    defWidth: true,
                    compact: true,
                    onPressed: () => context.pushNamed(AppRoutes.forgotPass),
                    child: const Text('${StringRes.forgotPass}?'))
              ],
            ),
            const SizedBox(height: Dimens.sizeMidLarge),
            BlocBuilder<SignInBloc, SignInState>(
                buildWhen: (pr, cr) => pr.emailLoading != cr.emailLoading,
                builder: (context, state) {
                  return LoadingButton(
                      isLoading: state.emailLoading,
                      onPressed: () => bloc.add(SignInviaEmail()),
                      child: const Text(StringRes.signin));
                }),
            BlocListener<SignInBloc, SignInState>(
                listenWhen: (pr, cr) => pr.success != cr.success,
                listener: (context, state) {
                  if (state.success) context.goNamed(bloc.auth.initialRoute);
                },
                child: const SizedBox(height: Dimens.sizeDefault)),
            Align(
                alignment: Alignment.center,
                child: Text(StringRes.continueWith,
                    style: TextStyle(color: scheme.disabled))),
            const SizedBox(height: Dimens.sizeMedSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(Dimens.borderDefault),
                    ),
                    child: BlocBuilder<SignInBloc, SignInState>(
                        buildWhen: (pr, cr) =>
                            pr.googleLoading != cr.googleLoading,
                        builder: (context, state) {
                          return LoadingIcon(
                            loading: state.googleLoading,
                            onPressed: () => bloc.add(SignInviaGoogle()),
                            icon: Image.asset(ImageRes.google,
                                height: 24, width: 24),
                          );
                        }),
                  ),
                ),
                const SizedBox(width: Dimens.sizeDefault),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(Dimens.borderDefault),
                    ),
                    child: BlocBuilder<SignInBloc, SignInState>(
                        buildWhen: (pr, cr) =>
                            pr.twitterLoading != cr.twitterLoading,
                        builder: (context, state) {
                          return LoadingIcon(
                            loading: state.twitterLoading,
                            onPressed: () => bloc.add(SignInviaTwitter()),
                            icon: Image.asset(ImageRes.twitter,
                                height: 24, width: 24),
                          );
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.sizeLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(StringRes.noAcc),
                LoadingTextButton(
                    defWidth: true,
                    onPressed: () => context.pushNamed(AppRoutes.signUp),
                    child: const Text(StringRes.createAcc))
              ],
            ),
            const SizedBox(height: Dimens.sizeSmall),
          ],
        ));
  }
}
