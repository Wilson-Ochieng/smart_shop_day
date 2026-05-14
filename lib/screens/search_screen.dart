// search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/providers/wishlist_provider.dart';
import 'package:smartshop/screens/productWidget.dart';

class SearchScreen extends StatefulWidget {
  static const routName = "/SearchScreen";

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";
  bool _isSearching = false;

  List<String> get _categories {
    final provider = Provider.of<ProductProvider>(context);
    return ["All", ...provider.categories];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty && !provider.isLoading) {
        provider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final provider = context.read<ProductProvider>();
    
    // Start with all products
    List<ProductModel> products = provider.products;

    // Filter by search query using provider's searchProducts method
    if (_searchQuery.isNotEmpty) {
      products = provider.searchProducts(searchText: _searchQuery);
    }

    // Filter by category using provider's findByCategory method
    if (_selectedCategory != "All") {
      products = provider.findByCategory(categoryName: _selectedCategory);
    }
    
    // If both filters are applied, we need to intersect the results
    if (_searchQuery.isNotEmpty && _selectedCategory != "All") {
      // First get search results, then filter by category
      final searchResults = provider.searchProducts(searchText: _searchQuery);
      products = searchResults.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Search Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Wishlist counter badge
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final wishlistCount = wishlistProvider.getWishlists.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Navigate to wishlist screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wishlist screen coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$wishlistCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _isSearching = value.isNotEmpty || _selectedCategory != "All";
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, category or description...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              // Category Filter Chips with category counts
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.products.isEmpty) return const SizedBox.shrink();
                  
                  // Get category counts for display
                  final categoryCounts = provider.categoryCount;
                  
                  return Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        
                        // Display count for categories (except "All")
                        final count = category == "All" 
                            ? provider.products.length 
                            : (categoryCounts[category] ?? 0);
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('$category ($count)'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _isSearching = true;
                                if (_searchQuery.isEmpty && category == "All") {
                                  _isSearching = false;
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // Optional: Show active filters summary
              if (_searchQuery.isNotEmpty || _selectedCategory != "All")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Active filters: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Search: "$_searchQuery"',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                          ),
                        ),
                      if (_searchQuery.isNotEmpty && _selectedCategory != "All")
                        const SizedBox(width: 4),
                      if (_selectedCategory != "All")
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Category: $_selectedCategory',
                            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Show loading shimmer
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildShimmerLoading();
          }

          // No products in database
          if (provider.products.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inventory_2,
              message: "No products available",
              subMessage: "Check back later for new products",
            );
          }

          final filteredProducts = _filteredProducts;
          
          // Show empty state for no results
          if (filteredProducts.isEmpty) {
            String message = "No products found";
            String subMessage = "Try adjusting your search or category filter";
            
            if (_searchQuery.isNotEmpty && _selectedCategory != "All") {
              message = "No matching products";
              subMessage = "No products match \"$_searchQuery\" in $_selectedCategory";
            } else if (_searchQuery.isNotEmpty) {
              message = "No results for \"$_searchQuery\"";
              subMessage = "Try searching with different keywords";
            } else if (_selectedCategory != "All") {
              message = "No products in $_selectedCategory";
              subMessage = "Try selecting a different category";
            }
            
            return _buildEmptyState(
              icon: Icons.search_off,
              message: message,
              subMessage: subMessage,
            );
          }

          // Show search results as list
          return _buildSearchResults(filteredProducts);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 16,
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        height: 14,
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProductWidget(
            product: product,
            isCompact: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != "All") ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                  _selectedCategory = "All";
                  _isSearching = false;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
          // Show category suggestions when no search results
          if (_searchQuery.isNotEmpty && _selectedCategory == "All")
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  Text(
                    'Try these categories:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories
                        .where((c) => c != "All")
                        .take(4)
                        .map((category) {
                      return ActionChip(
                        label: Text(category),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                            _isSearching = true;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}