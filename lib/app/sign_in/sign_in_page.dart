import 'package:firebase_auth_demo_flutter/app/developer_menu.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/email_password_sign_in_page.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/sign_in_bloc.dart';
import 'package:firebase_auth_demo_flutter/app/sign_in/social_sign_in_button.dart';
import 'package:firebase_auth_demo_flutter/common_widgets/platform_exception_alert_dialog.dart';
import 'package:firebase_auth_demo_flutter/constants/strings.dart';
import 'package:firebase_auth_demo_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage._({Key key, this.bloc, this.title}) : super(key: key);
  final SignInBloc bloc;
  final String title;

  static Widget create(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    final SignInBloc signInBloc = SignInBloc(auth: auth);
    return Provider<SignInBloc>(
      builder: (BuildContext context) => signInBloc,
      dispose: (BuildContext context, SignInBloc bloc) => bloc.dispose(),
      child: SignInPage._(
        bloc: signInBloc,
        title: 'Firebase Auth Demo',
      ),
    );
  }

  Future<void> _showSignInError(BuildContext context, PlatformException exception) async {
    await PlatformExceptionAlertDialog(
      title: Strings.signInFailed,
      exception: exception,
    ).show(context);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await bloc.signInAnonymously();
    } on PlatformException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await bloc.signInWithFacebook();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e);
      }
    }
  }

  Future<void> _signInWithEmail(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => EmailPasswordSignInPage.create(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: bloc.isLoadingStream,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool isLoading = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            elevation: 2.0,
            title: Text(title),
          ),
          // Hide developer menu while loading in progress.
          // This is so that it's not possible to switch auth service while a request is in progress
          drawer: isLoading ? null : DeveloperMenu(),
          backgroundColor: Colors.grey[200],
          body: _buildSignIn(context, isLoading),
        );
      },
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSignIn(BuildContext context, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(isLoading),
          ),
          SizedBox(height: 48.0),
          SocialSignInButton(
            assetName: 'assets/go-logo.png',
            text: Strings.signInWithGoogle,
            onPressed: isLoading ? null : () => _signInWithGoogle(context),
            color: Colors.white,
          ),
          SizedBox(height: 8),
          SocialSignInButton(
            assetName: 'assets/fb-logo.png',
            text: Strings.signInWithFacebook,
            textColor: Colors.white,
            onPressed: isLoading ? null : () => _signInWithFacebook(context),
            color: Color(0xFF334D92),
          ),
          SizedBox(height: 8),
          SignInButton(
            text: Strings.signInWithEmail,
            onPressed: isLoading ? null : () => _signInWithEmail(context),
            textColor: Colors.white,
            color: Colors.teal[700],
          ),
          SizedBox(height: 8),
          Text(
            Strings.or,
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          SignInButton(
            text: Strings.goAnonymous,
            color: Colors.lime[300],
            textColor: Colors.black,
            onPressed: isLoading ? null : () => _signInAnonymously(context),
          ),
        ],
      ),
    );
  }
}
