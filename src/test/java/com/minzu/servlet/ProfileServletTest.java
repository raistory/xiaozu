package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.PasswordUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ProfileServletTest extends BaseServletTest {

    private final ProfileServlet servlet = new ProfileServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_showsProfile() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        assertEquals(1, request.getAttribute("u_id"));
        assertEquals("2024001", request.getAttribute("u_no"));
        assertEquals("张三", request.getAttribute("u_realName"));
    }

    @Test
    void doGet_showsStatistics() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone", "5999.00", "ON_SALE");
        insertProduct(2, 1, 1, "MacBook", "12999.00", "SOLD");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        assertEquals(1, request.getAttribute("productCount"));
        assertEquals(1, request.getAttribute("soldCount"));
    }

    @Test
    void doPost_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doPost_updateProfile_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("nickname", "新昵称");
        request.setParameter("phone", "13800138000");
        request.setParameter("email", "test@example.com");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        assertEquals("个人信息已保存", session.getAttribute("successMsg"));
    }

    @Test
    void doPost_changePassword_wrongOldPassword() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("nickname", "张三");
        request.setParameter("oldPassword", "wrong");
        request.setParameter("newPassword", "654321");
        request.setParameter("confirmPassword", "654321");
        servlet.doPost(request, response);

        assertEquals("旧密码错误", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_changePassword_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("nickname", "张三");
        request.setParameter("oldPassword", "123456");
        request.setParameter("newPassword", "654321");
        request.setParameter("confirmPassword", "654321");
        servlet.doPost(request, response);

        assertEquals("个人信息已保存", session.getAttribute("successMsg"));
    }

    @Test
    void doPost_changePassword_mismatch() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", PasswordUtil.hash("123456"), "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("nickname", "张三");
        request.setParameter("oldPassword", "123456");
        request.setParameter("newPassword", "654321");
        request.setParameter("confirmPassword", "111111");
        servlet.doPost(request, response);

        assertEquals("两次输入的新密码不一致", session.getAttribute("errorMsg"));
    }
}
