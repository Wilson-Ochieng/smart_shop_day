import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/providers/user_provider.dart';

class ProductFormScreen extends StatefulWidget {
  static const routName = '/ProductForm';
  final ProductModel? product; 

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Electronics';
  File? _pickedImage;
  String? _webImageUrl; // For web image preview
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics', 'Clothing', 'Food', 'Home', 'Sports', 'Other'
  ];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );
  
  if (picked != null) {
    setState(() {
      if (kIsWeb) {
        _webImageUrl = picked.path;
      } else {
        _pickedImage = File(picked.path);
      }
    });
  }
}

  // For web support - handle image selection differently
  Future<void> _pickImageWeb() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _webImageUrl = picked.path;
        _pickedImage = null; // Clear file when using web
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditMode && _pickedImage == null && _webImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ProductProvider>();
    final userProvider = context.read<UserProvider>();
    String? error;

    if (_isEditMode) {
      error = await provider.updateProduct(
        productId: widget.product!.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        stock: int.parse(_stockController.text.trim()),
        newImageFile: _pickedImage,
        existingImageUrl: widget.product!.imageUrl,
      );
    } else {
      error = await provider.addProduct(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        stock: int.parse(_stockController.text.trim()),
        imageFile: _pickedImage!,
        createdBy: userProvider.getUser?.uid ?? '',
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker - platform aware
              GestureDetector(
                onTap: () {
                  // Use appropriate picker based on platform
                  if (Theme.of(context).platform == TargetPlatform.iOS ||
                      Theme.of(context).platform == TargetPlatform.android) {
                    _pickImage();
                  } else {
                    _pickImageWeb();
                  }
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 20),

              _buildField(_nameController, 'Product Name', 'Enter product name'),
              _buildField(_descController, 'Description', 'Enter description',
                  maxLines: 3),
              _buildField(_priceController, 'Price', 'Enter price',
                  keyboardType: TextInputType.number),
              _buildField(_stockController, 'Stock Quantity', 'Enter quantity',
                  keyboardType: TextInputType.number),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditMode ? 'Update Product' : 'Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Platform-aware image preview builder
  Widget _buildImagePreview() {
    // Show picked image (mobile)
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_pickedImage!, fit: BoxFit.cover),
      );
    }
    
    // Show web image preview
    if (_webImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_webImageUrl!, fit: BoxFit.cover),
      );
    }
    
    // Show existing image in edit mode
    if (_isEditMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.product!.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error),
          ),
        ),
      );
    }
    
    // Default placeholder
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text('Tap to select image'),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? '$label is required' : null,
      ),
    );
  }
}