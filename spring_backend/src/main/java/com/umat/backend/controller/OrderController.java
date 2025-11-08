package com.umat.backend.controller;

import com.umat.backend.model.*;
import com.umat.backend.repository.CartItemRepository;
import com.umat.backend.repository.OrderRepository;
import com.umat.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final CartItemRepository cartRepo;
    private final OrderRepository orderRepo;
    private final UserRepository userRepo;
    
    public OrderController(CartItemRepository cartRepo, OrderRepository orderRepo, UserRepository userRepo) {
        this.cartRepo = cartRepo; this.orderRepo = orderRepo; this.userRepo = userRepo;
    }

    private Optional<User> getUser(HttpServletRequest req) {
        String email = (String) req.getAttribute("userEmail");
        if (email == null) return Optional.empty();
        return userRepo.findByEmail(email);
    }

    @PostMapping("/create")
    public ResponseEntity<?> createOrder(@RequestBody OrderEntity order, HttpServletRequest req) {
        Optional<User> uo = getUser(req);
        if (uo.isEmpty()) return ResponseEntity.status(401).body("Unauthorized");
        User user = uo.get();
        // calculate total from items
        double total = 0.0;
        for (OrderItem it : order.getItems()) total += it.getPrice() * it.getQuantity();
        order.setTotalAmount(total);
        order.setUser(user);
        order.setStatus("CREATED");
        OrderEntity saved = orderRepo.save(order);
        // clear cart after creating order
        cartRepo.deleteByUser(user);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrder(@PathVariable Long id, HttpServletRequest req) {
        Optional<User> uo = getUser(req);
        if (uo.isEmpty()) return ResponseEntity.status(401).body("Unauthorized");
        return orderRepo.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
}
