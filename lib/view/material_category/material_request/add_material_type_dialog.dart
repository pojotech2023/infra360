import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/utils/file_picker_helper.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

/// Shows the "Add Material Type" dialog (matches screenshot 3)
Future<bool> showAddMaterialTypeDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _AddMaterialTypeDialog(),
  ) ?? false;
}

class _AddMaterialTypeDialog extends StatefulWidget {
  const _AddMaterialTypeDialog();

  @override
  State<_AddMaterialTypeDialog> createState() => _AddMaterialTypeDialogState();
}

class _AddMaterialTypeDialogState extends State<_AddMaterialTypeDialog> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await FilePickerHelper.pickImage();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    print("🔍 [AddMaterialTypeDialog] Saving: name=${_nameController.text.trim()}  hasImage=${_selectedImage != null}");

    try {
      final res = await ApiData().addMaterialTypeApi(
        _nameController.text.trim(),
        _selectedImage,
      );

      print("📥 [AddMaterialTypeDialog] Response: status=${res?.status}  message=${res?.message}");

      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Material type added successfully");
        if (mounted) Navigator.of(context).pop(true);
      } else {
        showToastMessage(res?.message ?? "Failed to add material type");
      }
    } catch (e) {
      print("❌ [AddMaterialTypeDialog] Exception: $e");
      showToastMessage("Error adding material type");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Material Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252C58)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Material Name
                  const Text("Material Name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "e.g. Waterproofing",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Material name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Image picker
                  const Text("Image", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          // "Choose File" button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFCCCCCC)),
                            ),
                            child: const Text("Choose File", style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImage != null
                                  ? _selectedImage!.path.split('/').last.split('\\').last
                                  : "No file chosen",
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedImage != null ? Colors.black87 : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Preview image if selected
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        _selectedImage!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B4FBF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Save", style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4B4FBF),
                          side: const BorderSide(color: Color(0xFF4B4FBF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text("Cancel", style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
