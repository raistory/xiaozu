package com.minzu.servlet;

import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/seller")
public class SellerProfileServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        int sellerId;
        try {
            sellerId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr.trim()));
        } catch (NumberFormatException ignored) {}

        Map<String, Object> seller = null;
        double avgRating = 0;
        int reviewCount = 0;
        int onSaleCount = 0;
        List<Map<String, Object>> productList = new ArrayList<>();
        List<Map<String, Object>> reviewList = new ArrayList<>();
        int totalPages = 1;

        try (Connection conn = DBUtil.getConnection()) {

            // 查询卖家基本信息
            String sellerSql = "SELECT user_id, real_name, nickname, avatar_url FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sellerSql)) {
                ps.setInt(1, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        seller = new HashMap<>();
                        seller.put("userId", rs.getInt("user_id"));
                        seller.put("realName", rs.getString("real_name"));
                        seller.put("nickname", rs.getString("nickname"));
                        seller.put("avatarUrl", rs.getString("avatar_url"));
                    }
                }
            }

            if (seller == null) {
                response.sendRedirect(request.getContextPath() + "/index");
                return;
            }

            // 计算平均评分
            String ratingSql = "SELECT AVG(score), COUNT(*) FROM reviews WHERE reviewed_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(ratingSql)) {
                ps.setInt(1, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        avgRating = rs.getDouble(1);
                        reviewCount = rs.getInt(2);
                    }
                }
            }

            // 统计在售商品数量
            String countSql = "SELECT COUNT(*) FROM products WHERE seller_id = ? AND publish_status = 'ON_SALE' AND is_deleted = 0";
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) onSaleCount = rs.getInt(1);
                }
            }

            // 分页查询在售商品
            totalPages = (int) Math.ceil((double) onSaleCount / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * PAGE_SIZE;

            String productSql = "SELECT product_id, title, price, cover_image_url, condition_level, created_at " +
                    "FROM products WHERE seller_id = ? AND publish_status = 'ON_SALE' AND is_deleted = 0 " +
                    "ORDER BY created_at DESC LIMIT ? OFFSET ?";
            try (PreparedStatement ps = conn.prepareStatement(productSql)) {
                ps.setInt(1, sellerId);
                ps.setInt(2, PAGE_SIZE);
                ps.setInt(3, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("productId", rs.getInt("product_id"));
                        p.put("title", rs.getString("title"));
                        p.put("price", rs.getBigDecimal("price"));
                        p.put("coverImageUrl", rs.getString("cover_image_url"));
                        p.put("conditionLevel", rs.getString("condition_level"));
                        p.put("createdAt", rs.getTimestamp("created_at"));
                        productList.add(p);
                    }
                }
            }

            // 查询最近10条评价
            String reviewSql = "SELECT r.score, r.content, r.role, r.created_at, " +
                    "u.real_name AS reviewer_name " +
                    "FROM reviews r LEFT JOIN users u ON r.reviewer_id = u.user_id " +
                    "WHERE r.reviewed_id = ? ORDER BY r.created_at DESC LIMIT 10";
            try (PreparedStatement ps = conn.prepareStatement(reviewSql)) {
                ps.setInt(1, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> r = new HashMap<>();
                        r.put("score", rs.getInt("score"));
                        r.put("content", rs.getString("content"));
                        r.put("role", rs.getString("role"));
                        r.put("createdAt", rs.getTimestamp("created_at"));
                        r.put("reviewerName", rs.getString("reviewer_name"));
                        reviewList.add(r);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("seller", seller);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("reviewCount", reviewCount);
        request.setAttribute("onSaleCount", onSaleCount);
        request.setAttribute("productList", productList);
        request.setAttribute("reviewList", reviewList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/seller-profile.jsp").forward(request, response);
    }
}
