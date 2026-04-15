package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;
import com.minzu.util.UploadUtil;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.*;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * /profile
 *   GET  -> 渲染个人信息编辑页 (profile.jsp)
 *   POST -> 保存昵称 / 联系方式 / 密码修改
 */
@WebServlet("/profile")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,   // 1MB
        maxFileSize = 5 * 1024 * 1024,     // 5MB per file
        maxRequestSize = 10 * 1024 * 1024  // 10MB total
)
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        // 从数据库重新读取最新信息（含 phone / email 等字段）
        String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, " +
                     "account_status, phone, email, avatar_url FROM users WHERE user_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    req.setAttribute("u_id",       rs.getInt("user_id"));
                    req.setAttribute("u_no",       rs.getString("student_or_staff_no"));
                    req.setAttribute("u_realName", rs.getString("real_name"));
                    req.setAttribute("u_nickname", rs.getString("nickname"));
                    req.setAttribute("u_phone",    rs.getString("phone"));
                    req.setAttribute("u_email",    rs.getString("email"));
                    req.setAttribute("u_role",     rs.getString("role_code"));
                    req.setAttribute("u_avatarUrl", rs.getString("avatar_url"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "读取用户信息失败：" + e.getMessage());
        }

        // 统计当前用户在售商品数、已售数、收藏数、获赞数
        try (Connection conn = DBUtil.getConnection()) {
            int uid = loginUser.getUserId();

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM products WHERE seller_id=? AND publish_status='ON_SALE' AND IFNULL(is_deleted,0)=0")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) req.setAttribute("productCount", rs.getInt(1)); }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM products WHERE seller_id=? AND publish_status='SOLD' AND IFNULL(is_deleted,0)=0")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) req.setAttribute("soldCount", rs.getInt(1)); }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM favorites WHERE user_id=?")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) req.setAttribute("favoriteCount", rs.getInt(1)); }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COALESCE(SUM(p.favorite_count),0) FROM products p WHERE p.seller_id=? AND IFNULL(p.is_deleted,0)=0")) {
                ps.setInt(1, uid);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) req.setAttribute("likeCount", rs.getInt(1)); }
            }
        } catch (Exception e) { e.printStackTrace(); }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        // --- Avatar upload (if present in a multipart request) ---
        try {
            Part avatarPart = req.getPart("avatar");
            if (avatarPart != null && avatarPart.getSize() > 0) {
                // Validate file extension
                String submittedFileName = Paths.get(avatarPart.getSubmittedFileName()).getFileName().toString();
                String ext = "";
                int dot = submittedFileName.lastIndexOf(".");
                if (dot != -1) ext = submittedFileName.substring(dot).toLowerCase();

                Set<String> allowedExts = new HashSet<>(Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp"));
                if (!allowedExts.contains(ext)) {
                    req.getSession().setAttribute("errorMsg", "仅支持 JPG、PNG、GIF、WebP 格式的头像");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                String uploadDir = UploadUtil.getUploadDir();
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                }

                String avatarUrl = UploadUtil.saveFile(avatarPart, uploadDir, req);

                String updateAvatarSql = "UPDATE users SET avatar_url=? WHERE user_id=?";
                try (Connection conn = DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(updateAvatarSql)) {
                    ps.setString(1, avatarUrl);
                    ps.setInt(2, loginUser.getUserId());
                    ps.executeUpdate();
                }

                // Update session User object so header reflects change immediately
                loginUser.setAvatarUrl(avatarUrl);

                req.getSession().setAttribute("successMsg", "头像已更新");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
        } catch (Exception e) {
            // Not a multipart request, or other error -- fall through to existing logic
        }

        String nickname    = req.getParameter("nickname");
        String phone       = req.getParameter("phone");
        String email       = req.getParameter("email");
        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPwd  = req.getParameter("confirmPassword");

        // --- 基本信息更新 ---
        String updateBaseSql = "UPDATE users SET nickname=?, phone=?, email=? WHERE user_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateBaseSql)) {
            ps.setString(1, (nickname != null && !nickname.trim().isEmpty()) ? nickname.trim() : null);
            ps.setString(2, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
            ps.setString(3, (email != null && !email.trim().isEmpty()) ? email.trim() : null);
            ps.setInt(4, loginUser.getUserId());
            ps.executeUpdate();

            // 同步 session 中的昵称
            if (nickname != null && !nickname.trim().isEmpty()) {
                loginUser.setNickname(nickname.trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "保存失败：" + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        // --- 密码修改（可选，仅当 oldPassword 非空时执行）---
        if (oldPassword != null && !oldPassword.trim().isEmpty()) {
            if (newPassword == null || newPassword.length() < 6 || newPassword.length() > 16) {
                req.getSession().setAttribute("errorMsg", "新密码须为 6-16 位");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
            if (!newPassword.equals(confirmPwd)) {
                req.getSession().setAttribute("errorMsg", "两次输入的新密码不一致");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
            // 验证旧密码
            String pwdSql = "SELECT password_hash FROM users WHERE user_id=?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(pwdSql)) {
                ps.setInt(1, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        req.getSession().setAttribute("errorMsg", "用户不存在");
                        resp.sendRedirect(req.getContextPath() + "/profile");
                        return;
                    }
                    String storedHash = rs.getString("password_hash");
                    boolean valid;
                    // 兼容明文（旧数据）和 BCrypt（新数据）
                    if (storedHash != null && storedHash.startsWith("$2")) {
                        valid = BCrypt.checkpw(oldPassword.trim(), storedHash);
                    } else {
                        valid = oldPassword.trim().equals(storedHash);
                    }
                    if (!valid) {
                        req.getSession().setAttribute("errorMsg", "旧密码错误");
                        resp.sendRedirect(req.getContextPath() + "/profile");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("errorMsg", "密码验证失败：" + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
            // 更新密码（写入 BCrypt 哈希）
            String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            String updPwdSql = "UPDATE users SET password_hash=? WHERE user_id=?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updPwdSql)) {
                ps.setString(1, newHash);
                ps.setInt(2, loginUser.getUserId());
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("errorMsg", "密码更新失败：" + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
        }

        req.getSession().setAttribute("successMsg", "个人信息已保存");
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return u;
    }
}
