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

class OfferServletTest extends BaseServletTest {

    private final OfferServlet servlet = new OfferServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_sentTab_showsSentOffers() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 1, 2, "5000.00", "PENDING");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("tab", "sent");
        servlet.doGet(request, response);

        List<?> offers = (List<?>) request.getAttribute("offerList");
        assertEquals(1, offers.size());
    }

    @Test
    void doGet_receivedTab_showsReceivedOffers() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("tab", "received");
        servlet.doGet(request, response);

        List<?> offers = (List<?>) request.getAttribute("offerList");
        assertEquals(1, offers.size());
    }

    @Test
    void doPost_createOffer_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        request.setParameter("offerPrice", "5000");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_createOffer_ownProduct_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        request.setParameter("offerPrice", "5000");
        servlet.doPost(request, response);

        assertEquals("不能对自己的商品出价", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_acceptOffer_createsOrder() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "accept");
        request.setParameter("offerId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            try (ResultSet orderRs = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE product_id = 1")) {
                assertTrue(orderRs.next());
                assertEquals(1, orderRs.getInt(1));
            }
            try (ResultSet productRs = stmt.executeQuery(
                    "SELECT publish_status FROM products WHERE product_id = 1")) {
                assertTrue(productRs.next());
                assertEquals("OFF_SHELF", productRs.getString(1));
            }
        }
    }

    @Test
    void doPost_acceptOffer_withActiveOrder_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");
        insertOrder(1, "ORD001", 1, 2, 1, "5999.00", "CREATED");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "accept");
        request.setParameter("offerId", "1");
        servlet.doPost(request, response);

        assertEquals("该商品已有进行中的订单，无法再接受出价", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_rejectOffer_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "reject");
        request.setParameter("offerId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
