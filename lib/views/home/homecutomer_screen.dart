import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/item/customerItem_screen.dart';

class HomeCustomerScreen extends StatelessWidget {
  /// ✅ **Mock Data for Categories**
  final List<Map<String, String>> categories = [
    {"title": "Pizza", "image": "assets/images/pizza.jpg"},
    {"title": "Burger", "image": "assets/images/burger.jpg"},
    {"title": "Sandwich", "image": "assets/images/sandwich.jpg"},
    {"title": "Pizza", "image": "assets/images/pizza.jpg"},
    {"title": "Burger", "image": "assets/images/burger.jpg"},
    {"title": "Sandwich", "image": "assets/images/sandwich.jpg"},
  ];

  /// ✅ **Mock Data for Open Restaurants**
  final List<Map<String, dynamic>> restaurants = [
    {
      "name": "Rose Garden Restaurant",
      "description": "Burger - Chicken - Riche - Wings",
      "image": "assets/images/resturent1.jpg",
      "rating": 4.7,
      "delivery": "Free",
      "time": "20 min",
    },
    {
      "name": "Urban Spice",
      "description": "Pizza - Pasta - Salads",
      "image": "assets/images/resturent2.jpg",
      "rating": 4.5,
      "delivery": "\$2",
      "time": "30 min",
    },
    {
      "name": "Rose Garden Restaurant",
      "description": "Burger - Chicken - Riche - Wings",
      "image": "assets/images/resturent1.jpg",
      "rating": 4.7,
      "delivery": "Free",
      "time": "20 min",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "2",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ **Delivery Section**
              const Text(
                "DELIVER TO",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Halal Lab office",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                ],
              ),

              const SizedBox(height: 15),

              /// ✅ **Greeting Message**
              const Text(
                "Hey Halal, Good Afternoon!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              /// ✅ **Search Bar**
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Search dishes, restaurants",
                    border: InputBorder.none,
                  ),
                ),
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
                    return _categoryCard(
                      categories[index],
                      context,
                    ); // ✅ Pass context
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// ✅ **Open Restaurants Section**
              _sectionTitle("Open Restaurants"),
              Column(
                children:
                    restaurants.map((restaurant) {
                      return _restaurantCard(restaurant);
                    }).toList(),
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
  /// ✅ **Updated Category Card - Navigate to CustomerItemScreen**
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
              width: 100, // Keep the card size fixed
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
                borderRadius: BorderRadius.circular(
                  15,
                ), // Clip image inside card
                child: Image.asset(
                  category["image"]!,
                  width: 100, // Match container width
                  height: 100, // Match container height
                  fit:
                      BoxFit
                          .cover, // ✅ Cover entire container without whitespace
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

  /// ✅ **Reusable Restaurant Card**
  Widget _restaurantCard(Map<String, dynamic> restaurant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                restaurant["image"],
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    restaurant["description"],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(
                        " ${restaurant["rating"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.delivery_dining,
                        color: Colors.orange,
                        size: 18,
                      ),
                      Text(
                        " ${restaurant["delivery"]}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time,
                        color: Colors.orange,
                        size: 18,
                      ),
                      Text(
                        " ${restaurant["time"]}",
                        style: const TextStyle(fontSize: 14),
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
