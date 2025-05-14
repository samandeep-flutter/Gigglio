import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/settings_bloc.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../widgets/base_widget.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(backgroundColor: scheme.background),
      child: PopScope(
        onPopInvokedWithResult: bloc.fromChangePass,
        child: ListView(
          children: [
            const SizedBox(height: Dimens.sizeExtraLarge),
            const Text(
              StringRes.changePass,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Dimens.fontUltraLarge),
            ),
            const SizedBox(height: Dimens.sizeSmall),
            Text(
              StringRes.newPassDesc,
              style: TextStyle(color: scheme.textColorLight),
            ),
            const SizedBox(height: Dimens.sizeLarge),
            Form(
              key: bloc.changePassKey,
              child: Column(
                children: [
                  MyTextField(
                    title: 'New Password',
                    isPass: true,
                    obscureText: true,
                    controller: bloc.newPassContr,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    title: 'Confirm Password',
                    isPass: true,
                    obscureText: true,
                    controller: bloc.confirmPassContr,
                    customValidator: (value) {
                      if (value?.isEmpty ?? true) {
                        return StringRes.errorEmpty('Confirm Password');
                      } else if (bloc.newPassContr.text != value) {
                        return StringRes.errorPassMatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            BlocListener<SettingsBloc, SettingsState>(
              listenWhen: (pr, cr) => pr.error != cr.error,
              listener: (context, state) {
                if (state.error == 'requires-recent-login') {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return MyAlertDialog(
                          title: 'Re-Authenticate',
                          content: const Text(StringRes.reauthDesc),
                          actions: [
                            TextButton(
                              onPressed: context.pop,
                              child: const Text(StringRes.cancel),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: bloc.auth.logout,
                              child: const Text('Re-Authenticate'),
                            ),
                          ],
                        );
                      });
                }
              },
              child: const SizedBox(height: Dimens.sizeExtraLarge),
            ),
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
              return LoadingButton(
                  isLoading: state.changePassLoading,
                  onPressed: () => bloc.add(PasswordChanged()),
                  child: const Text(StringRes.submit));
            }),
            const SizedBox(height: Dimens.sizeLarge),
          ],
        ),
      ),
    );
  }
}
