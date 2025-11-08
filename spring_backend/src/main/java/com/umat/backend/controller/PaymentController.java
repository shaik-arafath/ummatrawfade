package com.umat.backend.controller;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.PaymentLink;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Value("${razorpay.key}")
    private String razorKey;
    @Value("${razorpay.secret}")
    private String razorSecret;

    @PostMapping("/create-order")
    public ResponseEntity<?> createRazorpayOrder(@RequestBody Map<String, Object> body) {
        try {
            Double amount = Double.parseDouble(body.get("amount").toString()); // rupees
            int amountPaise = (int) Math.round(amount * 100);
            RazorpayClient client = new RazorpayClient(razorKey, razorSecret);
            JSONObject options = new JSONObject();
            options.put("amount", amountPaise);
            options.put("currency", "INR");
            Order order = client.orders.create(options);
            Map<String, Object> res = new HashMap<>();
            res.put("orderId", order.get("id"));
            res.put("amount", order.get("amount"));
            return ResponseEntity.ok(res);
        } catch (RazorpayException e) {
            return ResponseEntity.status(500).body("Razorpay error: " + e.getMessage());
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verifyPayment(@RequestBody Map<String, String> payload) {
        // Backend should verify signature here using razorpay-java util or manual HMAC
        // For brevity we only echo back the payload; implement verification in production
        return ResponseEntity.ok(payload);
    }

    @PostMapping("/create-link")
    public ResponseEntity<?> createPaymentLink(@RequestBody Map<String, Object> body) {
        try {
            Double amount = Double.parseDouble(body.getOrDefault("amount", 0).toString()); // rupees
            int amountPaise = (int) Math.round(amount * 100);
            RazorpayClient client = new RazorpayClient(razorKey, razorSecret);

            JSONObject options = new JSONObject();
            options.put("amount", amountPaise);
            options.put("currency", "INR");
            if (body.containsKey("description")) {
                options.put("description", body.get("description").toString());
            }
            JSONObject customer = new JSONObject();
            if (body.containsKey("name")) customer.put("name", body.get("name").toString());
            if (body.containsKey("email")) customer.put("email", body.get("email").toString());
            if (body.containsKey("contact")) customer.put("contact", body.get("contact").toString());
            if (customer.length() > 0) {
                options.put("customer", customer);
            }
            options.put("reminder_enable", true);

            if (body.containsKey("callback_url")) {
                options.put("callback_url", body.get("callback_url").toString());
                options.put("callback_method", "get");
            }

            PaymentLink link = client.paymentLink.create(options);
            Map<String, Object> res = new HashMap<>();
            res.put("id", link.get("id"));
            res.put("short_url", link.get("short_url"));
            res.put("status", link.get("status"));
            return ResponseEntity.ok(res);
        } catch (RazorpayException e) {
            return ResponseEntity.status(500).body("Razorpay error: " + e.getMessage());
        }
    }

    @GetMapping("/link/{id}")
    public ResponseEntity<?> fetchPaymentLink(@PathVariable String id) {
        try {
            RazorpayClient client = new RazorpayClient(razorKey, razorSecret);
            PaymentLink link = client.paymentLink.fetch(id);
            Map<String, Object> res = new HashMap<>();
            res.put("id", link.get("id"));
            res.put("amount", link.get("amount"));
            res.put("status", link.get("status"));
            res.put("short_url", link.get("short_url"));
            res.put("created_at", link.get("created_at"));
            return ResponseEntity.ok(res);
        } catch (RazorpayException e) {
            return ResponseEntity.status(500).body("Razorpay error: " + e.getMessage());
        }
    }
}
