package com.minzu.servlet;

import com.minzu.entity.Message;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /messages                     GET  -> 会话列表
 * /messages?with={uid}&productId={pid}  GET  -> 查找/创建会话 → 重定向到 conversationId
 * /messages?conversationId={cid}  GET  -> 加载指定会话聊天记录
 * /messages                     POST -> 发送消息（conversationId + content）
 */
@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

    private static final int CHAT_PAGE_SIZE = 50;

    // ==================== GET ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String withStr      = request.getParameter("with");
        String productIdStr = request.getParameter("productId");
        String convIdStr    = request.getParameter("conversationId");

        if (convIdStr != null && !convIdStr.trim().isEmpty()) {
            // 已有会话 → 直接加载聊天记录
            showChatByConversationId(request, response, loginUser, convIdStr);
        } else if (withStr != null && !withStr.trim().isEmpty()) {
            // 从商品详情页进入 → 查找或创建会话，重定向到 conversationId
            redirectToConversation(request, response, loginUser, withStr, productIdStr);
        } else {
            showConversationList(request, response, loginUser);
        }
    }

    // ==================== POST ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String convIdStr = request.getParameter("conversationId");
        String content   = request.getParameter("content");

        if (convIdStr == null || content == null || content.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        long conversationId;
        try {
            conversationId = Long.parseLong(convIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        String sql = "INSERT INTO messages (conversation_id, sender_id, message_type, message_content, is_read, created_at) " +
                     "VALUES (?, ?, 'TEXT', ?, 0, NOW())";

        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT 1 FROM conversations WHERE conversation_id = ? AND (buyer_id = ? OR seller_id = ?)";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setLong(1, conversationId);
                checkPs.setInt(2, loginUser.getUserId());
                checkPs.setInt(3, loginUser.getUserId());
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        request.getSession().setAttribute("errorMsg", "无权向该会话发送消息");
                        response.sendRedirect(request.getContextPath() + "/messages");
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, conversationId);
            ps.setInt(2, loginUser.getUserId());
            ps.setString(3, content.trim());
            ps.executeUpdate();
            }

            // 更新会话最后消息时间
            String updateConv = "UPDATE conversations SET last_message_at = NOW() WHERE conversation_id = ?";
            try (PreparedStatement up = conn.prepareStatement(updateConv)) {
                up.setLong(1, conversationId);
                up.executeUpdate();
            }

            request.getSession().setAttribute("successMsg", "消息已发送");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "发送失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/messages?conversationId=" + conversationId);
    }

    // ========== 会话列表 ==========
    private void showConversationList(HttpServletRequest request, HttpServletResponse response,
                                      User loginUser) throws ServletException, IOException {
        int me = loginUser.getUserId();

        String sql =
            "SELECT " +
            "  c.conversation_id, " +
            "  c.product_id, " +
            "  IF(c.buyer_id = ?, c.seller_id, c.buyer_id) AS other_id, " +
            "  u.nickname AS other_nickname, " +
            "  (SELECT m.message_content FROM messages m " +
            "   WHERE m.conversation_id = c.conversation_id " +
            "   ORDER BY m.created_at DESC LIMIT 1) AS last_content, " +
            "  c.last_message_at AS last_time, " +
            "  COALESCE((SELECT COUNT(*) FROM messages m " +
            "   WHERE m.conversation_id = c.conversation_id " +
            "   AND m.sender_id != ? AND m.is_read = 0), 0) AS unread_count " +
            "FROM conversations c " +
            "JOIN users u ON u.user_id = IF(c.buyer_id = ?, c.seller_id, c.buyer_id) " +
            "WHERE c.buyer_id = ? OR c.seller_id = ? " +
            "ORDER BY c.last_message_at DESC";

        List<Map<String, Object>> conversations = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, me);
            ps.setInt(2, me);
            ps.setInt(3, me);
            ps.setInt(4, me);
            ps.setInt(5, me);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> conv = new LinkedHashMap<>();
                    conv.put("conversationId", rs.getLong("conversation_id"));
                    conv.put("productId",      rs.getLong("product_id"));
                    conv.put("otherId",        rs.getInt("other_id"));
                    conv.put("otherNickname",  rs.getString("other_nickname"));
                    conv.put("lastContent",    rs.getString("last_content"));
                    conv.put("lastTime",       rs.getTimestamp("last_time"));
                    conv.put("unreadCount",    rs.getInt("unread_count"));
                    conversations.add(conv);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载私信列表失败：" + e.getMessage());
        }

        request.setAttribute("conversations", conversations);
        request.getRequestDispatcher("/messages.jsp").forward(request, response);
    }

    // ========== 查找/创建会话 → 重定向 ==========
    private void redirectToConversation(HttpServletRequest request, HttpServletResponse response,
                                        User loginUser, String withStr, String productIdStr)
            throws IOException {
        int me = loginUser.getUserId();
        int otherId;
        try {
            otherId = Integer.parseInt(withStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }
        if (otherId == me) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        long productId;
        try {
            productId = Long.parseLong(productIdStr != null ? productIdStr.trim() : "0");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }
        if (productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 确定谁是 seller（商品拥有者），谁是 buyer（另一方）
            int sellerId;
            String prodSql = "SELECT seller_id FROM products WHERE product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(prodSql)) {
                ps.setLong(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        request.getSession().setAttribute("errorMsg", "商品不存在");
                        response.sendRedirect(request.getContextPath() + "/messages");
                        return;
                    }
                    sellerId = rs.getInt("seller_id");
                }
            }

            // 验证：两个用户中必须有一个是商品卖家
            if (sellerId != me && sellerId != otherId) {
                request.getSession().setAttribute("errorMsg", "无权发起此会话");
                response.sendRedirect(request.getContextPath() + "/messages");
                return;
            }

            int buyerId = (sellerId == me) ? otherId : me;

            // 查找已有会话
            String findSql = "SELECT conversation_id FROM conversations " +
                            "WHERE product_id = ? AND buyer_id = ? AND seller_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setLong(1, productId);
                ps.setInt(2, buyerId);
                ps.setInt(3, sellerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long convId = rs.getLong("conversation_id");
                        response.sendRedirect(request.getContextPath() + "/messages?conversationId=" + convId);
                        return;
                    }
                }
            }

            // 不存在则新建会话
            String insertSql = "INSERT INTO conversations (product_id, buyer_id, seller_id) VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, productId);
                ps.setInt(2, buyerId);
                ps.setInt(3, sellerId);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        long newConvId = rs.getLong(1);
                        response.sendRedirect(request.getContextPath() + "/messages?conversationId=" + newConvId);
                        return;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "创建会话失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/messages");
    }

    // ========== 加载聊天记录 ==========
    private void showChatByConversationId(HttpServletRequest request, HttpServletResponse response,
                                          User loginUser, String convIdStr)
            throws ServletException, IOException {
        long conversationId;
        try {
            conversationId = Long.parseLong(convIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        int me = loginUser.getUserId();

        try (Connection conn = DBUtil.getConnection()) {
            // 验证会话归属
            String checkSql = "SELECT product_id, buyer_id, seller_id " +
                             "FROM conversations WHERE conversation_id = ?";
            long productId;
            int buyerId, sellerId;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, conversationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/messages");
                        return;
                    }
                    productId = rs.getLong("product_id");
                    buyerId   = rs.getInt("buyer_id");
                    sellerId  = rs.getInt("seller_id");
                }
            }

            if (me != buyerId && me != sellerId) {
                response.sendRedirect(request.getContextPath() + "/messages");
                return;
            }

            int otherId = (me == buyerId) ? sellerId : buyerId;

            // 获取对方昵称
            String userSql = "SELECT nickname FROM users WHERE user_id = ?";
            String otherNickname = "用户" + otherId;
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setInt(1, otherId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) otherNickname = rs.getString("nickname");
                }
            }

            // 获取商品信息
            Map<String, Object> product = null;
            String pSql = "SELECT product_id, title, cover_image_url, price " +
                          "FROM products WHERE product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(pSql)) {
                ps.setLong(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        product = new LinkedHashMap<>();
                        product.put("productId", rs.getLong("product_id"));
                        product.put("title",     rs.getString("title"));
                        product.put("coverUrl",  rs.getString("cover_image_url"));
                        product.put("price",     rs.getBigDecimal("price"));
                    }
                }
            }

            // 分页
            int chatPage = 1;
            try {
                String pageStr = request.getParameter("chatPage");
                if (pageStr != null) chatPage = Math.max(1, Integer.parseInt(pageStr.trim()));
            } catch (NumberFormatException ignored) {}

            String countSql = "SELECT COUNT(*) FROM messages WHERE conversation_id = ?";
            int totalMsgCount = 0;
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setLong(1, conversationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalMsgCount = rs.getInt(1);
                }
            }

            int totalChatPages = Math.max(1, (int) Math.ceil((double) totalMsgCount / CHAT_PAGE_SIZE));
            if (chatPage > totalChatPages) chatPage = totalChatPages;
            int chatOffset = (chatPage - 1) * CHAT_PAGE_SIZE;

            // 加载消息（message_content 别名 content 匹配 Message 实体）
            String msgSql =
                "SELECT m.message_id, m.sender_id, m.message_content AS content, " +
                "       m.is_read, m.created_at, " +
                "       s.nickname AS sender_nickname " +
                "FROM messages m " +
                "JOIN users s ON s.user_id = m.sender_id " +
                "WHERE m.conversation_id = ? " +
                "ORDER BY m.created_at ASC LIMIT ? OFFSET ?";

            List<Message> chatList = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(msgSql)) {
                ps.setLong(1, conversationId);
                ps.setInt(2, CHAT_PAGE_SIZE);
                ps.setInt(3, chatOffset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Message msg = new Message();
                        msg.setMessageId(rs.getInt("message_id"));
                        msg.setSenderId(rs.getInt("sender_id"));
                        msg.setContent(rs.getString("content"));   // 别名来自 message_content
                        msg.setRead(rs.getBoolean("is_read"));
                        msg.setCreatedAt(rs.getTimestamp("created_at"));
                        msg.setSenderNickname(rs.getString("sender_nickname"));
                        chatList.add(msg);
                    }
                }
            }

            // 标记对方消息为已读
            String markSql = "UPDATE messages SET is_read = 1 " +
                             "WHERE conversation_id = ? AND sender_id != ? AND is_read = 0";
            try (PreparedStatement ps = conn.prepareStatement(markSql)) {
                ps.setLong(1, conversationId);
                ps.setInt(2, me);
                ps.executeUpdate();
            }

            request.setAttribute("conversationId", conversationId);
            request.setAttribute("otherId",        otherId);
            request.setAttribute("otherNickname",  otherNickname);
            request.setAttribute("product",        product);
            request.setAttribute("productId",      productId);
            request.setAttribute("chatList",       chatList);
            request.setAttribute("chatPage",       chatPage);
            request.setAttribute("totalChatPages", totalChatPages);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载聊天记录失败：" + e.getMessage());
        }

        request.getRequestDispatcher("/message-chat.jsp").forward(request, response);
    }
}
