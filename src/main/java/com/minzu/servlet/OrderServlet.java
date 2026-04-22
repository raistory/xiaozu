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
import java.util.stream.Collectors;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private static final String TYPE_BUY = "buy";
    private static final String TYPE_SELL = "sell";

    private static final String STATUS_CREATED = "CREATED";
    private static final String STATUS_PAID_OFFLINE = "PAID_OFFLINE";
    private static final String STATUS_COMPLETED = "COMPLETED";
    private static final String STATUS_CANCELLED = "CANCELLED";
    private static final String STATUS_DISPUTED = "DISPUTED";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User loginUser = getLoginUser(request, response);
        if (loginUser == null) return;

        String type = normalizeType(request.getParameter("type"));
        int page = parsePositiveInt(request.getParameter("page"), 1);

        int totalCount = 0;
        int totalPages = 1;
        List<Map<String, Object>> orderList = new ArrayList<>();

        String whereClause = TYPE_SELL.equals(type) ? "o.seller_id = ?" : "o.buyer_id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            totalCount = countOrders(conn, whereClause, loginUser.getUserId());
            totalPages = Math.max(1, (int) Math.ceil(totalCount * 1.0 / PAGE_SIZE));
            page = Math.min(page, totalPages);
            int offset = (page - 1) * PAGE_SIZE;

            orderList = queryOrders(conn, whereClause, loginUser.getUserId(), offset);
            fillReviewStatus(conn, loginUser.getUserId(), orderList);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载订单失败：" + e.getMessage());
        }

        request.setAttribute("type", type);
        request.setAttribute("orderList", orderList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/my-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User loginUser = getLoginUser(request, response);
        if (loginUser == null) return;

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            createOrder(request, response, loginUser);
            return;
        }

        String targetStatus = resolveTargetStatus(action);
        if (targetStatus == null) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        updateOrderStatus(request, response, loginUser, targetStatus);
    }

    private User getLoginUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
        }
        return loginUser;
    }

    private String normalizeType(String type) {
        return TYPE_SELL.equals(type) ? TYPE_SELL : TYPE_BUY;
    }

    private int parsePositiveInt(String str, int defaultValue) {
        try {
            return str == null ? defaultValue : Math.max(1, Integer.parseInt(str.trim()));
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String resolveTargetStatus(String action) {
        if ("cancel".equals(action)) return STATUS_CANCELLED;
        if ("paid".equals(action)) return STATUS_PAID_OFFLINE;
        if ("complete".equals(action)) return STATUS_COMPLETED;
        if ("dispute".equals(action)) return STATUS_DISPUTED;
        return null;
    }

    private int countOrders(Connection conn, String whereClause, int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM orders o WHERE " + whereClause;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private List<Map<String, Object>> queryOrders(Connection conn, String whereClause, int userId, int offset)
            throws SQLException {
        List<Map<String, Object>> orderList = new ArrayList<>();

        String sql =
                "SELECT o.order_id, o.order_no, o.product_id, o.deal_price, o.quantity, " +
                        "o.order_status, o.buyer_note, o.seller_note, o.pickup_code, " +
                        "o.created_at, o.paid_at, o.completed_at, o.cancelled_at, " +
                        "IFNULL(o.updated_at, o.created_at) AS updated_at, " +
                        "p.title, p.cover_image_url, " +
                        "bu.nickname AS buyer_name, se.nickname AS seller_name " +
                        "FROM orders o " +
                        "LEFT JOIN products p ON o.product_id = p.product_id " +
                        "LEFT JOIN users bu ON o.buyer_id = bu.user_id " +
                        "LEFT JOIN users se ON o.seller_id = se.user_id " +
                        "WHERE " + whereClause + " " +
                        "ORDER BY o.created_at DESC " +
                        "LIMIT ? OFFSET ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, PAGE_SIZE);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("orderId", rs.getInt("order_id"));
                    row.put("orderNo", rs.getString("order_no"));
                    row.put("productId", rs.getInt("product_id"));
                    row.put("title", rs.getString("title"));
                    row.put("coverImageUrl", rs.getString("cover_image_url"));
                    row.put("dealPrice", rs.getBigDecimal("deal_price"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("orderStatus", rs.getString("order_status"));
                    row.put("buyerNote", rs.getString("buyer_note"));
                    row.put("sellerNote", rs.getString("seller_note"));
                    row.put("pickupCode", rs.getString("pickup_code"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    row.put("paidAt", rs.getTimestamp("paid_at"));
                    row.put("completedAt", rs.getTimestamp("completed_at"));
                    row.put("cancelledAt", rs.getTimestamp("cancelled_at"));
                    row.put("updatedAt", rs.getTimestamp("updated_at"));
                    row.put("buyerName", rs.getString("buyer_name"));
                    row.put("sellerName", rs.getString("seller_name"));
                    row.put("hasReviewed", false);
                    orderList.add(row);
                }
            }
        }

        return orderList;
    }

    private void fillReviewStatus(Connection conn, int reviewerId, List<Map<String, Object>> orderList) throws SQLException {
        List<Integer> completedOrderIds = new ArrayList<>();
        for (Map<String, Object> order : orderList) {
            if (STATUS_COMPLETED.equals(order.get("orderStatus"))) {
                completedOrderIds.add((Integer) order.get("orderId"));
            }
        }

        if (completedOrderIds.isEmpty()) return;

        String placeholders = completedOrderIds.stream()
                .map(id -> "?")
                .collect(Collectors.joining(","));

        String sql = "SELECT order_id FROM reviews WHERE reviewer_id = ? AND order_id IN (" + placeholders + ")";
        Set<Integer> reviewedIds = new HashSet<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerId);
            for (int i = 0; i < completedOrderIds.size(); i++) {
                ps.setInt(i + 2, completedOrderIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reviewedIds.add(rs.getInt("order_id"));
                }
            }
        }

        for (Map<String, Object> order : orderList) {
            Integer orderId = (Integer) order.get("orderId");
            order.put("hasReviewed", reviewedIds.contains(orderId));
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String productIdStr = request.getParameter("productId");
        String buyerNote = trimToNull(request.getParameter("buyerNote"));

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

        String productSql =
                "SELECT product_id, seller_id, price, publish_status, title " +
                        "FROM products WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0 FOR UPDATE";

        String activeOrderSql =
                "SELECT 1 FROM orders " +
                        "WHERE product_id = ? AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED') " +
                        "LIMIT 1";

        String insertSql =
                "INSERT INTO orders " +
                        "(order_no, product_id, buyer_id, seller_id, deal_price, quantity, order_status, buyer_note) " +
                        "VALUES (?, ?, ?, ?, ?, ?, 'CREATED', ?)";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            int sellerId;
            BigDecimal price;
            String publishStatus;
            String productTitle;

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
                    price = rs.getBigDecimal("price");
                    publishStatus = rs.getString("publish_status");
                    productTitle = rs.getString("title");
                }
            }

            if (sellerId == loginUser.getUserId()) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "不能购买自己的商品");
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                return;
            }

            if (!"ON_SALE".equalsIgnoreCase(publishStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "该商品当前不可交易");
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(activeOrderSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        setSessionMsg(request, "errorMsg", "该商品已有进行中的订单，请稍后再试");
                        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                        return;
                    }
                }
            }

            String orderNo = generateOrderNo();
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, orderNo);
                ps.setInt(2, productId);
                ps.setInt(3, loginUser.getUserId());
                ps.setInt(4, sellerId);
                ps.setBigDecimal(5, price);
                ps.setInt(6, 1);
                ps.setString(7, buyerNote);

                int rows = ps.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    setSessionMsg(request, "errorMsg", "下单失败，请重试");
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                    return;
                }
            }

            conn.commit();

            sendNotification(sellerId, "您收到了一个关于「" + productTitle + "」的新订单，请前往「我的订单」查看处理");
            setSessionMsg(request, "successMsg", "订单已创建，请等待卖家确认");
            response.sendRedirect(request.getContextPath() + "/orders?type=buy");

        } catch (Exception e) {
            safeRollback(conn);
            e.printStackTrace();
            setSessionMsg(request, "errorMsg", "下单失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/product-list");
        } finally {
            closeConn(conn);
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response,
                                   User loginUser, String targetStatus) throws IOException {

        String type = normalizeType(request.getParameter("type"));
        int orderId = parsePositiveInt(request.getParameter("orderId"), -1);
        if (orderId < 1) {
            response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
            return;
        }

        Connection conn = null;
        NotificationTask notificationTask = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            OrderSnapshot order = lockOrderForUpdate(conn, orderId);
            if (order == null) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "订单不存在");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if (order.isDeletedProduct) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "商品已被删除，无法操作订单");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if (!canOperate(loginUser.getUserId(), order, targetStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "无权操作该订单");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if (!isValidTransition(order.orderStatus, targetStatus)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "操作失败，当前订单状态不允许此操作");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if ((STATUS_PAID_OFFLINE.equals(targetStatus) || STATUS_COMPLETED.equals(targetStatus))
                    && hasOtherActiveOrders(conn, order.productId, order.orderId)) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "该商品存在其他进行中的订单，请先处理后再继续");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            int rows = executeStatusUpdate(conn, orderId, loginUser.getUserId(), targetStatus);
            if (rows <= 0) {
                conn.rollback();
                setSessionMsg(request, "errorMsg", "操作失败，可能订单状态已变更");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if (STATUS_CANCELLED.equals(targetStatus) && !hasOtherActiveOrders(conn, order.productId, order.orderId)) {
                restoreReservedProduct(conn, order.productId);
            }

            if (STATUS_COMPLETED.equals(targetStatus)) {
                markProductSold(conn, order.productId);
            }

            notificationTask = buildNotificationTask(order, loginUser.getUserId(), targetStatus);

            conn.commit();

            if (notificationTask != null) {
                sendNotification(notificationTask.userId, notificationTask.content);
            }

            setSessionMsg(request, "successMsg", successMsg(targetStatus));
        } catch (Exception e) {
            safeRollback(conn);
            e.printStackTrace();
            setSessionMsg(request, "errorMsg", "操作失败：" + e.getMessage());
        } finally {
            closeConn(conn);
        }

        response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
    }

    private OrderSnapshot lockOrderForUpdate(Connection conn, int orderId) throws SQLException {
        String sql =
                "SELECT o.order_id, o.product_id, o.buyer_id, o.seller_id, o.order_status, " +
                        "p.title, IFNULL(p.is_deleted, 0) AS is_deleted " +
                        "FROM orders o " +
                        "LEFT JOIN products p ON p.product_id = o.product_id " +
                        "WHERE o.order_id = ? FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                OrderSnapshot snapshot = new OrderSnapshot();
                snapshot.orderId = rs.getInt("order_id");
                snapshot.productId = rs.getInt("product_id");
                snapshot.buyerId = rs.getInt("buyer_id");
                snapshot.sellerId = rs.getInt("seller_id");
                snapshot.orderStatus = rs.getString("order_status");
                snapshot.productTitle = rs.getString("title");
                snapshot.isDeletedProduct = rs.getInt("is_deleted") == 1;
                return snapshot;
            }
        }
    }

    private boolean canOperate(int userId, OrderSnapshot order, String targetStatus) {
        if (STATUS_CANCELLED.equals(targetStatus) || STATUS_COMPLETED.equals(targetStatus)) {
            return userId == order.buyerId;
        }
        if (STATUS_PAID_OFFLINE.equals(targetStatus)) {
            return userId == order.sellerId;
        }
        if (STATUS_DISPUTED.equals(targetStatus)) {
            return userId == order.buyerId || userId == order.sellerId;
        }
        return false;
    }

    private boolean isValidTransition(String currentStatus, String targetStatus) {
        if (STATUS_CANCELLED.equals(targetStatus)) {
            return STATUS_CREATED.equals(currentStatus);
        }
        if (STATUS_PAID_OFFLINE.equals(targetStatus)) {
            return STATUS_CREATED.equals(currentStatus);
        }
        if (STATUS_COMPLETED.equals(targetStatus)) {
            return STATUS_PAID_OFFLINE.equals(currentStatus);
        }
        if (STATUS_DISPUTED.equals(targetStatus)) {
            return STATUS_CREATED.equals(currentStatus) || STATUS_PAID_OFFLINE.equals(currentStatus);
        }
        return false;
    }

    private int executeStatusUpdate(Connection conn, int orderId, int userId, String targetStatus) throws SQLException {
        if (STATUS_CANCELLED.equals(targetStatus)) {
            String sql = "UPDATE orders SET order_status='CANCELLED', cancelled_at=NOW() " +
                    "WHERE order_id=? AND buyer_id=? AND order_status='CREATED'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                return ps.executeUpdate();
            }
        }

        if (STATUS_PAID_OFFLINE.equals(targetStatus)) {
            String sql = "UPDATE orders SET order_status='PAID_OFFLINE', paid_at=NOW(), pickup_code=? " +
                    "WHERE order_id=? AND seller_id=? AND order_status='CREATED'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, generatePickupCode());
                ps.setInt(2, orderId);
                ps.setInt(3, userId);
                return ps.executeUpdate();
            }
        }

        if (STATUS_COMPLETED.equals(targetStatus)) {
            String sql = "UPDATE orders SET order_status='COMPLETED', completed_at=NOW() " +
                    "WHERE order_id=? AND buyer_id=? AND order_status='PAID_OFFLINE'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                return ps.executeUpdate();
            }
        }

        if (STATUS_DISPUTED.equals(targetStatus)) {
            String sql = "UPDATE orders SET order_status='DISPUTED' " +
                    "WHERE order_id=? AND (buyer_id=? OR seller_id=?) " +
                    "AND order_status IN ('CREATED','PAID_OFFLINE')";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                ps.setInt(3, userId);
                return ps.executeUpdate();
            }
        }

        return 0;
    }

    private void markProductSold(Connection conn, int productId) throws SQLException {
        String sql = "UPDATE products SET publish_status='SOLD' " +
                "WHERE product_id=? AND publish_status IN ('ON_SALE','OFF_SHELF')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    private void restoreReservedProduct(Connection conn, int productId) throws SQLException {
        String sql = "UPDATE products SET publish_status='ON_SALE' " +
                "WHERE product_id=? AND publish_status='OFF_SHELF'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    private boolean hasOtherActiveOrders(Connection conn, int productId, int currentOrderId) throws SQLException {
        String sql = "SELECT 1 FROM orders WHERE product_id=? AND order_id<>? " +
                "AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED') LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, currentOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private NotificationTask buildNotificationTask(OrderSnapshot order, int operatorUserId, String targetStatus) {
        String title = order.productTitle == null ? "未知商品" : order.productTitle;
        NotificationTask task = new NotificationTask();

        if (STATUS_PAID_OFFLINE.equals(targetStatus)) {
            task.userId = order.buyerId;
            task.content = "卖家已确认「" + title + "」线下成交！请前往「我的订单」查看取货码";
            return task;
        }

        if (STATUS_COMPLETED.equals(targetStatus)) {
            task.userId = order.sellerId;
            task.content = "买家已确认「" + title + "」交易完成，商品已自动标记为已售出";
            return task;
        }

        if (STATUS_CANCELLED.equals(targetStatus)) {
            task.userId = order.sellerId;
            task.content = "买家取消了「" + title + "」的订单";
            return task;
        }

        if (STATUS_DISPUTED.equals(targetStatus)) {
            task.userId = (operatorUserId == order.buyerId) ? order.sellerId : order.buyerId;
            task.content = "订单「" + title + "」已被发起纠纷，请联系对方协商处理";
            return task;
        }

        return null;
    }

    private String successMsg(String targetStatus) {
        if (STATUS_COMPLETED.equals(targetStatus)) return "订单已完成，商品已标记为已售";
        if (STATUS_PAID_OFFLINE.equals(targetStatus)) return "已确认线下成交，取货码已生成";
        return "订单状态已更新";
    }

    private String generateOrderNo() {
        return "ORD" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    private String generatePickupCode() {
        return String.format("%06d", new Random().nextInt(1_000_000));
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
            try {
                conn.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void closeConn(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private static class OrderSnapshot {
        int orderId;
        int productId;
        int buyerId;
        int sellerId;
        String orderStatus;
        String productTitle;
        boolean isDeletedProduct;
    }

    private static class NotificationTask {
        int userId;
        String content;
    }
}
