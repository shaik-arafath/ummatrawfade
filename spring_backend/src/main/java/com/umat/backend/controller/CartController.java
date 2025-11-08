package com.umat.backend.controller;

import com.umat.backend.dto.AddToCartRequest;
import com.umat.backend.model.CartItem;
import com.umat.backend.model.Product;
import com.umat.backend.model.User;
import com.umat.backend.repository.CartItemRepository;
import com.umat.backend.repository.ProductRepository;
import com.umat.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/cart")
public class CartController {
    private final CartItemRepository cartRepo;
    private final UserRepository userRepo;
    private final ProductRepository productRepo;

    public CartController(CartItemRepository cartRepo, UserRepository userRepo, ProductRepository productRepo) {
        this.cartRepo = cartRepo; this.userRepo = userRepo; this.productRepo = productRepo;
    }

    private Optional<User> getUserFromRequest(HttpServletRequest req) {
        String email = (String) req.getAttribute("userEmail");
        if (email == null) return Optional.empty();
        return userRepo.findByEmail(email);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addToCart(@RequestBody AddToCartRequest request, HttpServletRequest req) {
        Optional<User> uo = getUserFromRequest(req);
        if (uo.isEmpty()) return ResponseEntity.status(401).body("Unauthorized");
        User user = uo.get();
        
        if (request.getProductId() == null || request.getQuantity() == null || request.getQuantity() < 1) {
            return ResponseEntity.badRequest().body("Invalid product ID or quantity");
        }
        
        Optional<Product> po = productRepo.findById(request.getProductId());
        if (po.isEmpty()) return ResponseEntity.badRequest().body("Product not found");
        
        CartItem item = new CartItem();
        item.setUser(user);
        item.setProduct(po.get());
        item.setQuantity(request.getQuantity());
        
        cartRepo.save(item);
        return ResponseEntity.ok(item);
    }

    @GetMapping
    public ResponseEntity<?> getCart(HttpServletRequest req) {
        Optional<User> uo = getUserFromRequest(req);
        if (uo.isEmpty()) return ResponseEntity.status(401).body("Unauthorized");
        return ResponseEntity.ok(cartRepo.findByUser(uo.get()));
    }

    @GetMapping("/user/{username}")
    public ResponseEntity<?> getCartByUsername(@PathVariable String username, HttpServletRequest req) {
        Optional<User> uo = getUserFromRequest(req);
        if (uo.isEmpty() || !uo.get().getEmail().equals(username)) {
            return ResponseEntity.status(401).body("Unauthorized");
        }
        return ResponseEntity.ok(cartRepo.findByUser(uo.get()));
    }

    @PostMapping("/clear")
    public ResponseEntity<?> clearCart(HttpServletRequest req) {
        Optional<User> uo = getUserFromRequest(req);
        if (uo.isEmpty()) return ResponseEntity.status(401).body("Unauthorized");
        cartRepo.deleteByUser(uo.get());
        return ResponseEntity.ok("Cleared");
    }
}
