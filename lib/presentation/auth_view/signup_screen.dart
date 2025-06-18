import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import '../../business_logic/auth_bloc/signup_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    final bloc = context.read<SignUpBloc>();
    bloc.add(SignupInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<SignUpBloc>();

    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                StringRes.signup,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Dimens.fontTitle),
              ),
            ),
            const SizedBox(height: Dimens.sizeSmall),
            Text(
              StringRes.singupDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.textColorLight),
            ),
            const SizedBox(height: Dimens.sizeExtraLarge),
            Form(
              key: bloc.formKey,
              child: Column(
                children: [
                  MyTextField(
                    title: 'Name',
                    controller: bloc.nameContr,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    title: 'Email',
                    isEmail: true,
                    controller: bloc.emailContr,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    title: 'Password',
                    obscureText: true,
                    isPass: true,
                    controller: bloc.passContr,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    title: 'Confirm Password',
                    obscureText: true,
                    controller: bloc.confirmPassContr,
                    customValidator: (value) {
                      if (value?.isEmpty ?? true) {
                        return StringRes.errorEmpty('Confirm Password');
                      } else if (value != bloc.passContr.text) {
                        return StringRes.errorPassMatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimens.sizeSmall),
            Text(
              StringRes.newPassDesc,
              style: TextStyle(color: scheme.textColorLight),
            ),
            BlocListener<SignUpBloc, SignupState>(
                listenWhen: (pr, cr) => pr.success != cr.success,
                listener: (context, state) {
                  if (state.success) context.goNamed(bloc.auth.initialRoute);
                },
                child: const SizedBox(height: Dimens.sizeExtraLarge)),
            BlocBuilder<SignUpBloc, SignupState>(
              buildWhen: (pr, cr) => pr.loading != cr.loading,
              builder: (context, state) {
                return LoadingButton(
                    isLoading: state.loading,
                    onPressed: () => bloc.add(SignUpviaEmail()),
                    child: const Text(StringRes.signup));
              },
            ),
            const SizedBox(height: Dimens.sizeSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(StringRes.accAlready),
                LoadingTextButton(
                  defWidth: true,
                  onPressed: context.pop,
                  child: const Text(StringRes.signin),
                )
              ],
            ),
            const SizedBox(height: Dimens.sizeSmall),
          ],
        ));
  }
}
