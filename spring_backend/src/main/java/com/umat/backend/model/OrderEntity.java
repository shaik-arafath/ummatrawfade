package com.umat.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne
    private User user;
    private Double totalAmount;
    private String status; // CREATED, PAID, CANCELLED
    @OneToMany(cascade = CascadeType.ALL)
    private List<OrderItem> items;
    private String razorpayOrderId;
    private String razorpayPaymentId;
}
