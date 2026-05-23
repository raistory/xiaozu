package com.minzu.servlet;

import com.minzu.util.PasswordUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RegisterServletTest extends BaseServletTest {

    private final RegisterServlet servlet = new RegisterServlet();

    @Test
    void doGet_showsRegisterPage() throws Exception {
        servlet.doGet(request, response);
        assertNull(getRedirectUrl());
    }

    @Test
    void doPost_missingFields_showsError() throws Exception {
        request.setParameter("studentOrStaffNo", "");
        request.setParameter("realName", "");
        request.setParameter("password", "");
        request.setParameter("confirmPassword", "");
        servlet.doPost(request, response);
        assertEquals("请把必填项填写完整", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_passwordMismatch_showsError() throws Exception {
        request.setParameter("studentOrStaffNo", "2024001");
        request.setParameter("realName", "张三");
        request.setParameter("password", "123456");
        request.setParameter("confirmPassword", "654321");
        servlet.doPost(request, response);
        assertEquals("两次输入的密码不一致", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_duplicateAccount_showsError() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan",
                PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");
        request.setParameter("studentOrStaffNo", "2024001");
        request.setParameter("realName", "李四");
        request.setParameter("password", "123456");
        request.setParameter("confirmPassword", "123456");
        servlet.doPost(request, response);
        assertEquals("该学号/工号已注册，请直接登录", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_validRegistration_redirectsToLogin() throws Exception {
        request.setParameter("studentOrStaffNo", "2024002");
        request.setParameter("realName", "李四");
        request.setParameter("nickname", "lisi");
        request.setParameter("password", "123456");
        request.setParameter("confirmPassword", "123456");
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
        assertEquals("注册成功，请登录", session.getAttribute("successMsg"));
    }
}
