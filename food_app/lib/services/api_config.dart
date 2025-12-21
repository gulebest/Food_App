class ApiConfig {
  // ===============================
  // PRODUCTION BASE URL (RENDER)
  // ===============================
  static const String baseUrl = "https://foodapp-backend-796q.onrender.com/api";

  // AUTH
  static String get register => "$baseUrl/auth/register";
  static String get login => "$baseUrl/auth/login";
  static String get me => "$baseUrl/auth/me";

  // PRODUCTS
  static String get products => "$baseUrl/products";

  // CART
  static String get cart => "$baseUrl/cart";

  // ORDERS
  static String get orders => "$baseUrl/orders";
}
