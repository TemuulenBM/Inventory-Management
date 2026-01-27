import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/product_categories.dart';
import 'package:retail_control_platform/core/services/image_service.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

/// Product Form Screen (Add/Edit)
/// Pattern-based design (consistency with Product Detail + Cart)
class ProductFormScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductFormScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _colorController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = ProductCategories.defaultCategory;
  bool _isSaving = false;

  // Зургийн state
  File? _selectedImage;
  String? _existingImageUrl;
  final ImageService _imageService = ImageService();

  // Категориудын жагсаалт (constants-аас)
  List<String> _categories = ProductCategories.values;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  /// Бараа засах үед бодит data ачаалах
  Future<void> _loadProductData() async {
    if (widget.productId == 'new') return;

    try {
      final product = await ref.read(
        productDetailProvider(widget.productId).future,
      );

      if (product != null && mounted) {
        setState(() {
          _nameController.text = product.name;
          _skuController.text = product.sku;
          _sellPriceController.text = product.sellPrice.toInt().toString();
          if (product.costPrice > 0) {
            _costPriceController.text = product.costPrice.toInt().toString();
          }
          _thresholdController.text =
              (product.lowStockThreshold ?? 10).toString();
          _existingImageUrl = product.imageUrl;

          // Category ачаалах
          if (product.category != null && product.category!.isNotEmpty) {
            _selectedCategory = product.category!;
            // Хэрэв custom category бол _categories list-д нэмэх
            if (!_categories.contains(product.category!)) {
              _categories = [..._categories, product.category!];
            }
          }
        });
      }
    } catch (e) {
      debugPrint('_loadProductData error: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _colorController.dispose();
    _sellPriceController.dispose();
    _costPriceController.dispose();
    _thresholdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _generateSku() {
    // Auto-generate SKU based on category + random
    final categoryPrefix = _selectedCategory.substring(0, 3).toUpperCase();
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    _skuController.text = '$categoryPrefix-${random.toString().padLeft(3, '0')}';
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final actions = ref.read(productActionsProvider.notifier);
      final isNew = widget.productId == 'new';
      bool success;

      if (isNew) {
        // Шинэ бараа нэмэх
        final productId = await actions.createProduct(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim(),
          unit: 'piece',
          sellPrice: double.tryParse(_sellPriceController.text) ?? 0,
          costPrice: _costPriceController.text.isNotEmpty
              ? double.tryParse(_costPriceController.text)
              : null,
          lowStockThreshold: int.tryParse(_thresholdController.text),
          category: _selectedCategory,
          imageFile: _selectedImage,
        );
        success = productId != null;
      } else {
        // Бараа засах
        success = await actions.updateProduct(
          widget.productId,
          name: _nameController.text.trim(),
          sku: _skuController.text.trim(),
          sellPrice: double.tryParse(_sellPriceController.text),
          costPrice: _costPriceController.text.isNotEmpty
              ? double.tryParse(_costPriceController.text)
              : null,
          lowStockThreshold: int.tryParse(_thresholdController.text),
          category: _selectedCategory,
          imageFile: _selectedImage,
        );
      }

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNew ? 'Бараа амжилттай нэмэгдлээ' : 'Бараа амжилттай засагдлаа',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
        context.pop();
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Бараа хадгалахад алдаа гарлаа',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Алдаа гарлаа: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewProduct = widget.productId == 'new';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isNewProduct ? 'БАРАА НЭМЭХ' : 'БАРАА ЗАСАХ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isNewProduct)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFDC2626),
              ),
              onPressed: () {
                // Show delete confirmation dialog
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Барааны зураг
                    _buildImagePicker(),
                    AppSpacing.verticalLG,

                    // Category selector
                    const Text(
                      'Ангилал',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategorySelector(),
                    AppSpacing.verticalLG,

                    // Product name
                    _buildTextField(
                      label: 'Барааны нэр',
                      controller: _nameController,
                      hint: 'жнь: Cashmere Scarf',
                      required: true,
                      icon: Icons.inventory_2_outlined,
                    ),
                    AppSpacing.verticalMD,

                    // Color/Variant
                    _buildTextField(
                      label: 'Өнгө / Variant',
                      controller: _colorController,
                      hint: 'жнь: Шаргал, M size',
                      icon: Icons.palette_outlined,
                    ),
                    AppSpacing.verticalMD,

                    // SKU
                    _buildTextField(
                      label: 'SKU код',
                      controller: _skuController,
                      hint: 'жнь: CSH-001-BGE',
                      required: true,
                      icon: Icons.qr_code_2,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.auto_fix_high,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: _generateSku,
                        tooltip: 'Автоматаар үүсгэх',
                      ),
                    ),
                    AppSpacing.verticalLG,

                    // Price section
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Зарах үнэ',
                            controller: _sellPriceController,
                            hint: '0',
                            required: true,
                            icon: Icons.monetization_on_outlined,
                            keyboardType: TextInputType.number,
                            suffix: '₮',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Орлогын үнэ',
                            controller: _costPriceController,
                            hint: '0',
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            suffix: '₮',
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalMD,

                    // Threshold
                    _buildTextField(
                      label: 'Бага үлдэгдлийн босго',
                      controller: _thresholdController,
                      hint: '10',
                      required: true,
                      icon: Icons.notifications_outlined,
                      keyboardType: TextInputType.number,
                      helperText:
                          'Үлдэгдэл энэ тооноос бага болбол сануулга харагдана',
                    ),
                    AppSpacing.verticalMD,

                    // Location
                    _buildTextField(
                      label: 'Агуулах / Байршил',
                      controller: _locationController,
                      hint: 'жнь: Төв дэлгүүр',
                      icon: Icons.store_outlined,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            _buildBottomActions(isNewProduct),
          ],
        ),
      ),
    );
  }

  /// Зураг сонгох widget
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.image_outlined, size: 16, color: AppColors.gray500),
            SizedBox(width: 6),
            Text(
              'Барааны зураг',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Зураг харуулах / сонгох хэсэг
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(
                color: AppColors.gray200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildImageContent(),
          ),
        ),

        // Зураг устгах товч
        if (_selectedImage != null || _existingImageUrl != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
              label: const Text(
                'Зураг устгах',
                style: TextStyle(color: Color(0xFFDC2626), fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Зургийн content (preview эсвэл placeholder)
  Widget _buildImageContent() {
    // Шинэ сонгосон зураг байвал
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: AppRadius.radiusLG,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Хуучин зураг байвал (edit mode)
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radiusLG,
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    // Placeholder
    return _buildPlaceholder();
  }

  /// Зураг байхгүй үеийн placeholder
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 48,
          color: AppColors.gray400,
        ),
        const SizedBox(height: 12),
        Text(
          'Зураг нэмэх',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Камер эсвэл галерейгаас сонгох',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.gray400,
          ),
        ),
      ],
    );
  }

  /// Зураг сонгох dialog харуулах
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Камераар авах
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text(
                  'Камераар авах',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Шинэ зураг авах'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              // Галерейгаас сонгох
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text(
                  'Галерейгаас сонгох',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Байгаа зургаас сонгох'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Зураг сонгох
  Future<void> _pickImage(ImageSource source) async {
    final file = await _imageService.pickImage(source: source);

    if (file != null) {
      setState(() {
        _selectedImage = file;
        _existingImageUrl = null; // Хуучин URL-г цэвэрлэх
      });
    }
  }

  /// Зураг устгах
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return Material(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.radiusLG,
          elevation: 0,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            borderRadius: AppRadius.radiusLG,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.gray200,
                  width: 1.5,
                ),
                borderRadius: AppRadius.radiusLG,
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.gray600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool required = false,
    IconData? icon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? suffix,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusMD,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray400,
              ),
              suffixIcon: suffixIcon,
              suffixText: suffix,
              suffixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return '$label заавал бөглөнө үү';
              }
              return null;
            },
            inputFormatters: keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions(bool isNewProduct) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppColors.gray300,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLG,
                  ),
                ),
                child: const Text(
                  'Цуцлах',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Save button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00878F),
                  disabledBackgroundColor: AppColors.gray300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLG,
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.check,
                        size: 20,
                        color: Colors.white,
                      ),
                label: Text(
                  _isSaving
                      ? 'Хадгалж байна...'
                      : (isNewProduct ? 'Бараа нэмэх' : 'Хадгалах'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
