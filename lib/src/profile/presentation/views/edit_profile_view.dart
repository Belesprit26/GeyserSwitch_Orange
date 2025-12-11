import 'dart:convert';

import 'package:gs_orange/core/common/widgets/nested_back_button.dart';
import 'package:gs_orange/core/enums/update_user.dart';
import 'package:gs_orange/core/extensions/context_extension.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:gs_orange/src/auth/presentation/bloc/auth_bloc.dart';
import 'package:gs_orange/src/home/presentation/widgets/asset_image_widget.dart';
import 'package:gs_orange/src/profile/presentation/widgets/edit_profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final oldPasswordController = TextEditingController();

  bool get nameChanged =>
      context.currentUser?.fullName.trim() != fullNameController.text.trim();

  bool get emailChanged => emailController.text.trim().isNotEmpty;

  bool get passwordChanged => passwordController.text.trim().isNotEmpty;

  bool get bioChanged =>
      context.currentUser?.bio?.trim() != bioController.text.trim();

  bool get nothingChanged =>
      !nameChanged && !emailChanged && !passwordChanged && !bioChanged;

  @override
  void initState() {
    fullNameController.text = context.currentUser!.fullName.trim();
    bioController.text = context.currentUser!.bio?.trim() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserUpdated) {
          CoreUtils.showSnackBar(context, 'Profile updated Successfully');
          context.pop();
        } else if (state is AuthError) {
          CoreUtils.showSnackBar(context, state.message);
        } else if (state is UserDeleted) {
          CoreUtils.showSnackBar(context, 'Account and Data successfully deleted');
          Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(forceMaterialTransparency: true,
              leading: const NestedBackButton(),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (nothingChanged) context.pop();
                    final bloc = context.read<AuthBloc>();
                    if (passwordChanged) {
                      if (oldPasswordController.text.isEmpty) {
                        CoreUtils.showSnackBar(
                          context,
                          'Please enter your old password',
                        );
                        return;
                      }
                      bloc.add(
                        UpdateUserEvent(
                          action: UpdateUserAction.password,
                          userData: jsonEncode({
                            'oldPassword': oldPasswordController.text.trim(),
                            'newPassword': passwordController.text.trim(),
                          }),
                        ),
                      );
                    }
                    if (nameChanged) {
                      bloc.add(
                        UpdateUserEvent(
                          action: UpdateUserAction.displayName,
                          userData: fullNameController.text.trim(),
                        ),
                      );
                    }
                    if (emailChanged) {
                      bloc.add(
                        UpdateUserEvent(
                          action: UpdateUserAction.email,
                          userData: emailController.text.trim(),
                        ),
                      );
                    }
                    if (bioChanged) {
                      bloc.add(
                        UpdateUserEvent(
                          action: UpdateUserAction.bio,
                          userData: bioController.text.trim(),
                        ),
                      );
                    }
                  },
                  child: state is AuthLoading
                      ? const Center(child: CircularProgressIndicator())
                      : StatefulBuilder(
                    builder: (_, refresh) {
                      fullNameController.addListener(() => refresh(() {}));
                      bioController.addListener(() => refresh(() {}));
                      emailController.addListener(() => refresh(() {}));
                      passwordController.addListener(() => refresh(() {}));
                      return Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: nothingChanged
                              ? Colors.grey
                              : Colors.blueAccent,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Static Profile Image
                ClipOval(
                  child: Container(
                    width: 129,
                    height: 129,
                    color: Colors.transparent,
                    child: AssetImageWidget(
                      imagePath: 'assets/images/GS_EC2.png',
                      width: 129,
                      height: 129,
                      fit: BoxFit.contain,
                      key: const ValueKey('AssetImage'),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                EditProfileForm(
                  fullNameController: fullNameController,
                  bioController: bioController,
                  emailController: emailController,
                  passwordController: passwordController,
                  oldPasswordController: oldPasswordController,
                ),
                const SizedBox(height: 30),
                Baseline(
                  baseline: 20,
                  baselineType: TextBaseline.alphabetic,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text("Delete Account"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Enter your password to confirm permanent data & account deletion."),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: oldPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  final bloc = context.read<AuthBloc>();

                                  if (oldPasswordController.text.isEmpty) {
                                    CoreUtils.showSnackBar(context, "Please enter your password");
                                    return;
                                  }

                                  bloc.add(DeleteUserEvent(oldPasswordController.text.trim()));
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Delete account?',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}