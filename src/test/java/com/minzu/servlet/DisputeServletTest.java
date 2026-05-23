package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.*;

class DisputeServletTest extends BaseServletTest {

    private final DisputeServlet servlet = new DisputeServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_myDisputes_showsList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 1, 2, "5999.00", "CREATED");
        insertDispute(1, 1, 1, "商品有问题", "PENDING");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        var disputes = request.getAttribute("disputeList");
        assertNotNull(disputes);
    }

    @Test
    void doGet_adminView_showsAllDisputes() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(3, "2024003", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 3, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 2, 3, "5999.00", "CREATED");
        insertDispute(1, 1, 2, "商品有问题", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "admin");
        servlet.doGet(request, response);

        var disputes = request.getAttribute("disputeList");
        assertNotNull(disputes);
    }

    @Test
    void doPost_submitDispute_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 1, 2, "5999.00", "CREATED");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "submit");
        request.setParameter("orderId", "1");
        request.setParameter("reason", "商品与描述不符");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_resolveDispute_refund() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(3, "2024003", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 3, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 2, 3, "5999.00", "DISPUTED");
        insertDispute(1, 1, 2, "商品有问题", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "resolve");
        request.setParameter("disputeId", "1");
        request.setParameter("result", "REFUND");
        request.setParameter("adminNote", "同意退款");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT publish_status FROM products WHERE product_id = 1")) {
            assertTrue(rs.next());
            assertEquals("ON_SALE", rs.getString(1));
        }
    }
}
