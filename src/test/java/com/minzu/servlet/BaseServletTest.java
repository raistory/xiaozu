package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockHttpSession;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServletRequest;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public abstract class BaseServletTest {

    private static final String H2_URL = "jdbc:h2:mem:shared_test;MODE=MySQL;DB_CLOSE_DELAY=-1";
    protected MockHttpServletRequest request;
    protected MockHttpServletResponse response;
    protected MockHttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        Class.forName("org.h2.Driver");

        try (Connection conn = DriverManager.getConnection(H2_URL);
             Statement stmt = conn.createStatement()) {
            // Drop all tables first for clean state
            String[] tables = {"offers", "product_comments", "admin_profiles", "admin_action_logs",
                    "pickup_locations", "disputes", "reports", "notifications", "messages",
                    "conversations", "reviews", "order_status_logs", "orders",
                    "favorites", "product_favorites", "product_images", "products",
                    "pickup_points", "categories", "users"};
            for (String table : tables) {
                stmt.execute("DROP TABLE IF EXISTS " + table);
            }

            String schema = Files.readString(Path.of("src/test/resources/schema-h2.sql"));
            for (String sql : schema.split(";")) {
                sql = sql.trim();
                if (!sql.isEmpty()) {
                    stmt.execute(sql);
                }
            }
        }

        // Each call to getConnection returns a NEW connection to the same shared in-memory DB
        DBUtil.setConnectionSupplier(() -> DriverManager.getConnection(H2_URL));

        request = new MockHttpServletRequest();
        response = new MockHttpServletResponse();
        session = new MockHttpSession();
        request.setSession(session);
        request.setContextPath("");
    }

    @AfterEach
    void tearDown() {
        DBUtil.setConnectionSupplier(null);
    }

    protected void executeSql(String sql) throws Exception {
        try (Connection conn = DriverManager.getConnection(H2_URL);
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        }
    }

    protected User createTestUser(int userId, String studentNo, String realName, String nickname,
                                   String roleCode, String accountStatus) {
        User user = new User();
        user.setUserId(userId);
        user.setStudentOrStaffNo(studentNo);
        user.setRealName(realName);
        user.setNickname(nickname);
        user.setRoleCode(roleCode);
        user.setAccountStatus(accountStatus);
        return user;
    }

    protected void insertUser(int userId, String studentNo, String realName, String nickname,
                               String passwordHash, String roleCode, String accountStatus) throws Exception {
        executeSql("INSERT INTO users (user_id, student_or_staff_no, real_name, nickname, password_hash, role_code, account_status) " +
                "VALUES (" + userId + ", '" + studentNo + "', '" + realName + "', '" + nickname + "', '" + passwordHash + "', '" + roleCode + "', '" + accountStatus + "')");
    }

    protected void insertCategory(int categoryId, String categoryName) throws Exception {
        executeSql("INSERT INTO categories (category_id, category_name) VALUES (" + categoryId + ", '" + categoryName + "')");
    }

    protected void insertProduct(int productId, int sellerId, int categoryId, String title,
                                  String price, String publishStatus) throws Exception {
        executeSql("INSERT INTO products (product_id, seller_id, category_id, title, product_desc, price, publish_status, created_at, updated_at) " +
                "VALUES (" + productId + ", " + sellerId + ", " + categoryId + ", '" + title + "', 'desc', " + price + ", '" + publishStatus + "', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)");
    }

    protected void insertOrder(int orderId, String orderNo, int productId, int buyerId, int sellerId,
                                String dealPrice, String orderStatus) throws Exception {
        executeSql("INSERT INTO orders (order_id, order_no, product_id, buyer_id, seller_id, deal_price, order_status) " +
                "VALUES (" + orderId + ", '" + orderNo + "', " + productId + ", " + buyerId + ", " + sellerId + ", " + dealPrice + ", '" + orderStatus + "')");
    }

    protected void insertFavorite(int userId, int productId) throws Exception {
        executeSql("INSERT INTO favorites (user_id, product_id) VALUES (" + userId + ", " + productId + ")");
    }

    protected void insertNotification(int notificationId, int userId, String content, boolean isRead) throws Exception {
        executeSql("INSERT INTO notifications (notification_id, user_id, content, is_read) " +
                "VALUES (" + notificationId + ", " + userId + ", '" + content + "', " + (isRead ? 1 : 0) + ")");
    }

    protected void insertConversation(long conversationId, long productId, int buyerId, int sellerId) throws Exception {
        executeSql("INSERT INTO conversations (conversation_id, product_id, buyer_id, seller_id) " +
                "VALUES (" + conversationId + ", " + productId + ", " + buyerId + ", " + sellerId + ")");
    }

    protected void insertMessage(long conversationId, int senderId, String content, boolean isRead) throws Exception {
        executeSql("INSERT INTO messages (conversation_id, sender_id, message_content, is_read) " +
                "VALUES (" + conversationId + ", " + senderId + ", '" + content + "', " + (isRead ? 1 : 0) + ")");
    }

    protected void insertComment(long commentId, long productId, int userId, String content, Long parentId) throws Exception {
        String parentVal = parentId == null ? "NULL" : parentId.toString();
        executeSql("INSERT INTO product_comments (comment_id, product_id, user_id, content, parent_id) " +
                "VALUES (" + commentId + ", " + productId + ", " + userId + ", '" + content + "', " + parentVal + ")");
    }

    protected void insertReport(long reportId, long productId, long reporterId, String reason, String status) throws Exception {
        executeSql("INSERT INTO reports (report_id, product_id, reporter_id, report_reason, report_status) " +
                "VALUES (" + reportId + ", " + productId + ", " + reporterId + ", '" + reason + "', '" + status + "')");
    }

    protected void insertDispute(int disputeId, int orderId, int applicantId, String reason, String status) throws Exception {
        executeSql("INSERT INTO disputes (dispute_id, order_id, applicant_id, reason, status) " +
                "VALUES (" + disputeId + ", " + orderId + ", " + applicantId + ", '" + reason + "', '" + status + "')");
    }

    protected void insertOffer(long offerId, long productId, int buyerId, int sellerId,
                                String offerPrice, String status) throws Exception {
        executeSql("INSERT INTO offers (offer_id, product_id, buyer_id, seller_id, offer_price, status) " +
                "VALUES (" + offerId + ", " + productId + ", " + buyerId + ", " + sellerId + ", " + offerPrice + ", '" + status + "')");
    }

    protected void insertReview(long reviewId, long orderId, long productId, int reviewerId,
                                 int revieweeId, int rating) throws Exception {
        executeSql("INSERT INTO reviews (review_id, order_id, product_id, reviewer_id, reviewee_id, rating) " +
                "VALUES (" + reviewId + ", " + orderId + ", " + productId + ", " + reviewerId + ", " + revieweeId + ", " + rating + ")");
    }

    protected void loginUser(User user) {
        session.setAttribute("loginUser", user);
    }

    protected String getRedirectUrl() {
        return response.getRedirectedUrl();
    }
}
