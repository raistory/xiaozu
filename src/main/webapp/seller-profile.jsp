<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Map<String, Object> seller = (Map<String, Object>) request.getAttribute("seller");
    Double avgRating = (Double) request.getAttribute("avgRating");
    Integer reviewCount = (Integer) request.getAttribute("reviewCount");
    Integer onSaleCount = (Integer) request.getAttribute("onSaleCount");
    List<Map<String, Object>> productList = (List<Map<String, Object>>) request.getAttribute("productList");
    List<Map<String, Object>> reviewList = (List<Map<String, Object>>) request.getAttribute("reviewList");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");

    if (seller == null) {
        response.sendRedirect(request.getContextPath() + "/index");
        return;
    }

    String sellerName = (String) seller.get("realName");
    String nickname = (String) seller.get("nickname");
    int sellerId = (int) seller.get("userId");
    String sellerAvatarUrl = (String) seller.get("avatarUrl");

    if (avgRating == null) avgRating = 0.0;
    if (reviewCount == null) reviewCount = 0;
    if (onSaleCount == null) onSaleCount = 0;
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String displayName = (nickname != null && !nickname.isEmpty()) ? nickname : sellerName;
    String avatarChar = (sellerName != null && !sellerName.isEmpty()) ? sellerName.substring(0, 1) : "?";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= displayName %> - 卖家主页 - 民大二手交易平台</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Noto+Sans+SC:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: { 50: '#f0fdf4', 100: '#dcfce7', 200: '#bbf7d0', 300: '#86efac', 400: '#4ade80', 500: '#22c55e', 600: '#16a34a', 700: '#15803d', 800: '#166534', 900: '#14532d' },
                        accent: { DEFAULT: '#f97316', hover: '#ea580c' },
                        surface: { DEFAULT: '#fafaf9', raised: '#ffffff' },
                        ink: { primary: '#1c1917', secondary: '#44403c', muted: '#78716c', faint: '#a8a29e' }
                    },
                    fontFamily: {
                        display: ['Outfit', 'sans-serif'],
                        body: ['Noto Sans SC', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <style>
        .hover-lift { transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
        .btn-press { transition: transform 0.1s ease; }
        .btn-press:active { transform: scale(0.97); }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value=""/>
</jsp:include>

<main class="max-w-6xl mx-auto px-4 py-8">

    <!-- 卖家信息卡片 -->
    <div class="bg-white rounded-2xl shadow-sm border border-stone-100 p-8 mb-8">
        <div class="flex flex-col sm:flex-row items-center sm:items-start gap-6">
            <% if (sellerAvatarUrl != null && !sellerAvatarUrl.isEmpty()) { %>
                <img src="<%= sellerAvatarUrl %>" alt="<%= displayName %>"
                     class="w-20 h-20 rounded-full object-cover border-2 border-stone-200 flex-shrink-0">
            <% } else { %>
                <div class="w-20 h-20 rounded-full bg-brand-500 text-white flex items-center justify-center text-3xl font-display font-bold flex-shrink-0">
                    <%= avatarChar %>
                </div>
            <% } %>
            <div class="text-center sm:text-left flex-1">
                <h1 class="text-2xl font-display font-bold text-ink-primary"><%= displayName %></h1>
                <p class="text-ink-muted mt-1"><%= sellerName %></p>
                <div class="flex flex-wrap justify-center sm:justify-start gap-6 mt-4">
                    <div class="text-center">
                        <div class="flex items-center gap-1 justify-center">
                            <%
                                int fullStars = (int) Math.floor(avgRating);
                                boolean hasHalf = (avgRating - fullStars) >= 0.5;
                                for (int i = 0; i < fullStars; i++) {
                            %>
                                <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                            <%
                                }
                                if (hasHalf) {
                            %>
                                <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                            <%
                                }
                                int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);
                                for (int i = 0; i < emptyStars; i++) {
                            %>
                                <svg class="w-5 h-5 text-stone-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                            <%
                                }
                            %>
                            <span class="text-lg font-semibold text-ink-primary ml-1"><%= String.format("%.1f", avgRating) %></span>
                        </div>
                        <p class="text-sm text-ink-muted mt-1">评分</p>
                    </div>
                    <div class="text-center">
                        <p class="text-lg font-semibold text-ink-primary"><%= reviewCount %></p>
                        <p class="text-sm text-ink-muted">条评价</p>
                    </div>
                    <div class="text-center">
                        <p class="text-lg font-semibold text-ink-primary"><%= onSaleCount %></p>
                        <p class="text-sm text-ink-muted">在售商品</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 在售商品 -->
    <section class="mb-10">
        <h2 class="text-xl font-display font-bold text-ink-primary mb-4">在售商品</h2>
        <% if (productList == null || productList.isEmpty()) { %>
            <div class="bg-white rounded-2xl shadow-sm border border-stone-100 p-12 text-center">
                <p class="text-ink-muted text-lg">暂无在售商品</p>
            </div>
        <% } else { %>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                <% for (Map<String, Object> p : productList) {
                    int pid = (int) p.get("productId");
                    String title = (String) p.get("title");
                    java.math.BigDecimal price = (java.math.BigDecimal) p.get("price");
                    String cover = (String) p.get("coverImageUrl");
                    String condition = (String) p.get("conditionLevel");
                    String conditionLabel = "";
                    if (condition != null) {
                        switch (condition) {
                            case "NEW": conditionLabel = "全新"; break;
                            case "LIKE_NEW": conditionLabel = "几乎全新"; break;
                            case "GOOD": conditionLabel = "成色良好"; break;
                            case "FAIR": conditionLabel = "一般"; break;
                            default: conditionLabel = condition;
                        }
                    }
                %>
                    <a href="<%= request.getContextPath() %>/product-detail?id=<%= pid %>"
                       class="bg-white rounded-xl shadow-sm border border-stone-100 overflow-hidden hover-lift block">
                        <div class="aspect-[4/3] bg-stone-100 overflow-hidden">
                            <% if (cover != null && !cover.isEmpty()) { %>
                                <img src="<%= request.getContextPath() %>/<%= cover %>" alt="<%= title %>"
                                     class="w-full h-full object-cover" loading="lazy">
                            <% } else { %>
                                <div class="w-full h-full flex items-center justify-center text-ink-faint">
                                    <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                              d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                    </svg>
                                </div>
                            <% } %>
                        </div>
                        <div class="p-3">
                            <h3 class="text-sm font-medium text-ink-primary truncate"><%= title %></h3>
                            <div class="flex items-center justify-between mt-2">
                                <span class="text-brand-600 font-display font-bold">¥<%= price %></span>
                                <% if (!conditionLabel.isEmpty()) { %>
                                    <span class="text-xs bg-brand-50 text-brand-700 px-2 py-0.5 rounded-full"><%= conditionLabel %></span>
                                <% } %>
                            </div>
                        </div>
                    </a>
                <% } %>
            </div>

            <!-- 分页 -->
            <% if (totalPages > 1) { %>
                <div class="flex justify-center items-center gap-2 mt-6">
                    <% if (currentPage > 1) { %>
                        <a href="<%= request.getContextPath() %>/seller?id=<%= sellerId %>&page=<%= currentPage - 1 %>"
                           class="px-3 py-2 rounded-lg bg-white border border-stone-200 text-ink-secondary hover:bg-stone-50 text-sm">
                            上一页
                        </a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                        <% if (i == currentPage) { %>
                            <span class="px-3 py-2 rounded-lg bg-brand-500 text-white text-sm font-medium"><%= i %></span>
                        <% } else { %>
                            <a href="<%= request.getContextPath() %>/seller?id=<%= sellerId %>&page=<%= i %>"
                               class="px-3 py-2 rounded-lg bg-white border border-stone-200 text-ink-secondary hover:bg-stone-50 text-sm">
                                <%= i %>
                            </a>
                        <% } %>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                        <a href="<%= request.getContextPath() %>/seller?id=<%= sellerId %>&page=<%= currentPage + 1 %>"
                           class="px-3 py-2 rounded-lg bg-white border border-stone-200 text-ink-secondary hover:bg-stone-50 text-sm">
                            下一页
                        </a>
                    <% } %>
                </div>
            <% } %>
        <% } %>
    </section>

    <!-- 收到的评价 -->
    <section>
        <h2 class="text-xl font-display font-bold text-ink-primary mb-4">收到的评价</h2>
        <% if (reviewList == null || reviewList.isEmpty()) { %>
            <div class="bg-white rounded-2xl shadow-sm border border-stone-100 p-12 text-center">
                <p class="text-ink-muted text-lg">暂无评价</p>
            </div>
        <% } else { %>
            <div class="space-y-4">
                <% for (Map<String, Object> r : reviewList) {
                    int score = (int) r.get("score");
                    String content = (String) r.get("content");
                    String reviewerName = (String) r.get("reviewerName");
                    java.sql.Timestamp createdAt = (java.sql.Timestamp) r.get("createdAt");
                    String role = (String) r.get("role");
                    String roleLabel = "BUYER".equals(role) ? "买家" : "卖家";
                %>
                    <div class="bg-white rounded-xl shadow-sm border border-stone-100 p-5">
                        <div class="flex items-center justify-between mb-3">
                            <div class="flex items-center gap-3">
                                <div class="w-9 h-9 rounded-full bg-brand-100 text-brand-700 flex items-center justify-center text-sm font-bold">
                                    <%= (reviewerName != null && !reviewerName.isEmpty()) ? reviewerName.substring(0, 1) : "?" %>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-ink-primary"><%= reviewerName != null ? reviewerName : "匿名用户" %></p>
                                    <p class="text-xs text-ink-faint"><%= roleLabel %>评价</p>
                                </div>
                            </div>
                            <div class="flex items-center gap-1">
                                <% for (int i = 0; i < score; i++) { %>
                                    <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                                <% } %>
                                <% for (int i = score; i < 5; i++) { %>
                                    <svg class="w-4 h-4 text-stone-300" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                                <% } %>
                            </div>
                        </div>
                        <% if (content != null && !content.isEmpty()) { %>
                            <p class="text-ink-secondary text-sm leading-relaxed"><%= content %></p>
                        <% } else { %>
                            <p class="text-ink-faint text-sm italic">用户未填写评价内容</p>
                        <% } %>
                        <% if (createdAt != null) { %>
                            <p class="text-xs text-ink-faint mt-3"><%= sdf.format(createdAt) %></p>
                        <% } %>
                    </div>
                <% } %>
            </div>
        <% } %>
    </section>

</main>

</body>
</html>
