package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class ProductListServletTest extends BaseServletTest {

    private final ProductListServlet servlet = new ProductListServlet();

    @Test
    void doGet_noProducts_showsEmptyList() throws Exception {
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertNotNull(products);
        assertTrue(products.isEmpty());
    }

    @Test
    void doGet_withProducts_showsList() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertNotNull(products);
        assertEquals(1, products.size());
    }

    @Test
    void doGet_withKeyword_filtersProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertProduct(2, 1, 1, "MacBook Pro", "12999.00", "ON_SALE");

        request.setParameter("keyword", "iPhone");
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(1, products.size());
    }

    @Test
    void doGet_withCategoryFilter_filtersProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertCategory(2, "书籍教材");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertProduct(2, 1, 2, "数据结构", "35.00", "ON_SALE");

        request.setParameter("categoryId", "1");
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(1, products.size());
    }

    @Test
    void doGet_withCategoryNameFilter_filtersProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertCategory(2, "书籍教材");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertProduct(2, 1, 2, "数据结构", "35.00", "ON_SALE");

        request.setParameter("category", "书籍教材");
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(1, products.size());
        assertEquals(1, request.getAttribute("totalCount"));
    }

    @Test
    void doGet_withInvalidCategoryId_ignoresBadFilter() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        request.setParameter("categoryId", "abc");
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(1, products.size());
        assertNull(request.getAttribute("categoryId"));
    }

    @Test
    void doGet_withSort_sortsProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "便宜货", "10.00", "ON_SALE");
        insertProduct(2, 1, 1, "贵重物", "9999.00", "ON_SALE");

        request.setParameter("sort", "price_asc");
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(2, products.size());
    }

    @Test
    void doGet_withPriceRange_filtersProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "便宜货", "10.00", "ON_SALE");
        insertProduct(2, 1, 1, "贵重物", "9999.00", "ON_SALE");

        request.setParameter("minPrice", "100");
        request.setParameter("maxPrice", "10000");
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(1, products.size());
    }

    @Test
    void doGet_withFavorites_showsFavoriteStatus() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertFavorite(1, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);

        servlet.doGet(request, response);
        Set<?> favoriteIds = (Set<?>) request.getAttribute("favoriteProductIds");
        assertNotNull(favoriteIds);
        assertTrue(favoriteIds.contains(1));
    }

    @Test
    void doGet_pagination_works() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        for (int i = 1; i <= 15; i++) {
            insertProduct(i, 1, 1, "商品" + i, "10.00", "ON_SALE");
        }

        request.setParameter("page", "2");
        servlet.doGet(request, response);
        List<?> products = (List<?>) request.getAttribute("products");
        assertEquals(3, products.size());
        assertEquals(2, request.getAttribute("currentPage"));
    }
}
