import 'dart:io';
import 'package:ecommerce/database/CartDatabaseHelper.dart';
import 'package:ecommerce/models/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductsItems? product;

  const ProductDetailsScreen({required this.product, Key? key})
      : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int itemCount = 0;
  double totalPrice = 0.0;
  double productPrice = 0.0;

  @override
  void initState() {
    super.initState();
    productPrice = widget.product?.price ?? 0.0;
  }

  void _addToCart() async {
    List<CartProduct> cartProducts =
        await CartDatabaseHelper().getCartProducts();
    CartProduct existingProduct = cartProducts.firstWhere(
      (product) => product.productId == widget.product!.id,
      orElse: () => CartProduct(
        productId: -1,
        title: widget.product!.title,
        price: widget.product!.price,
        image: widget.product!.image,
      ),
    );

    if (existingProduct.productId == -1) {
      CartProduct cartProduct = CartProduct(
        productId: widget.product!.id,
        title: widget.product!.title,
        price: widget.product!.price,
        image: widget.product!.image,
        quantity: itemCount, // Use itemCount as the selected quantity
      );

      int result = await CartDatabaseHelper().insertCartProduct(cartProduct);

      if (result != 0) {
        print('Products added to cart successfully');
        setState(() {
          totalPrice += (widget.product!.price *
              itemCount); // Update total price based on itemCount
          itemCount = 0; // Reset itemCount after adding to cart
        });
      } else {
        print('Error adding product to cart');
      }
    } else {
      int newQuantity = existingProduct.quantity +
          itemCount; // Update quantity based on itemCount
      int result = await CartDatabaseHelper().updateCartProductQuantity(
        widget.product!.id,
        newQuantity,
      );

      if (result != 0) {
        print('Quantity of product in cart updated successfully');
        setState(() {
          totalPrice += (widget.product!.price *
              itemCount); // Update total price based on itemCount
          itemCount = 0; // Reset itemCount after adding to cart
        });
      } else {
        print('Error updating product quantity in cart');
      }
    }
  }

  void removeFromCart() {
    setState(() {
      if (itemCount > 0) {
        itemCount--;
        totalPrice -= productPrice;
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      itemCount++;
      totalPrice += productPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 116, 91, 241),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                File(widget.product!.image),
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.0),
              Text(
                widget.product?.title ?? 'N/A',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product?.description ?? 'N/A',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rating: ${widget.product?.ranking ?? 0}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 8.0),
                      RatingBar.builder(
                        initialRating:
                            widget.product?.ranking?.toDouble() ?? 0.0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          // Update logic for rating if needed
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                'Detalles',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoBox(
                      title: 'Calorias',
                      content: widget.product?.calories?.toString() ?? 'N/A'),
                  InfoBox(
                      title: 'Vitaminas',
                      content: widget.product?.vitamins?.toString() ?? 'N/A'),
                  InfoBox(
                      title: 'Aditivos',
                      content: widget.product?.additives?.toString() ?? 'N/A'),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: removeFromCart,
                      iconSize: 36,
                    ),
                    Text(
                      '$itemCount',
                      style: TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _incrementQuantity,
                      iconSize: 36,
                    ),
                    Column(
                      children: [
                        Text(
                          'Precio Total: \$$totalPrice',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: _addToCart,
                          child: Text('Agregar al Carrito'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const InfoBox({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          Text(
            content,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
