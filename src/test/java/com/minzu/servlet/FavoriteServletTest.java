package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class FavoriteServletTest extends BaseServletTest {

    private final FavoriteServlet servlet = new FavoriteServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_myFavorites_showsList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertFavorite(1, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setRequestURI("/my-favorites");
        servlet.doGet(request, response);

        List<?> favorites = (List<?>) request.getAttribute("favoriteList");
        assertNotNull(favorites);
        assertEquals(1, favorites.size());
    }

    @Test
    void doPost_notLoggedIn_returnsNeedLogin() throws Exception {
        response.setContentType("application/json;charset=UTF-8");
        servlet.doPost(request, response);
        String body = response.getContentAsString();
        assertTrue(body.contains("needLogin"));
    }

    @Test
    void doPost_addFavorite_returnsSuccess() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        String body = response.getContentAsString();
        assertTrue(body.contains("success"));
        assertTrue(body.contains("favorited"));
    }

    @Test
    void doPost_removeFavorite_returnsSuccess() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertFavorite(1, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        String body = response.getContentAsString();
        assertTrue(body.contains("success"));
    }
}
