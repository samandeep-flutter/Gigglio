import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/forgot_pass_bloc.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<ForgotPassBloc>();

    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        safeAreaBottom: true,
        child: PopScope(
          onPopInvokedWithResult: bloc.fromForgotPass,
          child: ListView(
            children: [
              const SizedBox(height: Dimens.sizeLarge),
              const Text(
                StringRes.forgotPass,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontUltraLarge),
              ),
              const SizedBox(height: Dimens.sizeLarge),
              Text(
                StringRes.forgotPassDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              const SizedBox(height: Dimens.sizeLarge),
              MyTextField(
                fieldKey: bloc.forgotPassKey,
                title: 'Email',
                isEmail: true,
                controller: bloc.forgotPassContr,
              ),
              BlocListener<ForgotPassBloc, ForgotPassState>(
                listenWhen: (pr, cr) => pr.linkSent != cr.linkSent,
                listener: (context, state) {
                  if (!state.linkSent) return;
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        final scheme = context.scheme;

                        return MyAlertDialog(
                          title: StringRes.success,
                          content: Text(
                            StringRes.forgotPassOKDesc,
                            style: TextStyle(color: scheme.textColorLight),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.close(2),
                              child: const Text('OK'),
                            )
                          ],
                        );
                      });
                },
                child: SizedBox(height: context.height * 0.05),
              ),
              BlocBuilder<ForgotPassBloc, ForgotPassState>(
                  buildWhen: (pr, cr) => pr.loading != cr.loading,
                  builder: (context, state) {
                    return LoadingButton(
                        isLoading: state.loading,
                        onPressed: () => bloc.add(ForgotPassLinkSend()),
                        child: const Text(StringRes.submit));
                  }),
              const SizedBox(height: Dimens.sizeLarge),
            ],
          ),
        ));
  }
}
