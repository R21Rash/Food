import 'package:flutter/material.dart';

class CustomerItemScreen extends StatefulWidget {
  final String title;
  final String image;

  const CustomerItemScreen({Key? key, required this.title, required this.image})
    : super(key: key);

  @override
  _CustomerItemScreenState createState() => _CustomerItemScreenState();
}

class _CustomerItemScreenState extends State<CustomerItemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 🛒 **Cart Items List**
  List<Map<String, dynamic>> cartItems = [];

  /// ✅ **Mock Data for Categories**
  final List<Map<String, String>> categories = [
    {"title": "Pizza", "image": "assets/images/pizza.jpg"},
    {"title": "Burger", "image": "assets/images/burger.jpg"},
    {"title": "Sandwich", "image": "assets/images/sandwich.jpg"},
  ];

  /// 🛒 **Function to Add Item to Cart**
  void addToCart() {
    setState(() {
      cartItems.add({
        "title": widget.title,
        "image": widget.image,
        "price": "1500.00",
        "quantity": 1,
      });
    });

    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.title} added to cart!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,

        actions: [
          /// ✅ **Cart Icon with Drawer Trigger**
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                ),
                onPressed:
                    () =>
                        _scaffoldKey.currentState
                            ?.openEndDrawer(), // Open drawer
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      cartItems.length.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      /// ✅ **Cart Drawer**
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF1C1C2B), // Dark Background
        child: Column(
          children: [
            /// ✅ **Cart Header**
            ///   isScrollControlled: true, // Allows full-screen height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cart",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Close drawer
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            /// ✅ **Cart Items List**
            Expanded(
              child:
                  cartItems.isEmpty
                      ? const Center(
                        child: Text(
                          "Your cart is empty 🛒",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                /// 🖼 **Product Image**
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    item["image"],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 15),

                                /// 📄 **Product Details**
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "\$${item["price"]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        '14"', // Fixed size for now
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ➖ **Quantity Controls**
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (item["quantity"] > 1) {
                                            item["quantity"]--;
                                          } else {
                                            cartItems.removeAt(index);
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      "${item["quantity"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          item["quantity"]++;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                /// ❌ **Remove Button**
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      cartItems.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            /// ✅ **Delivery Address**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "DELIVERY ADDRESS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "EDIT",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "2118 Thornridge Cir. Syracuse",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ **Total Price Section**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ **Place Order Button**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Add order logic here
                },
                child: const Center(
                  child: Text(
                    "PLACE ORDER",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // Allows smooth scrolling
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ **Image Section**
              /// ✅ **Image Section**
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Ensures image follows border radius
                  child: Image.asset(
                    widget.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// ✅ **Restaurant Name & Favorite Icon**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Chip(
                    backgroundColor: Colors.white,
                    label: Text("Uttora Caffe House"),
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  const Chip(
                    backgroundColor: Color.fromARGB(255, 5, 216, 40),
                    label: Text("Open Now"),
                    labelStyle: TextStyle(color: Colors.white),
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// ✅ **Title**
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),

              /// ✅ **Description**
              const Text(
                "Prosciutto e funghi is a pizza variety that is topped with tomato sauce.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              /// ✅ **Ratings, Delivery & Time**
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const Text(
                    " 4.7",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const Text(" Free", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, color: Colors.orange, size: 18),
                  const Text(" 20 min", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.price_change_sharp,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const Text(
                    " 1500.00",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              /// ✅ **Pizza Size Options**
              const Text(
                "SIZE:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _sizeOption("10\""),
                  _sizeOption("14\"", selected: true),
                  _sizeOption("16\""),
                ],
              ),
              const SizedBox(height: 15),

              /// ✅ **Ingredients**
              const Text(
                "INGREDIENTS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ingredientIcon(Icons.local_pizza),
                  _ingredientIcon(Icons.rice_bowl),
                  _ingredientIcon(Icons.local_dining),
                  _ingredientIcon(Icons.fastfood),
                ],
              ),
              const SizedBox(height: 20),

              /// ✅ **Categories Section**
              _sectionTitle("All Categories"),
              SizedBox(
                height: 130, // Increased to make space for bigger images
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _categoryCard(categories[index], context);
                  },
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Primary Color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: addToCart,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Reusable Section Title**
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "See All >",
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Reusable Category Card**
  Widget _categoryCard(Map<String, String> category, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CustomerItemScreen(
                  title: category["title"]!,
                  image: category["image"]!,
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  category["image"]!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover, // ✅ Cover the card fully
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category["title"]!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Reusable Widget for Pizza Size Option**
  Widget _sizeOption(String size, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(
          size,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: selected ? Colors.orange : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? Colors.orange : Colors.grey),
        ),
      ),
    );
  }

  /// ✅ **Reusable Widget for Ingredient Icons**
  Widget _ingredientIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        backgroundColor: Colors.orange[100],
        radius: 20,
        child: Icon(icon, color: Colors.orange, size: 20),
      ),
    );
  }
}
