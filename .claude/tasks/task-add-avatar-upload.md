# Task: Add Avatar Upload Feature

- **id**: add-avatar-upload
- **created**: 2026-05-15
- **status**: done

## Context

This is a Maven Web project (second-hand trading platform) using pure Servlet 3.0 + JSP + JDBC (no Spring). The database `users` table already has an `avatar_url varchar(255)` column but it is never used in Java code. The project already has file upload infrastructure (`@MultipartConfig`, `Part` API) used in `PublishProductServlet` and `EditProductServlet`, both of which have identical `getUploadDir()` and `saveFile()` methods. `ImageServlet` serves uploaded files via `/uploads/*`.

All files below are at the project root `c:\Users\28363\Desktop\Maven Web\`.

## Design Decisions

1. **UploadUtil utility class**: Extract the duplicate `getUploadDir()` and `saveFile()` from `PublishProductServlet` and `EditProductServlet` into a shared utility class. This keeps things DRY and lets `ProfileServlet` reuse the same logic.
2. **Avatar upload UX**: The avatar area on `profile.jsp` becomes clickable. Clicking opens a file picker; selecting an image auto-submits a dedicated multipart form (separate from the existing nickname/password forms, so those remain unaffected).
3. **Fallback display**: Every place that shows an avatar checks `avatar_url`. If present, render an `<img>` tag. If absent, render the current initial-letter circle as fallback.
4. **Session sync**: After a successful avatar upload, the `loginUser` object in the session is updated with the new `avatarUrl` so the header reflects the change instantly.

## Files to Work With

- **Create**:
  - `src/main/java/com/minzu/util/UploadUtil.java`
- **Modify**:
  - `src/main/java/com/minzu/entity/User.java`
  - `src/main/java/com/minzu/entity/Product.java`
  - `src/main/java/com/minzu/servlet/LoginServlet.java`
  - `src/main/java/com/minzu/servlet/ProfileServlet.java`
  - `src/main/java/com/minzu/servlet/SellerProfileServlet.java`
  - `src/main/java/com/minzu/servlet/ProductDetailServlet.java`
  - `src/main/java/com/minzu/servlet/PublishProductServlet.java`
  - `src/main/java/com/minzu/servlet/EditProductServlet.java`
  - `src/main/webapp/profile.jsp`
  - `src/main/webapp/seller-profile.jsp`
  - `src/main/webapp/product-detail.jsp`
  - `src/main/webapp/common/header.jsp`
- **Reference**:
  - `src/main/java/com/minzu/servlet/ImageServlet.java` -- no changes needed, already serves all `/uploads/*` files

## Detailed Instructions

### 1. Create `src/main/java/com/minzu/util/UploadUtil.java`

Create a utility class with private constructor, containing the two methods currently duplicated across `PublishProductServlet` and `EditProductServlet`.

```java
package com.minzu.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import java.util.UUID;

public class UploadUtil {

    private UploadUtil() {}

    public static String getUploadDir() {
        String dir = System.getProperty("upload.dir");
        if (dir != null && !dir.trim().isEmpty()) {
            return dir.trim();
        }
        return System.getProperty("user.home") + File.separator + "minzu-secondhand-uploads";
    }

    public static String saveFile(Part part, String uploadPath, HttpServletRequest request) throws Exception {
        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) return null;
        String ext = "";
        int dot = submittedFileName.lastIndexOf(".");
        if (dot != -1) ext = submittedFileName.substring(dot);
        String newFileName = UUID.randomUUID().toString().replace("-", "") + ext;
        part.write(uploadPath + File.separator + newFileName);
        return request.getContextPath() + "/uploads/" + newFileName;
    }
}
```

### 2. Modify `src/main/java/com/minzu/entity/User.java`

Add the `avatarUrl` field with getter/setter after the `accountStatus` field/methods.

**Changes**:

After line 57 (`setAccountStatus` closing brace), add:

```java
    private String avatarUrl;

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }
```

The private field declaration `private String avatarUrl;` goes near line 9 with the other fields (after `accountStatus`). The getter/setter methods go at the end of the class after `setAccountStatus`.

### 3. Modify `src/main/java/com/minzu/entity/Product.java`

Add the `sellerAvatarUrl` field with getter/setter after the `sellerName` field/methods.

**Changes**:

After line 51 (`setSellerName` closing brace), add:

```java
    private String sellerAvatarUrl;

    public String getSellerAvatarUrl() {
        return sellerAvatarUrl;
    }

    public void setSellerAvatarUrl(String sellerAvatarUrl) {
        this.sellerAvatarUrl = sellerAvatarUrl;
    }
```

The private field `private String sellerAvatarUrl;` goes near line 10 (with the other private fields, after `sellerName`). The getter/setter methods go after `setSellerName`.

### 4. Modify `src/main/java/com/minzu/servlet/PublishProductServlet.java`

Replace the private `getUploadDir()` and `saveFile()` methods with `UploadUtil` calls.

**Changes**:

- **Delete** the private `getUploadDir()` method (lines 29-35).
- **Delete** the `saveFile()` method (lines 248-257).
- Replace all `getUploadDir()` with `UploadUtil.getUploadDir()`.
- Replace all `saveFile(...)` with `UploadUtil.saveFile(...)`.

Specifically:
- Line 120: `String uploadDir = getUploadDir();` -> `String uploadDir = UploadUtil.getUploadDir();`
- Line 132: `String coverImageUrl = saveFile(coverPart, uploadDir, request);` -> `String coverImageUrl = UploadUtil.saveFile(coverPart, uploadDir, request);`
- Line 200: `String imageUrl = saveFile(part, uploadDir, request);` -> `String imageUrl = UploadUtil.saveFile(part, uploadDir, request);`

Add import: `import com.minzu.util.UploadUtil;`

Remove unused imports after the refactor: `import java.nio.file.Paths;` and `import java.util.UUID;` (no longer needed since saveFile is delegated).

### 5. Modify `src/main/java/com/minzu/servlet/EditProductServlet.java`

Same pattern as PublishProductServlet.

**Changes**:

- **Delete** the private `getUploadDir()` method (lines 31-37).
- **Delete** the `saveFile()` method (lines 283-292).
- Line 172: `String uploadDir = getUploadDir();` -> `String uploadDir = UploadUtil.getUploadDir();`
- Line 180: `newCoverImageUrl = saveFile(coverPart, uploadDir, request);` -> `newCoverImageUrl = UploadUtil.saveFile(coverPart, uploadDir, request);`

Add import: `import com.minzu.util.UploadUtil;`

Remove unused imports: `import java.nio.file.Paths;` and `import java.util.UUID;`.

### 6. Modify `src/main/java/com/minzu/servlet/LoginServlet.java`

Update the SQL query to include `avatar_url`, and set it on the User object.

**Changes**:

- Line 40-42: Update the SELECT clause to include `avatar_url`:
  ```java
  String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, account_status, password_hash, avatar_url " +
               "FROM users " +
               "WHERE student_or_staff_no = ? AND IFNULL(is_deleted, 0) = 0";
  ```

- After line 90 (`user.setAccountStatus(accountStatus);`), add:
  ```java
  user.setAvatarUrl(rs.getString("avatar_url"));
  ```

### 7. Modify `src/main/java/com/minzu/servlet/ProfileServlet.java`

This is the core change. Add `@MultipartConfig`, update GET to read `avatar_url`, add POST handler for avatar upload.

**Changes**:

- Add `@MultipartConfig` annotation after `@WebServlet("/profile")`:
  ```java
  @WebServlet("/profile")
  @MultipartConfig(
      fileSizeThreshold = 1024 * 1024,   // 1MB
      maxFileSize = 5 * 1024 * 1024,     // 5MB per file
      maxRequestSize = 10 * 1024 * 1024  // 10MB total
  )
  ```

- Add imports:
  ```java
  import com.minzu.util.UploadUtil;
  import java.io.File;
  import java.nio.file.Paths;
  import java.util.Arrays;
  import java.util.HashSet;
  import java.util.Set;
  ```

- In `doGet()`, line 29-30: Add `avatar_url` to the SELECT query:
  ```java
  String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, " +
               "account_status, phone, email, avatar_url FROM users WHERE user_id=?";
  ```

- In `doGet()`, after line 42 (`req.setAttribute("u_role", rs.getString("role_code"));`), add:
  ```java
  req.setAttribute("u_avatarUrl", rs.getString("avatar_url"));
  ```

- In `doPost()`, at the very beginning of the method (right after line 57 `if (loginUser == null) return;`), add the avatar upload handling block:

  ```java
  // --- Avatar upload (if present in a multipart request) ---
  try {
      Part avatarPart = request.getPart("avatar");
      if (avatarPart != null && avatarPart.getSize() > 0) {
          // Validate file extension
          String submittedFileName = Paths.get(avatarPart.getSubmittedFileName()).getFileName().toString();
          String ext = "";
          int dot = submittedFileName.lastIndexOf(".");
          if (dot != -1) ext = submittedFileName.substring(dot).toLowerCase();

          Set<String> allowedExts = new HashSet<>(Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp"));
          if (!allowedExts.contains(ext)) {
              req.getSession().setAttribute("errorMsg", "仅支持 JPG、PNG、GIF、WebP 格式的头像");
              resp.sendRedirect(req.getContextPath() + "/profile");
              return;
          }

          String uploadDir = UploadUtil.getUploadDir();
          File uploadDirFile = new File(uploadDir);
          if (!uploadDirFile.exists()) {
              uploadDirFile.mkdirs();
          }

          String avatarUrl = UploadUtil.saveFile(avatarPart, uploadDir, req);

          String updateAvatarSql = "UPDATE users SET avatar_url=? WHERE user_id=?";
          try (Connection conn = DBUtil.getConnection();
               PreparedStatement ps = conn.prepareStatement(updateAvatarSql)) {
              ps.setString(1, avatarUrl);
              ps.setInt(2, loginUser.getUserId());
              ps.executeUpdate();
          }

          // Update session User object so header reflects change immediately
          loginUser.setAvatarUrl(avatarUrl);

          req.getSession().setAttribute("successMsg", "头像已更新");
          resp.sendRedirect(req.getContextPath() + "/profile");
          return;
      }
  } catch (Exception e) {
      // Not a multipart request, or other error -- fall through to existing logic
  }
  ```

  Place this block right after `if (loginUser == null) return;` (line 57 in original file).

### 8. Modify `src/main/java/com/minzu/servlet/SellerProfileServlet.java`

Update the seller SQL to include `avatar_url` and add it to the seller map.

**Changes**:

- Line 54: Update the SQL to include `avatar_url`:
  ```java
  String sellerSql = "SELECT user_id, real_name, nickname, avatar_url FROM users WHERE user_id = ?";
  ```

- After line 63 (`seller.put("nickname", rs.getString("nickname"));`), add:
  ```java
  seller.put("avatarUrl", rs.getString("avatar_url"));
  ```

### 9. Modify `src/main/java/com/minzu/servlet/ProductDetailServlet.java`

Update the SQL to include the seller's avatar_url and pass it to the JSP via the Product entity.

**Changes**:

- Lines 49-56: Add `u.avatar_url AS seller_avatar_url` to the SELECT clause:
  ```java
  String sql =
      "SELECT p.product_id, p.seller_id, u.real_name AS seller_name, " +
      "u.avatar_url AS seller_avatar_url, " +
      "p.category_id, c.category_name, p.title, p.product_desc, " +
      "p.price, p.original_price, p.condition_level, p.cover_image_url, " +
      "p.image_urls, p.publish_status, p.view_count, p.favorite_count, p.created_at " +
      "FROM products p " +
      "LEFT JOIN users u ON p.seller_id = u.user_id " +
      "LEFT JOIN categories c ON p.category_id = c.category_id " +
      "WHERE p.product_id = ? AND p.is_deleted = 0";
  ```

- After line 69 (`p.setSellerName(rs.getString("seller_name"));`), add:
  ```java
  p.setSellerAvatarUrl(rs.getString("seller_avatar_url"));
  ```

### 10b. profile.jsp avatar section

```jsp
            <!-- 头像 (clickable for upload) -->
            <div class="relative cursor-pointer group" onclick="document.getElementById('avatarInput').click()">
                <% if (uAvatarUrl != null && !uAvatarUrl.isEmpty()) { %>
                    <img src="<%= uAvatarUrl %>" alt="头像" class="w-20 h-20 rounded-full object-cover border-2 border-white/30">
                <% } else { %>
                    <div class="w-20 h-20 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-2xl font-display font-bold border-2 border-white/30">
                        <%= firstNameChar %>
                    </div>
                <% } %>
                <!-- Hover overlay: camera icon -->
                <div class="absolute inset-0 bg-black/40 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <svg class="w-8 h-8 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                        <circle cx="12" cy="13" r="4"/>
                    </svg>
                </div>
                <div class="absolute -bottom-1 -right-1 w-6 h-6 bg-accent rounded-full flex items-center justify-center border-2 border-white">
                    <svg class="w-3 h-3 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                </div>
            </div>
            <!-- Hidden form for avatar upload -->
            <form method="post" action="<%= request.getContextPath() %>/profile" enctype="multipart/form-data" id="avatarForm">
                <input type="file" name="avatar" id="avatarInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none" onchange="document.getElementById('avatarForm').submit();">
            </form>
```

### 11. Modify `src/main/webapp/seller-profile.jsp`

**Changes**:

A. After line 22 (`int sellerId = (int) seller.get("userId");`), add:
```jsp
    String sellerAvatarUrl = (String) seller.get("avatarUrl");
```

B. Replace lines 79-82 (the avatar `<div>` inside the seller info card) with:
```jsp
            <% if (sellerAvatarUrl != null && !sellerAvatarUrl.isEmpty()) { %>
                <img src="<%= sellerAvatarUrl %>" alt="<%= displayName %>"
                     class="w-20 h-20 rounded-full object-cover border-2 border-stone-200 flex-shrink-0">
            <% } else { %>
                <div class="w-20 h-20 rounded-full bg-brand-500 text-white flex items-center justify-center text-3xl font-display font-bold flex-shrink-0">
                    <%= avatarChar %>
                </div>
            <% } %>
```

### 12. Modify `src/main/webapp/product-detail.jsp`

**Changes**:

Replace lines 298-301 (the seller avatar in the product detail sidebar) with:
```jsp
                                <div class="flex items-center gap-2">
                                    <% 
                                        String prodSellerAvatarUrl = product.getSellerAvatarUrl();
                                        if (prodSellerAvatarUrl != null && !prodSellerAvatarUrl.isEmpty()) { 
                                    %>
                                        <img src="<%= prodSellerAvatarUrl %>" alt="<%= product.getSellerName() %>"
                                             class="w-6 h-6 rounded-full object-cover">
                                    <% } else { %>
                                        <div class="w-6 h-6 bg-brand-100 rounded-full flex items-center justify-center text-brand-600 font-bold text-xs"><%= product.getSellerName() != null ? product.getSellerName().substring(0, Math.min(1, product.getSellerName().length())) : "?" %></div>
                                    <% } %>
                                    <span class="text-sm font-semibold text-ink-primary"><%= product.getSellerName() != null ? product.getSellerName() : "未知卖家" %></span>
                                </div>
```

### 13. Modify `src/main/webapp/common/header.jsp`

Add avatar display for logged-in users.

**Changes**:

Replace lines 82-87 with:

```jsp
        <% } else if (navLoginUser != null) { %>
            <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 mr-1" title="个人信息">
                <% 
                    String navAvatarUrl = navLoginUser.getAvatarUrl();
                    String navInitial = (navLoginUser.getRealName() != null && !navLoginUser.getRealName().isEmpty()) 
                                        ? navLoginUser.getRealName().substring(0, 1) : "?";
                %>
                <% if (navAvatarUrl != null && !navAvatarUrl.isEmpty()) { %>
                    <img src="<%= navAvatarUrl %>" alt="头像" class="w-8 h-8 rounded-full object-cover border-2 border-stone-200">
                <% } else { %>
                    <div class="w-8 h-8 bg-brand-500 rounded-full flex items-center justify-center text-white text-sm font-bold">
                        <%= navInitial %>
                    </div>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product" class="px-4 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press flex items-center gap-1">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                发布商品
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="text-sm text-ink-muted hover:text-red-500 transition-colors px-2 py-1.5">退出</a>
        <% } else { %>
```

## Acceptance Criteria

- [ ] `UploadUtil.java` is created and used by `PublishProductServlet`, `EditProductServlet`, and `ProfileServlet`.
- [ ] `User.java` has `avatarUrl` field with getter/setter.
- [ ] `Product.java` has `sellerAvatarUrl` field with getter/setter.
- [ ] `LoginServlet` reads `avatar_url` from DB and sets it on the User session object.
- [ ] `ProfileServlet` has `@MultipartConfig`, reads `avatar_url` in GET, and handles avatar file upload in POST.
- [ ] `SellerProfileServlet` reads `avatar_url` and passes it to JSP.
- [ ] `ProductDetailServlet` reads `avatar_url` and passes it to JSP via Product entity.
- [ ] `profile.jsp` shows uploaded avatar image (falls back to initial letter), clicking avatar opens file picker, and selection auto-submits the upload form.
- [ ] `seller-profile.jsp` shows seller avatar image (falls back to initial letter).
- [ ] `product-detail.jsp` shows seller avatar image in the sidebar (falls back to initial letter).
- [ ] `header.jsp` shows user avatar thumbnail (falls back to initial letter) linking to profile page.
- [ ] Session `loginUser.avatarUrl` is updated after upload so header reflects change immediately without re-login.
- [ ] File type validation rejects non-image files gracefully with error message.
- [ ] All existing functionality (login, publish product, edit product, profile edit, password change, seller profile, product detail) continues to work unchanged.

## Constraints

- Follow existing patterns exactly: `@WebServlet`, `DBUtil`, JDBC try-with-resources, and session attribute patterns.
- The `getUploadDir()` logic must remain identical across all consumers - delegate to `UploadUtil.getUploadDir()`.
- Avatar uploads must use the SAME upload directory as product images (`~/minzu-secondhand-uploads/`).
- No Spring, no frameworks, no additional dependencies beyond what the project already uses.
- Keep the existing `@MultipartConfig` on `PublishProductServlet` and `EditProductServlet` - they still use the `Part` API directly.
- The try-catch around `request.getPart("avatar")` in `ProfileServlet` is intentional and required: non-multipart POSTs (password change, basic info) must NOT throw exceptions.
- Preserve all existing JSP structure - only change the avatar-specific parts of the markup.


## Review Results

**Review date**: 2026-05-15
**Reviewer**: DeepSeek V4 Pro (Architect)

### Avatar upload feature: PASS

All 14 acceptance criteria for the avatar upload feature are met. Key findings:

- UploadUtil.java correctly extracted with getUploadDir() and saveFile() methods
- ProfileServlet.java has correct @MultipartConfig with proper threshold/size values
- File type validation in ProfileServlet allows: .jpg, .jpeg, .png, .gif, .webp with Chinese error message
- Session sync is correctly performed: loginUser.setAvatarUrl(avatarUrl) mutates the session object in place
- All JSP pages (profile.jsp, seller-profile.jsp, product-detail.jsp, header.jsp) have correct image/fallback logic
- LoginServlet correctly reads avatar_url from DB and sets it on the User session object
- PublishProductServlet and EditProductServlet correctly refactored to use UploadUtil
- The try-catch in ProfileServlet.doPost correctly handles non-multipart requests (password change, basic info)

### Issues requiring revision

#### Revision 1: pickup-locations.jsp has incorrect university name

**File**: src/main/webapp/pickup-locations.jsp, line 53
**Current**: "以下是西南民族大学校内推荐的自提交易地点"
**Required**: "以下是中央民族大学校内推荐的自提交易地点"
**Reason**: The project is "中央民族大学" (Minzu University of China), not "西南民族大学". This file was not in the task's modification list and was accidentally changed. The coder must revert this line.

#### Out-of-scope changes (noted, not blocking)

The following files received modifications unrelated to the avatar upload task. These do not block the task but should be avoided in future work:
- AdminDashboardServlet.java -- added dailyUsers/categoryStats/dailyAmount queries
- ProductListServlet.java -- added hotTags feature
- admin-dashboard.jsp -- added Chart.js charts
- edit-product.jsp -- added tag input UI
- publish-product.jsp -- added tag input UI
- product-list.jsp -- added hot tags display and tag filtering
- product-detail.jsp -- added tag display (in addition to avatar change)
- PublishProductServlet.java / EditProductServlet.java -- added cleanTags() method
