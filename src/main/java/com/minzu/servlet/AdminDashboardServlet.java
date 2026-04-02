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

/**
 * /admin/dashboard - 管理后台数据统计面板
 * GET: 查询平台统计数据（用户数、商品数、订单数、交易金额）并展示
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 管理员登录校验
        HttpSession session = req.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!"ADMIN".equals(loginUser.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {

            // 总用户数
            long totalUsers = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalUsers = rs.getLong(1);
            }

            // 今日新增用户数
            long todayNewUsers = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) todayNewUsers = rs.getLong(1);
            }

            // 在售商品数
            long onSaleProducts = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM products WHERE publish_status = 'ON_SALE' AND IFNULL(is_deleted, 0) = 0");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) onSaleProducts = rs.getLong(1);
            }

            // 注册用户数（已激活）
            long totalActiveUsers = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM users WHERE account_status = 'ACTIVE' AND IFNULL(is_deleted, 0) = 0 AND role_code != 'ADMIN'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalActiveUsers = rs.getLong(1);
            }

            // 总订单数
            long totalOrders = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM orders");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalOrders = rs.getLong(1);
            }

            // 已完成订单数
            long completedOrders = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM orders WHERE order_status = 'COMPLETED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) completedOrders = rs.getLong(1);
            }

            // 总交易金额（已完成订单的 deal_price 总和）
            BigDecimal totalAmount = BigDecimal.ZERO;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT IFNULL(SUM(deal_price), 0) FROM orders WHERE order_status = 'COMPLETED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalAmount = rs.getBigDecimal(1);
            }

            // 近7天每天订单数
            List<Map<String, Object>> dailyOrders = new ArrayList<>();
            String dailySql =
                "SELECT DATE(created_at) AS order_date, COUNT(*) AS order_count " +
                "FROM orders " +
                "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                "GROUP BY DATE(created_at) " +
                "ORDER BY order_date ASC";
            try (PreparedStatement ps = conn.prepareStatement(dailySql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("orderDate", rs.getDate("order_date"));
                    row.put("orderCount", rs.getInt("order_count"));
                    dailyOrders.add(row);
                }
            }

            // 近7天每日新增用户数
            List<Map<String, Object>> dailyUsers = new ArrayList<>();
            String dailyUsersSql =
                "SELECT DATE(created_at) AS reg_date, COUNT(*) AS reg_count " +
                "FROM users " +
                "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                "GROUP BY DATE(created_at) " +
                "ORDER BY reg_date ASC";
            try (PreparedStatement ps = conn.prepareStatement(dailyUsersSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("regDate", rs.getDate("reg_date"));
                    row.put("regCount", rs.getInt("reg_count"));
                    dailyUsers.add(row);
                }
            }

            // 各分类商品数量
            List<Map<String, Object>> categoryStats = new ArrayList<>();
            String catStatsSql =
                "SELECT c.category_name, COUNT(p.product_id) AS product_count " +
                "FROM products p LEFT JOIN categories c ON p.category_id = c.category_id " +
                "WHERE p.is_deleted = 0 " +
                "GROUP BY c.category_name ORDER BY product_count DESC";
            try (PreparedStatement ps = conn.prepareStatement(catStatsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("categoryName", rs.getString("category_name"));
                    row.put("productCount", rs.getInt("product_count"));
                    categoryStats.add(row);
                }
            }

            // 近7天每日完成交易金额
            List<Map<String, Object>> dailyAmount = new ArrayList<>();
            String dailyAmountSql =
                "SELECT DATE(created_at) AS order_date, IFNULL(SUM(deal_price),0) AS daily_amount " +
                "FROM orders WHERE order_status='COMPLETED' " +
                "AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                "GROUP BY DATE(created_at) ORDER BY order_date ASC";
            try (PreparedStatement ps = conn.prepareStatement(dailyAmountSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("orderDate", rs.getDate("order_date"));
                    row.put("dailyAmount", rs.getBigDecimal("daily_amount"));
                    dailyAmount.add(row);
                }
            }

            // 设置属性
            req.setAttribute("totalUsers", totalUsers);
            req.setAttribute("todayNewUsers", todayNewUsers);
            req.setAttribute("onSaleProducts", onSaleProducts);
            req.setAttribute("totalActiveUsers", totalActiveUsers);
            req.setAttribute("totalOrders", totalOrders);
            req.setAttribute("completedOrders", completedOrders);
            req.setAttribute("totalAmount", totalAmount);
            req.setAttribute("dailyOrders", dailyOrders);
            req.setAttribute("dailyUsers", dailyUsers);
            req.setAttribute("categoryStats", categoryStats);
            req.setAttribute("dailyAmount", dailyAmount);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载统计数据失败：" + e.getMessage());
        }

        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, resp);
    }
}
