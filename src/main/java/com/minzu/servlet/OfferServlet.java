package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet("/offer")
public class OfferServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User loginUser = getLoginUser(request, response);
        if (loginUser == null) return;

        String tab = request.getParameter("tab");
        if (tab == null) tab = "received";

        List<Map<String, Object>> offerList = new ArrayList<>();

        String sql;
        if ("sent".equals(tab)) {
            sql = "SELECT o.*, bu.nickname AS buyer_name, se.nickname AS seller_name, " +
                  "p.title AS product_title, p.cover_image_url " +
                  "FROM offers o " +
                  "LEFT JOIN users bu ON o.buyer_id = bu.user_id " +
                  "LEFT JOIN users se ON o.seller_id = se.user_id " +
                  "LEFT JOIN products p ON o.product_id = p.product_id " +
                  "WHERE o.buyer_id = ? ORDER BY o.created_at DESC";
        } else {
            sql = "SELECT o.*, bu.nickname AS buyer_name, se.nickname AS seller_name, " +
                  "p.title AS product_title, p.cover_image_url " +
                  "FROM offers o " +
                  "LEFT JOIN users bu ON o.buyer_id = bu.user_id " +
                  "LEFT JOIN users se ON o.seller_id = se.user_id " +
                  "LEFT JOIN products p ON o.product_id = p.product_id " +
                  "WHERE o.seller_id = ? ORDER BY o.created_at DESC";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("offerId", rs.getInt("offer_id"));
                    row.put("productId", rs.getInt("product_id"));
                    row.put("buyerId", rs.getInt("buyer_id"));
                    row.put("sellerId", rs.getInt("seller_id"));
                    row.put("offerPrice", rs.getBigDecimal("offer_price"));
                    row.put("message", rs.getString("message"));
                    row.put("status", rs.getString("status"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    row.put("updatedAt", rs.getTimestamp("updated_at"));
                    row.put("buyerName", rs.getString("buyer_name"));
                    row.put("sellerName", rs.getString("seller_name"));
                    row.put("productTitle", rs.getString("product_title"));
                    row.put("coverImageUrl", rs.getString("cover_image_url"));
                    offerList.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载出价记录失败：" + e.getMessage());
        }

        request.setAttribute("offerList", offerList);
        request.setAttribute("tab", tab);
        request.getRequestDispatcher("/my-offers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User loginUser = getLoginUser(request, response);
        if (loginUser == null) return;

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            createOffer(request, response, loginUser);
        } else if ("accept".equals(action)) {
            acceptOffer(request, response, loginUser);
        } else if ("reject".equals(action)) {
            rejectOffer(request, response, loginUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/offer?tab=received");
        }
    }

    private void createOffer(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String productIdStr = request.getParameter("productId");
        String offerPriceStr = request.getParameter("offerPrice");
        String message = trimToNull(request.getParameter("message"));

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            setSessionMsg(request, "errorMsg", "商品ID不能为空");
            response.sendRedirect(request.getContextPath() + "/product-list");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            setSessionMsg(request, "errorMsg", "商品ID格式错误");
            response.sendRedirect(request.getContextPath() + "/product-list");
            return;
        }

        if (offerPriceStr == null || offerPriceStr.trim().isEmpty()) {
            setSessionMsg(request, "errorMsg", "请输入出价金额");
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
            return;
        }

        BigDecimal offerPrice;
        try {
            offerPrice = new BigDecimal(offerPriceStr.trim());
            if (offerPrice.compareTo(BigDecimal.ZERO) <= 0) {
                throw new NumberFormatException("价格必须大于0");
            }
        } catch (NumberFormatException e) {
            setSessionMsg(request, "errorMsg", "出价金额格式不正确");
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
            return;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String productSql = "SELECT product_id, seller_id, publish_status, title FROM products " +
                                "WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0 FOR UPDATE";
            int sellerId = 0;
            String publishStatus = "";
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(productSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "商品不存在");
                        response.sendRedirect(request.getContextPath() + "/product-list");
                        return;
                    }
                    sellerId = rs.getInt("seller_id");
                    publishStatus = rs.getString("publish_status");
                    productTitle = rs.getString("title");
                }
            }

            if (sellerId == loginUser.getUserId()) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "不能对自己的商品出价");
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                return;
            }

            if (!"ON_SALE".equalsIgnoreCase(publishStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "该商品当前不可交易");
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                return;
            }

            String existSql = "SELECT 1 FROM offers WHERE product_id = ? AND buyer_id = ? AND status = 'PENDING' LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(existSql)) {
                ps.setInt(1, productId);
                ps.setInt(2, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "你已对该商品有一个待处理的出价，请等待卖家处理");
                        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                        return;
                    }
                }
            }

            String insertSql = "INSERT INTO offers (product_id, buyer_id, seller_id, offer_price, message) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, productId);
                ps.setInt(2, loginUser.getUserId());
                ps.setInt(3, sellerId);
                ps.setBigDecimal(4, offerPrice);
                ps.setString(5, message);
                ps.executeUpdate();
            }

            conn.commit();

            sendNotification(sellerId, "买家「" + loginUser.getNickname() + "」对您的商品「" + productTitle + "」出价 ¥" + offerPrice + "，请前往「我的出价」查看");
            setSessionMsg(request, "successMsg", "出价已提交，等待卖家回复");
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);

        } catch (Exception e) {
            safeRollback(conn);
            e.printStackTrace();
            setSessionMsg(request, "errorMsg", "出价失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
        } finally {
            closeConn(conn);
        }
    }

    private void acceptOffer(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String offerIdStr = request.getParameter("offerId");
        if (offerIdStr == null || offerIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/offer?tab=received");
            return;
        }

        int offerId;
        try {
            offerId = Integer.parseInt(offerIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/offer?tab=received");
            return;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String lockSql = "SELECT o.offer_id, o.product_id, o.buyer_id, o.seller_id, o.offer_price, o.status, " +
                             "p.title, p.publish_status, IFNULL(p.is_deleted, 0) AS is_deleted " +
                             "FROM offers o " +
                             "LEFT JOIN products p ON o.product_id = p.product_id " +
                             "WHERE o.offer_id = ? FOR UPDATE";

            int productId = 0;
            int buyerId = 0;
            BigDecimal offerPrice = null;
            String offerStatus = "";
            String productTitle = "";
            int offerSellerId = 0;
            String publishStatus = "";
            boolean deletedProduct = false;

            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, offerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "出价记录不存在");
                        response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                        return;
                    }
                    productId = rs.getInt("product_id");
                    buyerId = rs.getInt("buyer_id");
                    offerSellerId = rs.getInt("seller_id");
                    offerPrice = rs.getBigDecimal("offer_price");
                    offerStatus = rs.getString("status");
                    productTitle = rs.getString("title");
                    publishStatus = rs.getString("publish_status");
                    deletedProduct = rs.getInt("is_deleted") == 1;
                }
            }

            if (!"PENDING".equals(offerStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "该出价已被处理");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            if (offerSellerId != loginUser.getUserId()) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "无权操作该出价");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            if (deletedProduct || publishStatus == null) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "商品已不存在，无法接受该出价");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            if (!"ON_SALE".equalsIgnoreCase(publishStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "商品当前不可交易，无法接受该出价");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            String activeOrderSql = "SELECT 1 FROM orders " +
                                    "WHERE product_id = ? AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED') LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(activeOrderSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "该商品已有进行中的订单，无法再接受出价");
                        response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                        return;
                    }
                }
            }

            String updateSql = "UPDATE offers SET status = 'ACCEPTED' WHERE offer_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, offerId);
                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    setSessionMsg(request, "errorMsg", "操作失败，出价状态可能已变更");
                    response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                    return;
                }
            }

            String orderNo = "ORD" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
            String insertOrderSql = "INSERT INTO orders (order_no, product_id, buyer_id, seller_id, deal_price, quantity, order_status) " +
                                    "VALUES (?, ?, ?, ?, ?, 1, 'CREATED')";
            try (PreparedStatement ps = conn.prepareStatement(insertOrderSql)) {
                ps.setString(1, orderNo);
                ps.setInt(2, productId);
                ps.setInt(3, buyerId);
                ps.setInt(4, offerSellerId);
                ps.setBigDecimal(5, offerPrice);
                ps.executeUpdate();
            }

            String reserveProductSql = "UPDATE products SET publish_status = 'OFF_SHELF', updated_at = NOW() " +
                                       "WHERE product_id = ? AND publish_status = 'ON_SALE' AND IFNULL(is_deleted, 0) = 0";
            try (PreparedStatement ps = conn.prepareStatement(reserveProductSql)) {
                ps.setInt(1, productId);
                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    setSessionMsg(request, "errorMsg", "商品状态已变化，无法接受该出价");
                    response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                    return;
                }
            }

            String rejectSql = "UPDATE offers SET status = 'REJECTED' WHERE product_id = ? AND status = 'PENDING' AND offer_id != ?";
            try (PreparedStatement ps = conn.prepareStatement(rejectSql)) {
                ps.setInt(1, productId);
                ps.setInt(2, offerId);
                ps.executeUpdate();
            }

            conn.commit();

            sendNotification(buyerId, "卖家已接受您对「" + productTitle + "」的出价 ¥" + offerPrice + "，订单已创建，请前往「我的订单」查看");
            setSessionMsg(request, "successMsg", "已接受出价，订单已创建");

        } catch (Exception e) {
            safeRollback(conn);
            e.printStackTrace();
            setSessionMsg(request, "errorMsg", "操作失败：" + e.getMessage());
        } finally {
            closeConn(conn);
        }

        response.sendRedirect(request.getContextPath() + "/offer?tab=received");
    }

    private void rejectOffer(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String offerIdStr = request.getParameter("offerId");
        if (offerIdStr == null || offerIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/offer?tab=received");
            return;
        }

        int offerId;
        try {
            offerId = Integer.parseInt(offerIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/offer?tab=received");
            return;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String lockSql = "SELECT o.offer_id, o.buyer_id, o.seller_id, o.status, p.title " +
                             "FROM offers o LEFT JOIN products p ON o.product_id = p.product_id " +
                             "WHERE o.offer_id = ? FOR UPDATE";

            int buyerId = 0;
            int offerSellerId = 0;
            String offerStatus = "";
            String productTitle = "";

            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, offerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "出价记录不存在");
                        response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                        return;
                    }
                    buyerId = rs.getInt("buyer_id");
                    offerSellerId = rs.getInt("seller_id");
                    offerStatus = rs.getString("status");
                    productTitle = rs.getString("title");
                }
            }

            if (!"PENDING".equals(offerStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "该出价已被处理");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            if (offerSellerId != loginUser.getUserId()) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "无权操作该出价");
                response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                return;
            }

            String updateSql = "UPDATE offers SET status = 'REJECTED' WHERE offer_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, offerId);
                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    setSessionMsg(request, "errorMsg", "操作失败");
                    response.sendRedirect(request.getContextPath() + "/offer?tab=received");
                    return;
                }
            }

            conn.commit();

            sendNotification(buyerId, "卖家已拒绝您对「" + productTitle + "」的出价");
            setSessionMsg(request, "successMsg", "已拒绝该出价");

        } catch (Exception e) {
            safeRollback(conn);
            e.printStackTrace();
            setSessionMsg(request, "errorMsg", "操作失败：" + e.getMessage());
        } finally {
            closeConn(conn);
        }

        response.sendRedirect(request.getContextPath() + "/offer?tab=received");
    }

    private User getLoginUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
        }
        return loginUser;
    }

    private void sendNotification(int userId, String content) {
        String sql = "INSERT INTO notifications (user_id, content) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setSessionMsg(HttpServletRequest request, String key, String value) {
        request.getSession().setAttribute(key, value);
    }

    private String trimToNull(String str) {
        if (str == null) return null;
        String s = str.trim();
        return s.isEmpty() ? null : s;
    }

    private void safeRollback(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    private void closeConn(Connection conn) {
        if (conn != null) {
            try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
