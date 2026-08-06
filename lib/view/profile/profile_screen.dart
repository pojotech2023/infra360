import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/profile/profile_controller.dart';

import '../../base_url.dart';
import '../../utils/app_text_style.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import '../widgets/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _attachment;

  // Password visibility toggles
  bool _newPasswordVisible      = false;
  bool _confirmPasswordVisible  = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Edit Profile',
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          builder: (ctrl) {
            if (ctrl.isLoading.value) {
              return const Center(child: CommonLoader());
            }
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Image ────────────────────────────────
                    Center(
                      child: InkWell(
                        onTap: () => _showAttachmentOptions(context),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.textFieldBorder, width: 2),
                            borderRadius: BorderRadius.circular(80),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Builder(builder: (_) {
                            final apiUrl = ctrl.profileImage.value;
                            if (_attachment != null) {
                              return Image.file(_attachment!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholder());
                            } else if (apiUrl.isNotEmpty) {
                              return Image.network('$imageUrl/$apiUrl',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null ? child : const Center(child: CircularProgressIndicator()),
                                  errorBuilder: (_, __, ___) => _placeholder());
                            }
                            return _placeholder();
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Tap to change photo',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),

                    VerticalSpacing.d20px(),
                    _sectionHeader('Profile Information'),
                    VerticalSpacing.d10px(),

                    // ── Name ─────────────────────────────────────────
                    Text('Name', style: AppTextStyle.textFieldHeadingStyle),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: ctrl.nameController,
                      decoration: textBoxDecoration(hint: 'Enter your name'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),

                    VerticalSpacing.d15px(),

                    // ── Mobile (read-only) ────────────────────────────
                    Text('Mobile Number', style: AppTextStyle.textFieldHeadingStyle),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: ctrl.mobileController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      decoration: textBoxDecoration(hint: 'Mobile number'),
                    ),

                    VerticalSpacing.d15px(),

                    // ── Email ─────────────────────────────────────────
                    Text('Email', style: AppTextStyle.textFieldHeadingStyle),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: ctrl.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textBoxDecoration(hint: 'Enter your email'),
                    ),

                    VerticalSpacing.d20px(),
                    _sectionHeader('Change Password'),
                    const Text(
                      'Leave blank if you do not want to change your password.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    VerticalSpacing.d10px(),

                    // ── New Password ──────────────────────────────────
                    Text('New Password', style: AppTextStyle.textFieldHeadingStyle),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: ctrl.newPasswordController,
                      obscureText: !_newPasswordVisible,
                      decoration: textBoxDecoration(
                        hint: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _newPasswordVisible = !_newPasswordVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    VerticalSpacing.d15px(),

                    // ── Confirm Password ──────────────────────────────
                    Text('Confirm Password', style: AppTextStyle.textFieldHeadingStyle),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: ctrl.confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: textBoxDecoration(
                        hint: 'Re-enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                              () => _confirmPasswordVisible = !_confirmPasswordVisible),
                        ),
                      ),
                      validator: (v) {
                        final newPw = ctrl.newPasswordController.text;
                        if (newPw.isNotEmpty) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (v != newPw) {
                            return 'Passwords do not match';
                          }
                        }
                        return null;
                      },
                    ),

                    VerticalSpacing.d30px(),

                    // ── Submit ────────────────────────────────────────
                    Obx(() => ctrl.isSaveLoading.value
                        ? const Center(child: CommonLoader())
                        : CommonButton(
                            text: 'Update Profile',
                            onTap: _onSubmit,
                          )),

                    VerticalSpacing.d20px(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Submit handler ─────────────────────────────────────────────────────────
  void _onSubmit() {
    // Run Flutter form validators (including password match check)
    if (!_formKey.currentState!.validate()) return;

    // Extra client-side password match guard (belt-and-suspenders)
    final newPw     = controller.newPasswordController.text;
    final confirmPw = controller.confirmPasswordController.text;
    if (newPw.isNotEmpty && newPw != confirmPw) {
      showToastMessage('New Password and Confirm Password do not match');
      return;
    }

    // Proceed with API call
    controller.updateProfileApi(files: _attachment);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyle.textBold.copyWith(
              color: AppColor.textGreen,
              fontSize: 16,
            )),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            color: AppColor.textGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        VerticalSpacing.d10px(),
      ],
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
        VerticalSpacing.d5px(),
        const Text('Add Photo',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.image, color: Colors.teal),
            title: const Text('Pick from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final file = await FilePickerHelper.pickImage();
              if (file != null) setState(() => _attachment = file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.teal),
            title: const Text('Capture Photo'),
            onTap: () async {
              Navigator.pop(context);
              final file = await FilePickerHelper.pickImage(fromCamera: true);
              if (file != null) setState(() => _attachment = file);
            },
          ),
        ]),
      ),
    );
  }
}
