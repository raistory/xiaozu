package com.minzu.servlet;

import com.minzu.entity.Product;
import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class MyProductsServletTest extends BaseServletTest {

    private final MyProductsServlet servlet = new MyProductsServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_showsUserProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertProduct(2, 1, 1, "MacBook", "12999.00", "OFF_SHELF");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("productList");
        assertEquals(2, products.size());
    }

    @Test
    void doGet_withStatusFilter_filtersProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertProduct(2, 1, 1, "MacBook", "12999.00", "OFF_SHELF");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("status", "ON_SALE");
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("productList");
        assertEquals(1, products.size());
    }

    @Test
    void doPost_offshelf_updatesStatus() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "offshelf");
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_onshelf_updatesStatus() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "OFF_SHELF");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "onshelf");
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }
}
