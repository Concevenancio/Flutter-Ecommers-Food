// cart_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ecommerce/database/CartDatabaseHelper.dart';
import 'package:ecommerce/models/products.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartProduct> cartProducts;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    cartProducts = [];
    _loadCartProducts();
  }

  void _loadCartProducts() async {
    List<CartProduct> products = await CartDatabaseHelper().getCartProducts();
    double total = 0.0;
    products.forEach((product) {
      total += product.price * product.quantity;
    });
    setState(() {
      cartProducts = products;
      totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  return _buildCartItem(cartProducts[index]);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Agrega la lógica para realizar la compra aquí
                      // Este botón "Buy Now" puede realizar una acción al ser presionado
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(
                          255, 0, 208, 255), // Cambia el color a naranja
                    ),
                    child: Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartProduct cartProduct) {
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.black,
      child: ListTile(
        leading: Image.file(
          File(cartProduct.image),
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        title: Text(
          cartProduct.title,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Price: \$${cartProduct.price.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                _updateQuantity(
                    cartProduct.productId, cartProduct.quantity - 1);
              },
              color: Colors.white,
            ),
            Text(
              cartProduct.quantity.toString(),
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _updateQuantity(
                    cartProduct.productId, cartProduct.quantity + 1);
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteProduct(cartProduct.productId);
              },
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(int productId, int newQuantity) async {
    if (newQuantity < 0) {
      // Evitar que la cantidad sea negativa
      return;
    }

    int result = await CartDatabaseHelper()
        .updateCartProductQuantity(productId, newQuantity);

    if (result != 0) {
      print('Cantidad del producto actualizada con éxito');
      _loadCartProducts();
    } else {
      print('Error al actualizar la cantidad del producto');
    }
  }

  void _deleteProduct(int productId) async {
    int result = await CartDatabaseHelper().deleteCartProduct(productId);

    if (result != 0) {
      print('Producto eliminado del carrito con éxito');
      _loadCartProducts();
    } else {
      print('Error al eliminar el producto del carrito');
    }
  }
}
