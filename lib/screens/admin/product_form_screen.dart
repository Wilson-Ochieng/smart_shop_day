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
  String? _webImageUrl;
  XFile? _webImageFile; // Store the actual XFile for web
  bool _isLoading = false;
  bool _imageChanged = false;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Food',
    'Home',
    'Sports',
    'Other'
  ];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _debugPrint('ProductFormScreen initState - Edit mode: $_isEditMode');
    if (_isEditMode) {
      _debugPrint('Loading product: ${widget.product!.name}');
      _loadProductData();
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

  // Debug print helper
  void _debugPrint(String message) {
    if (kDebugMode) {
      print('[ProductForm] $message');
    }
  }

  // Load existing product data for edit mode
  void _loadProductData() {
    _nameController.text = widget.product!.name;
    _descController.text = widget.product!.description;
    _priceController.text = widget.product!.price.toString();
    _stockController.text = widget.product!.stock.toString();
    _selectedCategory = widget.product!.category;
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    _debugPrint('Picking image...');
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked != null) {
        _debugPrint('Image picked successfully');
        _debugPrint('Image path: ${picked.path}');
        
        setState(() {
          if (kIsWeb) {
            // For web, store the XFile and the URL for preview
            _webImageFile = picked;
            _webImageUrl = picked.path;
            _pickedImage = null;
            _debugPrint('Web image stored');
          } else {
            // For mobile, create File object
            _pickedImage = File(picked.path);
            _webImageUrl = null;
            _webImageFile = null;
            _debugPrint('Mobile image file: ${_pickedImage?.path}');
          }
          _imageChanged = true;
        });
      } else {
        _debugPrint('No image selected');
      }
    } catch (e) {
      _debugPrint('Error picking image: $e');
      _showSnackBar('Error picking image: $e');
    }
  }

  // Validate form inputs
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    
    if (!_isEditMode && _pickedImage == null && _webImageFile == null) {
      _showSnackBar('Please select a product image');
      return false;
    }
    
    return true;
  }

  // Get form data as map
  Map<String, dynamic> _getFormData() {
    return {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'category': _selectedCategory,
      'stock': int.parse(_stockController.text.trim()),
    };
  }

  // Handle add product
  // Handle add product
Future<void> _handleAddProduct() async {
  _debugPrint('Adding new product...');
  
  final formData = _getFormData();
  final provider = context.read<ProductProvider>();
  final userProvider = context.read<UserProvider>();
  String? error;

  if (kIsWeb) {
    // For web: use the XFile directly
    if (_webImageFile == null) {
      _showSnackBar('Please select a product image');
      return;
    }
    
    // Assign to a local non-nullable variable after null check
    final webImage = _webImageFile!;
    
    error = await provider.addProductWeb(
      name: formData['name'],
      description: formData['description'],
      price: formData['price'],
      category: formData['category'],
      stock: formData['stock'],
      imageFile: webImage, // Now this is XFile (non-nullable)
      createdBy: userProvider.getUser?.uid ?? '',
    );
  } else {
    // For mobile: use File
    if (_pickedImage == null) {
      _showSnackBar('Please select a product image');
      return;
    }
    
    error = await provider.addProduct(
      name: formData['name'],
      description: formData['description'],
      price: formData['price'],
      category: formData['category'],
      stock: formData['stock'],
      imageFile: _pickedImage!,
      createdBy: userProvider.getUser?.uid ?? '',
    );
  }

  if (!mounted) return;
  
  if (error != null) {
    _debugPrint('Error adding product: $error');
    _showSnackBar(error);
  } else {
    _debugPrint('Product added successfully');
    _showSnackBar('Product added successfully', isError: false);
    Navigator.pop(context, true);
  }
}
 // Handle update product
Future<void> _handleUpdateProduct() async {
  _debugPrint('Updating product: ${widget.product!.id}');
  
  final formData = _getFormData();
  final provider = context.read<ProductProvider>();
  String? error;

  if (kIsWeb && _imageChanged) {
    // For web update with new image
    if (_webImageFile == null) {
      _showSnackBar('Please select a product image');
      return;
    }
    
    // Assign to a local non-nullable variable after null check
    final webImage = _webImageFile!;
    
    error = await provider.updateProductWeb(
      productId: widget.product!.id,
      name: formData['name'],
      description: formData['description'],
      price: formData['price'],
      category: formData['category'],
      stock: formData['stock'],
      newImageFile: webImage, 
      existingImageUrl: widget.product!.imageUrl,
    );
  } else {
    // For mobile or web without image change
    error = await provider.updateProduct(
      productId: widget.product!.id,
      name: formData['name'],
      description: formData['description'],
      price: formData['price'],
      category: formData['category'],
      stock: formData['stock'],
      newImageFile: _imageChanged ? _pickedImage : null,
      existingImageUrl: widget.product!.imageUrl,
    );
  }

  if (!mounted) return;
  
  if (error != null) {
    _debugPrint('Error updating product: $error');
    _showSnackBar(error);
  } else {
    _debugPrint('Product updated successfully');
    _showSnackBar('Product updated successfully', isError: false);
    Navigator.pop(context, true);
  }
}

  // Submit form (decides between add or update)
  Future<void> _submit() async {
    if (!_validateForm()) return;

    _debugPrint('Submitting form...');
    _debugPrint('Is edit mode: $_isEditMode');
    _debugPrint('Is web: $kIsWeb');
    _debugPrint('Has mobile image: ${_pickedImage != null}');
    _debugPrint('Has web image: ${_webImageFile != null}');
    
    setState(() => _isLoading = true);

    if (_isEditMode) {
      await _handleUpdateProduct();
    } else {
      await _handleAddProduct();
    }

    setState(() => _isLoading = false);
  }

  // Show snackbar message
  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _debugPrint('Building ProductFormScreen - Edit mode: $_isEditMode');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildNameField(),
              _buildDescriptionField(),
              _buildPriceField(),
              _buildStockField(),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Image picker widget
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
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
    );
  }

  // Image preview builder
  Widget _buildImagePreview() {
    // Show newly picked image (mobile)
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _pickedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    // Show web image preview
    if (_webImageUrl != null && kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _webImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    // Show existing image in edit mode
    if (_isEditMode && !_imageChanged) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.product!.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error, size: 48),
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
        Text(
          'Tap to select image',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Form field builders
  Widget _buildNameField() {
    return _buildField(
      _nameController,
      'Product Name',
      'Enter product name',
    );
  }

  Widget _buildDescriptionField() {
    return _buildField(
      _descController,
      'Description',
      'Enter description',
      maxLines: 3,
    );
  }

  Widget _buildPriceField() {
    return _buildField(
      _priceController,
      'Price',
      'Enter price',
      keyboardType: TextInputType.number,
      prefixText: '\$',
    );
  }

  Widget _buildStockField() {
    return _buildField(
      _stockController,
      'Stock Quantity',
      'Enter quantity',
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isEditMode ? 'Update Product' : 'Add Product',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // Reusable form field
  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
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
          prefixText: prefixText,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          enabled: !_isLoading,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (keyboardType == TextInputType.number) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (label == 'Price' && double.parse(value) <= 0) {
              return 'Price must be greater than 0';
            }
            if (label == 'Stock Quantity' && int.parse(value) < 0) {
              return 'Stock cannot be negative';
            }
          }
          return null;
        },
      ),
    );
  }
}