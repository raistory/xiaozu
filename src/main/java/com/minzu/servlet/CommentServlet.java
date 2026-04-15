package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String productIdStr = request.getParameter("productId");
        String content = request.getParameter("content");
        String parentIdStr = request.getParameter("parentId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        if (content == null || content.trim().isEmpty() || content.length() > 500) {
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
            return;
        }

        Integer parentId = null;
        if (parentIdStr != null && !parentIdStr.trim().isEmpty()) {
            try {
                parentId = Integer.parseInt(parentIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        try (Connection conn = DBUtil.getConnection()) {
            Integer sellerId = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT seller_id FROM products WHERE product_id = ? AND is_deleted = 0")) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        sellerId = rs.getInt("seller_id");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                        return;
                    }
                }
            }

            int commentId = 0;
            String insertSql = "INSERT INTO product_comments (product_id, user_id, content, parent_id) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, productId);
                ps.setInt(2, loginUser.getUserId());
                ps.setString(3, content.trim());
                if (parentId != null) {
                    ps.setInt(4, parentId);
                } else {
                    ps.setNull(4, Types.INTEGER);
                }
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) commentId = keys.getInt(1);
                }
            }

            if (parentId == null) {
                if (sellerId != null && sellerId != loginUser.getUserId()) {
                    String notifyContent = "用户「" + loginUser.getNickname() + "」在你的商品下留言：" + content.trim();
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO notifications (user_id, content) VALUES (?, ?)")) {
                        ps.setInt(1, sellerId);
                        ps.setString(2, notifyContent);
                        ps.executeUpdate();
                    }
                }
            } else {
                Integer replyToUserId = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT user_id FROM product_comments WHERE comment_id = ?")) {
                    ps.setInt(1, parentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) replyToUserId = rs.getInt("user_id");
                    }
                }
                if (replyToUserId != null && replyToUserId != loginUser.getUserId()) {
                    String notifyContent = "用户「" + loginUser.getNickname() + "」回复了你的留言：" + content.trim();
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO notifications (user_id, content) VALUES (?, ?)")) {
                        ps.setInt(1, replyToUserId);
                        ps.setString(2, notifyContent);
                        ps.executeUpdate();
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
    }
}
