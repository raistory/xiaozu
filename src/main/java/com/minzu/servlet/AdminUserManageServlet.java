package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserManageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";
        String statusFilter = request.getParameter("status");
        if (statusFilter == null) statusFilter = "";
        String pageStr = request.getParameter("page");
        int currentPage = 1;
        if (pageStr != null) {
            try { currentPage = Integer.parseInt(pageStr); } catch (Exception e) {}
        }
        if (currentPage < 1) currentPage = 1;
        int pageSize = 20;

        StringBuilder countSql = new StringBuilder("SELECT COUNT(*) FROM users WHERE role_code != 'ADMIN' AND IFNULL(is_deleted, 0) = 0");
        StringBuilder listSql = new StringBuilder(
            "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, account_status, created_at " +
            "FROM users WHERE role_code != 'ADMIN' AND IFNULL(is_deleted, 0) = 0");

        if (!keyword.trim().isEmpty()) {
            String condition = " AND (student_or_staff_no LIKE ? OR real_name LIKE ? OR nickname LIKE ?)";
            countSql.append(condition);
            listSql.append(condition);
        }
        if (!statusFilter.isEmpty()) {
            String condition = " AND account_status = ?";
            countSql.append(condition);
            listSql.append(condition);
        }

        listSql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");

        int totalCount = 0;
        List<User> userList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            // Count
            try (PreparedStatement ps = conn.prepareStatement(countSql.toString())) {
                int idx = 1;
                if (!keyword.trim().isEmpty()) {
                    String like = "%" + keyword.trim() + "%";
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                }
                if (!statusFilter.isEmpty()) {
                    ps.setString(idx++, statusFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            // List
            try (PreparedStatement ps = conn.prepareStatement(listSql.toString())) {
                int idx = 1;
                if (!keyword.trim().isEmpty()) {
                    String like = "%" + keyword.trim() + "%";
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                }
                if (!statusFilter.isEmpty()) {
                    ps.setString(idx++, statusFilter);
                }
                ps.setInt(idx++, pageSize);
                ps.setInt(idx++, (currentPage - 1) * pageSize);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setStudentOrStaffNo(rs.getString("student_or_staff_no"));
                        user.setRealName(rs.getString("real_name"));
                        user.setNickname(rs.getString("nickname"));
                        user.setRoleCode(rs.getString("role_code"));
                        user.setAccountStatus(rs.getString("account_status"));
                        userList.add(user);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载用户列表失败：" + e.getMessage());
        }

        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;

        request.setAttribute("userList", userList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/admin-users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        String keyword = request.getParameter("keyword");
        String statusFilter = request.getParameter("status");

        if (userIdStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        int userId;
        try { userId = Integer.parseInt(userIdStr); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String newStatus;
        String successMsg;
        if ("disable".equals(action)) {
            newStatus = "DISABLED";
            successMsg = "用户已禁用";
        } else if ("enable".equals(action)) {
            newStatus = "ACTIVE";
            successMsg = "用户已启用";
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String sql = "UPDATE users SET account_status = ?, updated_at = NOW() WHERE user_id = ? AND role_code != 'ADMIN'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, userId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                request.getSession().setAttribute("successMsg", successMsg);
            } else {
                request.getSession().setAttribute("errorMsg", "操作失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/users?");
        if (keyword != null && !keyword.isEmpty()) redirectUrl.append("keyword=").append(keyword).append("&");
        if (statusFilter != null && !statusFilter.isEmpty()) redirectUrl.append("status=").append(statusFilter).append("&");
        response.sendRedirect(redirectUrl.toString());
    }
}
