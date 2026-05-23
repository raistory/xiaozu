package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class IndexServletTest extends BaseServletTest {

    private final IndexServlet servlet = new IndexServlet();

    @Test
    void doGet_notLoggedIn_showsLatestProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("latestProducts");
        assertNotNull(products);
        assertEquals(1, products.size());
        assertNull(getRedirectUrl());
    }

    @Test
    void doGet_loggedIn_showsLatestProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("latestProducts");
        assertNotNull(products);
        assertEquals(1, products.size());
    }

    @Test
    void doGet_loggedIn_noProducts_showsEmptyList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("latestProducts");
        assertNotNull(products);
        assertTrue(products.isEmpty());
    }
}
