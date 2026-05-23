package com.minzu.servlet;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ZoneServletTest extends BaseServletTest {

    private final ZoneServlet servlet = new ZoneServlet();

    @Test
    void doGet_graduationZone_showsProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "毕业甩卖", "100.00", "ON_SALE");
        executeSql("UPDATE products SET is_graduation_zone = 1 WHERE product_id = 1");

        request.setParameter("type", "graduation");
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("productList");
        assertNotNull(products);
        assertEquals(1, products.size());
    }

    @Test
    void doGet_textbookZone_showsProducts() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "书籍教材");
        insertProduct(1, 1, 1, "数据结构教材", "35.00", "ON_SALE");
        executeSql("UPDATE products SET is_textbook_zone = 1 WHERE product_id = 1");

        request.setParameter("type", "textbook");
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("productList");
        assertNotNull(products);
        assertEquals(1, products.size());
    }

    @Test
    void doGet_defaultType_isGraduation() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "毕业甩卖", "100.00", "ON_SALE");
        executeSql("UPDATE products SET is_graduation_zone = 1 WHERE product_id = 1");

        servlet.doGet(request, response);

        assertEquals("graduation", request.getAttribute("type"));
    }

    @Test
    void doGet_emptyZone_showsEmptyList() throws Exception {
        servlet.doGet(request, response);

        List<?> products = (List<?>) request.getAttribute("productList");
        assertNotNull(products);
        assertTrue(products.isEmpty());
    }
}
