package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpSession;

import static org.junit.jupiter.api.Assertions.*;

class LogoutServletTest extends BaseServletTest {

    private final LogoutServlet servlet = new LogoutServlet();

    @Test
    void doGet_invalidatesSessionAndRedirects() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        assertNotNull(session.getAttribute("loginUser"));

        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_noSession_stillRedirects() throws Exception {
        MockHttpSession emptySession = new MockHttpSession();
        request.setSession(emptySession);
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }
}
