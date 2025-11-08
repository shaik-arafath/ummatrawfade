-- MySQL DDL for basic tables (run in your DB before starting or let JPA create tables)
USE rawfade;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255),
  name VARCHAR(255),
  role VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255),
  description TEXT,
  price DOUBLE,
  image_path VARCHAR(500),
  stock INT
);

-- Insert sample products
INSERT INTO products (id, title, description, price, image_path, stock) VALUES
(1, 'Men''s Fashion T Shirt', 'The Gildan Ultra Cotton T-shirt is made from a substantial 6.0oz pre sq.yd. fabric constructed from 100% cotton. This classic fit preshrunk jersey knit provides unmatched comfort with each wear. Featuring a taped neck and shoulder, and a seamless double-needle collar, and available in a range of colors, it offers it all in the ultimate head-turning package.', 139.00, 'img/products/c1-1.png', 100),
(2, 'Calico T-shirt', 'Comfortable and stylish calico t-shirt perfect for casual wear.', 78.00, 'img/products/c2-1.png', 50),
(3, 'Summer Dress', 'Elegant summer dress for all occasions.', 120.00, 'img/products/c3-1.png', 30),
(4, 'Casual Jeans', 'Durable and comfortable casual jeans.', 95.00, 'img/products/c4-1.png', 75),
(5, 'Formal Shirt', 'Professional formal shirt for office and events.', 85.00, 'img/products/c5-1.png', 40);

-- JPA will create the other tables (cart_items, orders, order_items) automatically if ddl-auto=update
