package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.PasswordUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class LoginServletTest extends BaseServletTest {

    private final LoginServlet servlet = new LoginServlet();

    @Test
    void doGet_showsLoginPage() throws Exception {
        servlet.doGet(request, response);
        assertNull(getRedirectUrl());
    }

    @Test
    void doPost_emptyFields_showsError() throws Exception {
        request.setParameter("account", "");
        request.setParameter("password", "");
        servlet.doPost(request, response);
        assertEquals("请输入账号和密码", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_nonexistentAccount_showsError() throws Exception {
        request.setParameter("account", "nonexistent");
        request.setParameter("password", "123456");
        servlet.doPost(request, response);
        assertEquals("账号不存在", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_wrongPassword_showsError() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("correct"), "STUDENT", "ACTIVE");
        request.setParameter("account", "2024001");
        request.setParameter("password", "wrong");
        servlet.doPost(request, response);
        assertEquals("账号或密码错误", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_pendingUser_showsError() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("123456"), "STUDENT", "PENDING_VERIFY");
        request.setParameter("account", "2024001");
        request.setParameter("password", "123456");
        servlet.doPost(request, response);
        assertEquals("账号已注册，正在等待审核", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_disabledUser_showsError() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("123456"), "STUDENT", "DISABLED");
        request.setParameter("account", "2024001");
        request.setParameter("password", "123456");
        servlet.doPost(request, response);
        assertEquals("账号已被停用，请联系管理员", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_validLogin_redirectsToIndex() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");
        request.setParameter("account", "2024001");
        request.setParameter("password", "123456");
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("index"));
        User loginUser = (User) session.getAttribute("loginUser");
        assertNotNull(loginUser);
        assertEquals(1, loginUser.getUserId());
    }

    @Test
    void doPost_redirectAfterLogin_goesToOriginalPage() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");
        session.setAttribute("redirectAfterLogin", "/product-list");
        request.setParameter("account", "2024001");
        request.setParameter("password", "123456");
        servlet.doPost(request, response);
        assertTrue(getRedirectUrl().contains("product-list"));
    }
}
