package com.minzu.servlet;

import com.minzu.entity.Product;
import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ProductDetailServletTest extends BaseServletTest {

    private final ProductDetailServlet servlet = new ProductDetailServlet();

    @Test
    void doGet_notLoggedIn_withoutProductId_showsError() throws Exception {
        servlet.doGet(request, response);
        assertEquals("商品ID不能为空", request.getAttribute("errorMsg"));
        assertNull(getRedirectUrl());
    }

    @Test
    void doGet_notLoggedIn_validProduct_showsDetail() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        request.setParameter("id", "1");
        servlet.doGet(request, response);

        Product product = (Product) request.getAttribute("product");
        assertNotNull(product);
        assertEquals("iPhone 15", product.getTitle());
        assertEquals(Boolean.FALSE, request.getAttribute("isFavorited"));
    }

    @Test
    void doGet_noProductId_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);
        assertEquals("商品ID不能为空", request.getAttribute("errorMsg"));
    }

    @Test
    void doGet_invalidProductId_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "abc");
        servlet.doGet(request, response);
        assertEquals("商品ID格式错误", request.getAttribute("errorMsg"));
    }

    @Test
    void doGet_nonexistentProduct_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "999");
        servlet.doGet(request, response);
        assertEquals("商品不存在或已下架", request.getAttribute("errorMsg"));
    }

    @Test
    void doGet_validProduct_showsDetail() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "1");
        servlet.doGet(request, response);

        Product product = (Product) request.getAttribute("product");
        assertNotNull(product);
        assertEquals("iPhone 15", product.getTitle());
    }

    @Test
    void doGet_incrementsViewCount() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "1");
        servlet.doGet(request, response);

        Product product = (Product) request.getAttribute("product");
        assertTrue(product.getViewCount() >= 1);
    }

    @Test
    void doGet_withFavorite_showsFavoriteStatus() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertFavorite(1, 1);

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "1");
        servlet.doGet(request, response);

        assertTrue((Boolean) request.getAttribute("isFavorited"));
    }

    @Test
    void doGet_withComments_showsComments() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertComment(1, 1, 2, "这个还在吗？", null);

        User user = createTestUser(2, "2024002", "李四", "lisi", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("id", "1");
        servlet.doGet(request, response);

        List<?> comments = (List<?>) request.getAttribute("comments");
        assertNotNull(comments);
        assertEquals(1, comments.size());
    }
}
