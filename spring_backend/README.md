UMAT Spring Boot Backend (Scaffold)
==================================

Contents:
- Basic Spring Boot + JPA project with entities for User, Product, CartItem, Order, OrderItem.
- Auth endpoints: /api/auth/signup and /api/auth/login (returns JWT token)
- Product endpoints: /api/products (GET/POST/PUT/DELETE)
- Cart endpoints: /api/cart (add/get/clear)
- Order endpoints: /api/orders (create/get)
- Payment endpoints: /api/payment/create-order and /api/payment/verify (Razorpay)

How to run:
1. Install JDK 17 and Maven.
2. Create a MySQL database named `umatdb` and update src/main/resources/application.properties with your DB credentials.
3. Build & run:
   mvn clean package
   java -jar target/umat-backend-0.0.1-SNAPSHOT.jar

Frontend integration notes:
- Auth: send POST to /api/auth/login or /api/auth/signup with JSON { email, password, name(optional) }.
  The response contains a JWT token. Send header `Authorization: Bearer <token>` on protected endpoints like /api/cart.
- Products: GET /api/products to list products. Products include `imagePath` which you should keep aligned with your frontend image paths.
- Cart: POST /api/cart/add with body { product: { id: <productId> }, quantity: <n> } and Authorization header.
- Order: POST /api/orders/create with an OrderEntity-like JSON:
  { items: [{ productId, title, price, quantity }], totalAmount: 123.45 }
- Payment: POST /api/payment/create-order with { amount: 123.45 } to get a Razorpay orderId.

Security:
- This scaffold includes a simple JWT util and a JwtFilter that places the user email into the request attribute `userEmail`.
- You will likely want to add full Spring Security configuration (authentication manager, password encoding bean injection) for production.
