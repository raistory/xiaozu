package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.*;

class ReportServletTest extends BaseServletTest {

    private final ReportServlet servlet = new ReportServlet();

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

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        servlet.doGet(request, response);

        assertNull(getRedirectUrl());
    }

    @Test
    void doPost_submitReport_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "submit");
        request.setParameter("productId", "1");
        request.setParameter("reason", "虚假商品");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_submitReport_ownProduct_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "submit");
        request.setParameter("productId", "1");
        request.setParameter("reason", "测试");
        servlet.doPost(request, response);

        assertEquals("不能举报自己的商品", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_takedown_adminCanTakedown() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertReport(1, 1, 2, "违规商品", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "takedown");
        request.setParameter("productId", "1");
        request.setParameter("reportId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_takedown_nonAdminDoesNotProcessAction() throws Exception {
        insertUser(1, "2024001", "普通用户", "user", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "卖家", "seller", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertReport(1, 1, 1, "违规商品", "PENDING");

        User user = createTestUser(1, "2024001", "普通用户", "user", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "takedown");
        request.setParameter("productId", "1");
        request.setParameter("reportId", "1");

        servlet.doPost(request, response);

        assertEquals("/index.jsp", getRedirectUrl());
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            try (ResultSet productRs = stmt.executeQuery(
                    "SELECT publish_status FROM products WHERE product_id = 1")) {
                assertTrue(productRs.next());
                assertEquals("ON_SALE", productRs.getString(1));
            }
            try (ResultSet reportRs = stmt.executeQuery(
                    "SELECT report_status FROM reports WHERE report_id = 1")) {
                assertTrue(reportRs.next());
                assertEquals("PENDING", reportRs.getString(1));
            }
        }
    }

    @Test
    void doPost_dismiss_adminCanDismiss() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertReport(1, 1, 2, "违规商品", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "dismiss");
        request.setParameter("reportId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
