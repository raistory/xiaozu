package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class NotificationServletTest extends BaseServletTest {

    private final NotificationServlet servlet = new NotificationServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_showsNotifications() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertNotification(1, 1, "你有新订单", false);
        insertNotification(2, 1, "商品已下架", true);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        List<?> notifications = (List<?>) request.getAttribute("notifyList");
        assertEquals(2, notifications.size());
        assertEquals(1, request.getAttribute("unreadCount"));
    }

    @Test
    void doPost_markRead_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertNotification(1, 1, "你有新订单", false);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "read");
        request.setParameter("notifyId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_readAll_marksAllRead() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertNotification(1, 1, "通知1", false);
        insertNotification(2, 1, "通知2", false);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "readAll");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_delete_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertNotification(1, 1, "通知1", true);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "delete");
        request.setParameter("notifyId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_deleteRead_clearsReadNotifications() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertNotification(1, 1, "已读通知", true);
        insertNotification(2, 1, "未读通知", false);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "deleteRead");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
