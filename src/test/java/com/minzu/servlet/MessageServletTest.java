package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class MessageServletTest extends BaseServletTest {

    private final MessageServlet servlet = new MessageServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_conversationList_doesNotRedirect() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertConversation(1, 1, 2, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        assertNull(getRedirectUrl());
        assertNotNull(request.getAttribute("conversations"));
    }

    @Test
    void doGet_withConversationId_doesNotRedirect() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertConversation(1, 1, 2, 1);
        insertMessage(1, 2, "你好，还在吗？", false);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("conversationId", "1");
        servlet.doGet(request, response);

        assertNull(getRedirectUrl());
        assertNotNull(request.getAttribute("chatList"));
    }

    @Test
    void doPost_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doPost_sendMessage_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertConversation(1, 1, 2, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("conversationId", "1");
        request.setParameter("content", "还在的");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("messages"));

        try (var conn = java.sql.DriverManager.getConnection("jdbc:h2:mem:shared_test;MODE=MySQL;DB_CLOSE_DELAY=-1");
             var stmt = conn.createStatement();
             var rs = stmt.executeQuery("SELECT COUNT(*) FROM messages WHERE conversation_id = 1")) {
            rs.next();
            assertEquals(1, rs.getInt(1));
        }
    }

    @Test
    void doPost_sendMessage_fromNonParticipant_isRejected() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertUser(3, "2024003", "王五", "wangwu", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertConversation(1, 1, 2, 1);

        User outsider = createTestUser(3, "2024003", "王五", "wangwu", "STUDENT", "ACTIVE");
        loginUser(outsider);
        request.setParameter("conversationId", "1");
        request.setParameter("content", "我也来插一句");
        servlet.doPost(request, response);

        assertEquals("无权向该会话发送消息", session.getAttribute("errorMsg"));
        try (var conn = java.sql.DriverManager.getConnection("jdbc:h2:mem:shared_test;MODE=MySQL;DB_CLOSE_DELAY=-1");
             var stmt = conn.createStatement();
             var rs = stmt.executeQuery("SELECT COUNT(*) FROM messages WHERE conversation_id = 1")) {
            rs.next();
            assertEquals(0, rs.getInt(1));
        }
    }

    @Test
    void doPost_emptyContent_redirectsBack() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("conversationId", "1");
        request.setParameter("content", "");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
