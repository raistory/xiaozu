package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DeleteProductServletTest extends BaseServletTest {

    private final DeleteProductServlet servlet = new DeleteProductServlet();

    @Test
    void doPost_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doPost(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doPost_noProductId_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doPost(request, response);
        assertEquals("商品ID不能为空", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_invalidProductId_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "abc");
        servlet.doPost(request, response);
        assertEquals("商品ID格式错误", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_nonexistentProduct_showsError() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "999");
        servlet.doPost(request, response);
        assertEquals("商品不存在", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_ownerCanDelete() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        assertEquals("商品删除成功", session.getAttribute("successMsg"));
    }

    @Test
    void doPost_nonOwnerCannotDelete() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User other = createTestUser(2, "2024002", "李四", "lisi", "STUDENT", "ACTIVE");
        loginUser(other);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertEquals("你无权删除该商品", request.getAttribute("errorMsg"));
    }

    @Test
    void doPost_adminCanDelete() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User admin = createTestUser(2, "2024002", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
        assertEquals("商品删除成功", session.getAttribute("successMsg"));
    }

    @Test
    void doPost_alreadyDeleted_showsError() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        executeSql("INSERT INTO products (product_id, seller_id, category_id, title, price, publish_status, is_deleted) " +
                "VALUES (1, 1, 1, 'iPhone', 5999.00, 'ON_SALE', 1)");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("productId", "1");
        servlet.doPost(request, response);

        assertEquals("该商品已被删除", request.getAttribute("errorMsg"));
    }
}
