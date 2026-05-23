package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class OrderServletTest extends BaseServletTest {

    private final OrderServlet servlet = new OrderServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_buyOrders_showsList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 1, 2, "5999.00", "CREATED");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("type", "buy");
        servlet.doGet(request, response);

        List<?> orders = (List<?>) request.getAttribute("orderList");
        assertEquals(1, orders.size());
    }

    @Test
    void doGet_sellOrders_showsList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 2, 1, "5999.00", "CREATED");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("type", "sell");
        servlet.doGet(request, response);

        List<?> orders = (List<?>) request.getAttribute("orderList");
        assertEquals(1, orders.size());
    }

    @Test
    void doPost_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doPost_createOrder_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("orders"));
    }

    @Test
    void doPost_createOwnProduct_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertEquals("不能购买自己的商品", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_cancelOrder_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 1, 2, "5999.00", "CREATED");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "cancel");
        request.setParameter("orderId", "1");
        request.setParameter("type", "buy");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_cancelReservedOfferOrder_restoresProductOnSale() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "OFF_SHELF");
        insertOrder(1, "ORD001", 1, 1, 2, "5999.00", "CREATED");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "cancel");
        request.setParameter("orderId", "1");
        request.setParameter("type", "buy");
        servlet.doPost(request, response);

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT publish_status FROM products WHERE product_id = 1")) {
            assertTrue(rs.next());
            assertEquals("ON_SALE", rs.getString(1));
        }
    }

    @Test
    void doPost_payOrder_sellerConfirms() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOrder(1, "ORD001", 1, 2, 1, "5999.00", "CREATED");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "paid");
        request.setParameter("orderId", "1");
        request.setParameter("type", "sell");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
