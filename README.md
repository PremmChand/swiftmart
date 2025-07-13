# 🛍️ SwiftMart – Smart Shopping, Simplified

**SwiftMart** is a full-featured **e-commerce Flutter application** designed with a clean, scalable architecture. It supports **role-based login for Admin and Users**, real-time data syncing via Firebase, and secure payments with Razorpay. Whether you're an admin managing products or a user browsing and buying items, SwiftMart offers a seamless experience with persistent cart, order tracking, and payment history.

---

##  Features at a Glance

###  Role-Based Authentication
- Admin and User have separate login flows and dashboards
- Firebase Authentication with persistent sessions

###  Admin Panel
-  Add/Delete/Filter Products
-  View all orders from users in real-time
-  Upload product images (Cloudinary or Firebase Storage)
-  Monitor product availability and inventory

###  User Functionality
- Browse categories & detailed product pages
-  Mark products as favorites
-  Add to cart with quantity, size, and color selection
- Place orders with instant confirmation
- View order history and current status

###  Secure Payments
-  Razorpay payment gateway integration
- Load wallet balance (optional)
-  View payment summaries after checkout
-  Multiple payment options supported: **PayPal**, **MasterCard**, UPI, and Cards

### Smart Backend with Firebase
- Firestore stores all users, products, carts, orders
- Data persists across sessions
- Real-time listeners update UI instantly

###  Tech Stack & Tools
-  Flutter & Dart
-  Firebase (Auth, Firestore, Storage)
-  Cloudinary (optional) for product image hosting
-  Razorpay API for secure payments
-  Riverpod for state management
-  CachedNetworkImage for performance-optimized UI
- Material Design & responsive layout

---

## Screenshots

> ## Screenshots

### 1. User Flow 
![login.png](screenshots/login.png) | ![register.png](screenshots/register.png) |
| 
### 2. Admin & Product Management Screenshots
| ![admin_add_product.png](screenshots/admin_add_product.png) | ![admin_display_order.png](screenshots/admin_display_order.png) |


### 3. User  & Product Management Screenshots
| ![user_home.png](screenshots/user_home.png) | ![user_home_1.png](screenshots/user_home_1.png) | ![user_info.png](screenshots/user_info.png) | | ![favorite_product.png](screenshots/favorite_product.png) 
|---|---|---|---|
 
| User Home | User Home (Alt) | User Info | | Favorite Product


### 4. Product details & Payment Type Screenshots
| ![product_category.png](screenshots/product_category.png) | ![product_detail.png](screenshots/product_detail.png) | ![payment_type.png](screenshots/payment_type.png) | | ![product_cart.png](screenshots/product_cart.png)
|---|---|---|---|
 | Product Category | Product Detail |  Payment Type |  Product Cart |


### 5. Payment details Screenshots
| ![add_fund.png](screenshots/add_fund.png) | ![add_payment_method.png](screenshots/add_payment_method.png) | ![add_payment_method_1.png](screenshots/add_payment_method_1.png) | ![payment_method.png](screenshots/payment_method.png) | ![payment_process.png](screenshots/payment_process.png)
|---|---|---|---|
| Add Fund | Add Payment Method | Add Payment Method (Alt) | Payment Method |

|  | ![payment_process_1.png](screenshots/payment_process_1.png) | ![payment.png](screenshots/payment.png) | ![payment_success.png](screenshots/payment_success.png) | ![order_success.png](screenshots/order_success.png)
|---|---|---|---|
| Payment Process | Payment Process (Alt) | Payment Success |

### 5. Order details Screenshots

| ![product_order.png](screenshots/product_order.png) | [order.png](screenshots/order.png)   
| ![order_details.png](screenshots/order_details.png) | ![order_detail.png](screenshots/order_detail.png) |

|---|---|---|---|
| Order Screen | Product Order | Order Details |




1. **Clone the repository**  
   ```bash
   git clone https://github.com/PremmChand/swiftmart.git
   cd swiftmart


👤 Developed by Premm Chand


💡 This project is a personal initiative to learn and showcase real-world Flutter, Firebase, and e-commerce integrations. 

⭐ If you found this project helpful or inspiring, don’t forget to Star it on GitHub!