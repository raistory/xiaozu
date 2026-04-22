package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /notifications - 消息通知
 *   GET: 查询当前用户所有通知，未读优先
 *   POST action=read: 标记单条已读
 *   POST action=readAll: 全部已读
 */
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String sql =
            "SELECT notification_id, content, is_read, created_at " +
            "FROM notifications " +
            "WHERE user_id = ? " +
            "ORDER BY is_read ASC, created_at DESC";

        List<Map<String, Object>> notifyList = new ArrayList<>();
        int unreadCount = 0;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("notificationId", rs.getInt("notification_id"));
                    row.put("content",        rs.getString("content"));
                    boolean isRead = rs.getBoolean("is_read");
                    row.put("isRead", isRead);
                    row.put("createdAt",      rs.getTimestamp("created_at"));
                    notifyList.add(row);
                    if (!isRead) unreadCount++;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载通知失败：" + e.getMessage());
        }

        req.setAttribute("notifyList", notifyList);
        req.setAttribute("unreadCount", unreadCount);
        req.getRequestDispatcher("/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String action = req.getParameter("action");

        if ("read".equals(action)) {
            // 标记单条已读
            String notifyIdStr = req.getParameter("notifyId");
            if (notifyIdStr != null && !notifyIdStr.trim().isEmpty()) {
                try (Connection conn = DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?")) {
                    ps.setInt(1, Integer.parseInt(notifyIdStr.trim()));
                    ps.setInt(2, loginUser.getUserId());
                    ps.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/notifications");

        } else if ("readAll".equals(action)) {
            // 全部标记已读
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0")) {
                ps.setInt(1, loginUser.getUserId());
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/notifications");

        } else if ("delete".equals(action)) {
            // 删除单条通知
            String notifyIdStr = req.getParameter("notifyId");
            if (notifyIdStr != null && !notifyIdStr.trim().isEmpty()) {
                try (Connection conn = DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "DELETE FROM notifications WHERE notification_id = ? AND user_id = ?")) {
                    ps.setInt(1, Integer.parseInt(notifyIdStr.trim()));
                    ps.setInt(2, loginUser.getUserId());
                    ps.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/notifications");

        } else if ("deleteRead".equals(action)) {
            // 清空所有已读通知
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM notifications WHERE user_id = ? AND is_read = 1")) {
                ps.setInt(1, loginUser.getUserId());
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/notifications");

        } else {
            resp.sendRedirect(req.getContextPath() + "/notifications");
        }
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
        return u;
    }
}
