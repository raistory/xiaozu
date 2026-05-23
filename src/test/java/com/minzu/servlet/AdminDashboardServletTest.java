package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AdminDashboardServletTest extends BaseServletTest {

    private final AdminDashboardServlet servlet = new AdminDashboardServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_nonAdmin_redirectsToIndex() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
    }

    @Test
    void doGet_admin_doesNotRedirect() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        servlet.doGet(request, response);

        assertNull(getRedirectUrl());
    }
}
