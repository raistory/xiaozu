<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="com.minzu.entity.User" %>
<%
    List<Product> productList = (List<Product>) request.getAttribute("products");
    User loginUser  = (User) session.getAttribute("loginUser");
    String keyword  = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String catId    = request.getAttribute("categoryId") != null ? (String) request.getAttribute("categoryId") : "";
    String catName  = request.getAttribute("categoryName") != null ? (String) request.getAttribute("categoryName") : "";
    List<Map<String, Object>> categories = (List<Map<String, Object>>) request.getAttribute("categories");
    if (categories == null) categories = new java.util.ArrayList<>();
    List<Map<String, Object>> hotTags = (List<Map<String, Object>>) request.getAttribute("hotTags");
    if (hotTags == null) hotTags = new java.util.ArrayList<>();
    java.util.Set<Integer> favoriteProductIds = (java.util.Set<Integer>) request.getAttribute("favoriteProductIds");
    if (favoriteProductIds == null) favoriteProductIds = new java.util.HashSet<>();
    String currentTag = request.getAttribute("tag") != null ? (String) request.getAttribute("tag") : "";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int) request.getAttribute("totalPages")  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? (int) request.getAttribute("totalCount")  : 0;

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");

%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品列表 - 民大二手交易平台</title>
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
        .hover-lift { transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s ease; }
        .hover-lift:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.12); }
        .btn-press { transition: transform 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }
        .img-zoom { transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1); }
        .img-zoom:hover { transform: scale(1.08); }

        .card-enter {
            animation: cardIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(30px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .search-glow:focus-within {
            box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.15), 0 8px 24px rgba(0,0,0,0.1);
        }

        .category-tag {
            transition: all 0.2s ease;
        }
        .category-tag.active {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: white;
            border-color: transparent;
            box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
        }

        .price-tag {
            position: relative;
            overflow: hidden;
        }
        .price-tag::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transform: translateX(-100%);
            animation: shimmer 2.5s infinite;
        }
        @keyframes shimmer {
            100% { transform: translateX(100%); }
        }

        .filter-dropdown {
            animation: dropIn 0.2s ease;
        }
        @keyframes dropIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .heart-btn:hover svg {
            animation: heartBeat 0.6s ease-in-out;
        }
        @keyframes heartBeat {
            0%, 100% { transform: scale(1); }
            25% { transform: scale(1.2); }
            50% { transform: scale(0.95); }
            75% { transform: scale(1.1); }
        }

        .notif-badge {
            background: #ef4444;
            color: #fff;
            border-radius: 10px;
            font-size: 10px;
            line-height: 1;
            padding: 1px 5px;
            font-weight: 700;
            min-width: 16px;
            text-align: center;
        }

        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .img-zoom, .card-enter, .filter-dropdown { animation: none; transition: none; }
            .hover-lift:hover, .img-zoom:hover { transform: none; }
            .btn-press:active { transform: none; }
            .price-tag::after { animation: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/20 to-stone-100">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="products"/>
</jsp:include>

<!-- Main content -->
<main class="max-w-7xl mx-auto px-4 py-6">

    <!-- Alerts -->
    <% if (successMsg != null) { %>
    <div class="flex items-center gap-3 p-4 bg-brand-50 border border-brand-200 text-brand-700 rounded-xl text-sm mb-4">
        <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
        <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="flex items-center gap-3 p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl text-sm mb-4">
        <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= errorMsg %>
    </div>
    <% } %>

    <!-- Search Form -->
    <form method="get" action="${pageContext.request.contextPath}/product-list" class="bg-surface-raised rounded-2xl shadow-lg p-6 mb-6">
        <div class="flex flex-col md:flex-row gap-4">
            <!-- Search input -->
            <div class="flex-1 relative search-glow rounded-xl transition-all">
                <input
                    type="text"
                    name="keyword"
                    placeholder="搜索商品名称、分类..."
                    value="<%= keyword != null ? keyword : "" %>"
                    class="w-full pl-12 pr-4 py-3.5 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint focus:border-brand-500 focus:outline-none transition-all"
                >
                <svg class="w-5 h-5 text-ink-faint absolute left-4 top-1/2 -translate-y-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
            </div>
            <!-- Min price -->
            <input type="number" name="minPrice" placeholder="最低价" min="0" step="0.01"
                   value="<%= request.getAttribute("minPrice") != null ? request.getAttribute("minPrice") : "" %>"
                   class="px-4 py-3.5 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint focus:border-brand-500 focus:outline-none transition-all w-28">
            <span class="hidden md:flex items-center text-ink-faint">-</span>
            <!-- Max price -->
            <input type="number" name="maxPrice" placeholder="最高价" min="0" step="0.01"
                   value="<%= request.getAttribute("maxPrice") != null ? request.getAttribute("maxPrice") : "" %>"
                   class="px-4 py-3.5 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint focus:border-brand-500 focus:outline-none transition-all w-28">
            <!-- Sort -->
            <select name="sort" class="px-4 py-3.5 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary focus:border-brand-500 focus:outline-none transition-all" onchange="this.form.submit()">
                <option value="newest" <%= "newest".equals(request.getAttribute("sort")) || request.getAttribute("sort") == null ? "selected" : "" %>>最新发布</option>
                <option value="price_asc" <%= "price_asc".equals(request.getAttribute("sort")) ? "selected" : "" %>>价格从低到高</option>
                <option value="price_desc" <%= "price_desc".equals(request.getAttribute("sort")) ? "selected" : "" %>>价格从高到低</option>
                <option value="views" <%= "views".equals(request.getAttribute("sort")) ? "selected" : "" %>>浏览量最多</option>
            </select>
            <!-- Search button -->
            <button type="submit" class="px-8 py-3.5 bg-gradient-to-r from-brand-500 to-brand-600 text-white font-display font-semibold rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/20 flex items-center gap-2">
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                搜索
            </button>
            <!-- Clear filter -->
            <% if ((keyword != null && !keyword.isEmpty()) || (request.getAttribute("minPrice") != null && !request.getAttribute("minPrice").toString().isEmpty()) || (request.getAttribute("maxPrice") != null && !request.getAttribute("maxPrice").toString().isEmpty()) || !currentTag.isEmpty()) { %>
            <a href="${pageContext.request.contextPath}/product-list" class="px-6 py-3.5 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-muted font-medium hover:border-brand-300 hover:text-brand-600 transition-all flex items-center gap-1 btn-press">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                清除
            </a>
            <% } %>
        </div>
    </form>

    <!-- Filter Row -->
    <div class="flex items-center justify-between mb-6 flex-wrap gap-3">
        <!-- Category tags -->
        <div class="flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/product-list"
               class="category-tag <%= (catId == null || catId.isEmpty()) && (catName == null || catName.isEmpty()) && currentTag.isEmpty() ? "active" : "" %> px-4 py-2 bg-surface-DEFAULT border border-stone-200 text-sm font-medium rounded-full hover:border-brand-300 hover:text-brand-600 transition-all">
                全部
            </a>
            <% for (Map<String, Object> cat : categories) { %>
            <a href="${pageContext.request.contextPath}/product-list?categoryId=<%= cat.get("categoryId") %>"
               class="category-tag <%= String.valueOf(cat.get("categoryId")).equals(catId) || String.valueOf(cat.get("categoryName")).equals(catName) ? "active" : "" %> px-4 py-2 bg-surface-DEFAULT border border-stone-200 text-sm font-medium rounded-full hover:border-brand-300 hover:text-brand-600 transition-all">
                <%= cat.get("categoryName") %>专区
            </a>
            <% } %>
            <a href="${pageContext.request.contextPath}/product-list?tag=graduation"
               class="category-tag <%= "graduation".equals(currentTag) ? "active" : "" %> px-4 py-2 bg-surface-DEFAULT border border-stone-200 text-sm font-medium rounded-full hover:border-brand-300 hover:text-brand-600 transition-all">
                毕业季专区
            </a>
        </div>

        <!-- Result info -->
        <span class="text-sm text-ink-muted">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                "<span class="text-ink-primary font-semibold"><%= keyword %></span>" 的结果 · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件
            <% } else if (catId != null && !catId.isEmpty()) {
                String currentCatName = "未知分类";
                for (Map<String, Object> cat : categories) {
                    if (String.valueOf(cat.get("categoryId")).equals(catId)) {
                        currentCatName = (String) cat.get("categoryName");
                        break;
                    }
                }
            %>
                <span class="text-ink-primary font-semibold"><%= currentCatName %>专区</span> · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件
            <% } else if (catName != null && !catName.isEmpty()) { %>
                <span class="text-ink-primary font-semibold"><%= catName %>专区</span> · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件
            <% } else if (!currentTag.isEmpty()) { %>
                标签：<span class="text-ink-primary font-semibold"><%= currentTag %></span> · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件
            <% } else { %>
                全部商品 · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件
            <% } %>
        </span>
    </div>

    <!-- Hot Tags -->
    <% if (!hotTags.isEmpty()) { %>
    <div class="mb-6">
        <div class="flex items-center gap-2 mb-3">
            <svg class="w-4 h-4 text-accent" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            <span class="text-sm font-medium text-ink-secondary">热门标签</span>
        </div>
        <div class="flex flex-wrap gap-2">
            <% for (Map<String, Object> ht : hotTags) {
                String tagName = (String) ht.get("tagName");
                int tagCount = (int) ht.get("count");
                boolean isActive = tagName.equals(currentTag);
                int colorIdx = Math.abs(tagName.hashCode()) % 6;
                String[] tagBgs = {"#dbeafe","#fce7f3","#d1fae5","#fef3c7","#ede9fe","#ffedd5"};
                String[] tagTexts = {"#1d4ed8","#be185d","#065f46","#92400e","#5b21b6","#9a3412"};
                String[] tagBorders = {"#93c5fd","#f9a8d4","#6ee7b7","#fcd34d","#c4b5fd","#fdba74"};
            %>
            <a href="${pageContext.request.contextPath}/product-list?tag=<%= java.net.URLEncoder.encode(tagName, "UTF-8") %>"
               class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all hover:shadow-md"
               style='background:<%= isActive ? tagTexts[colorIdx] : tagBgs[colorIdx] %>;color:<%= isActive ? "#fff" : tagTexts[colorIdx] %>;border:1px solid <%= tagBorders[colorIdx] %>'>
                <%= tagName %>
                <span class="opacity-60"><%= tagCount %></span>
            </a>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- Product Grid -->
    <% if (productList != null && !productList.isEmpty()) { %>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
    <% int delayIdx = 0;
       for (Product p : productList) {
           delayIdx++;
           boolean canDelete = false;
           if (loginUser != null) {
               boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
               boolean isOwner = loginUser.getUserId() == p.getSellerId();
               canDelete = isAdmin || isOwner;
           }

           String conditionText = "成色未填";
           if (p.getConditionLevel() != null) {
               switch (p.getConditionLevel()) {
                   case "NEW": conditionText = "全新"; break;
                   case "NINETY_NEW": conditionText = "九成新"; break;
                   case "EIGHTY_NEW": conditionText = "八成新"; break;
                   case "SEVENTY_NEW": conditionText = "七成新及以下"; break;
                   default: conditionText = p.getConditionLevel();
               }
           }
    %>
        <div class="card-enter bg-surface-raised border border-stone-200 rounded-2xl overflow-hidden hover-lift flex flex-col group" style="animation-delay: <%= delayIdx * 0.05 %>s">
            <div class="relative overflow-hidden">
                <% if (p.getCoverImageUrl() != null && !"".equals(p.getCoverImageUrl())) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" class="w-full h-44 object-cover img-zoom" loading="lazy">
                <% } else { %>
                    <div class="w-full h-44 bg-stone-100 flex items-center justify-center">
                        <svg class="w-12 h-12 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    </div>
                <% } %>
                <!-- Heart button -->
                <% boolean isFav = favoriteProductIds.contains(p.getProductId()); %>
                <button onclick="toggleFavorite(<%= p.getProductId() %>, this)" class="heart-btn absolute top-3 right-3 w-9 h-9 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:bg-red-50 transition-all opacity-0 group-hover:opacity-100 cursor-pointer">
                    <svg class="w-5 h-5 transition-colors <%= isFav ? "text-red-500" : "text-ink-muted hover:text-red-500" %>" viewBox="0 0 24 24" fill="<%= isFav ? "currentColor" : "none" %>" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                    </svg>
                </button>
                <!-- Category badge -->
                <div class="absolute bottom-3 left-3">
                    <span class="px-2.5 py-1 bg-brand-500/90 backdrop-blur-sm text-white text-xs font-medium rounded-full"><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                </div>
            </div>
            <div class="p-4 flex-1 flex flex-col">
                <h3 class="text-sm font-medium text-ink-primary line-clamp-2 group-hover:text-brand-600 transition-colors"><%= p.getTitle() %></h3>
                <div class="mt-2">
                    <span class="price-tag text-xl font-bold text-red-600 bg-red-50 px-2 py-0.5 rounded">¥<%= p.getPrice() %></span>
                    <% if (p.getOriginalPrice() != null) { %>
                    <span class="text-xs text-ink-faint line-through ml-1">¥<%= p.getOriginalPrice() %></span>
                    <% } %>
                </div>
                <div class="flex items-center gap-3 mt-2 text-xs text-ink-muted">
                    <span><%= conditionText %></span>
                    <span class="w-1 h-1 bg-stone-300 rounded-full"></span>
                    <span><%= p.getSellerName() != null ? p.getSellerName() : "未知" %></span>
                </div>
            </div>
            <div class="px-4 py-3 border-t border-stone-100 flex items-center gap-2">
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="flex-1 py-2.5 bg-gradient-to-r from-brand-500 to-brand-600 text-white text-xs font-medium rounded-xl text-center hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-sm block">查看详情</a>
                <% if (canDelete) { %>
                <form action="${pageContext.request.contextPath}/delete-product" method="post" class="flex-shrink-0"
                      onsubmit="return confirm('确定要删除这个商品吗？');">
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    <button type="submit" class="w-9 h-9 bg-red-50 border border-red-200 text-red-500 rounded-xl flex items-center justify-center hover:bg-red-100 transition-all btn-press" title="删除">
                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                    </button>
                </form>
                <% } %>
            </div>
        </div>
    <% } %>
    </div>

    <!-- Pagination -->
    <% if (totalPages > 1) {
           String kw = (keyword != null && !keyword.isEmpty()) ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "";
           String ci = (catId != null && !catId.isEmpty()) ? "&categoryId=" + catId : "";
           String tg = (!currentTag.isEmpty()) ? "&tag=" + java.net.URLEncoder.encode(currentTag, "UTF-8") : "";
    %>
    <nav class="flex justify-center items-center gap-2 mt-10 flex-wrap">
        <a href="<%= request.getContextPath() %>/product-list?page=<%= currentPage - 1 %><%= kw %><%= ci %><%= tg %>">
            <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press <%= currentPage == 1 ? "opacity-35 pointer-events-none" : "" %>">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
            </span>
        </a>

        <% int startP = Math.max(1, currentPage - 2);
           int endP   = Math.min(totalPages, currentPage + 2);
           if (startP > 1) { %>
            <a href="<%= request.getContextPath() %>/product-list?page=1<%= kw %><%= ci %><%= tg %>">
                <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press">1</span>
            </a>
            <% if (startP > 2) { %><span class="text-ink-faint px-1">...</span><% } %>
        <% }
           for (int pp = startP; pp <= endP; pp++) { %>
            <a href="<%= request.getContextPath() %>/product-list?page=<%= pp %><%= kw %><%= ci %><%= tg %>">
                <span class="w-10 h-10 flex items-center justify-center rounded-xl font-semibold transition-all btn-press <%= pp == currentPage ? "bg-gradient-to-r from-brand-500 to-brand-600 text-white shadow-lg shadow-brand-500/20" : "border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %>"><%= pp %></span>
            </a>
        <% }
           if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span class="text-ink-faint px-1">...</span><% } %>
            <a href="<%= request.getContextPath() %>/product-list?page=<%= totalPages %><%= kw %><%= ci %><%= tg %>">
                <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press"><%= totalPages %></span>
            </a>
        <% } %>

        <a href="<%= request.getContextPath() %>/product-list?page=<%= currentPage + 1 %><%= kw %><%= ci %><%= tg %>">
            <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press <%= currentPage == totalPages ? "opacity-35 pointer-events-none" : "" %>">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </span>
        </a>

        <span class="text-xs text-ink-muted ml-3">第 <%= currentPage %> / <%= totalPages %> 页 · 共 <%= totalCount %> 件</span>
    </nav>
    <% } %>

    <% } else { %>
    <!-- Empty State -->
    <div class="bg-surface-raised border border-stone-200 rounded-2xl p-16 text-center shadow-sm">
        <div class="mx-auto mb-4 w-16 h-16 bg-stone-100 rounded-2xl flex items-center justify-center">
            <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
        </div>
        <h3 class="text-lg font-display font-semibold text-ink-primary mb-2">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                没有找到 "<%= keyword %>" 相关商品
            <% } else { %>
                暂时没有商品
            <% } %>
        </h3>
        <p class="text-ink-muted text-sm">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                换个关键词试试，或者 <a href="${pageContext.request.contextPath}/product-list" class="text-brand-600 font-semibold hover:underline">查看全部商品</a>
            <% } else { %>
                快去发布第一件商品吧
            <% } %>
        </p>
    </div>
    <% } %>

</main>

<script>
function toggleFavorite(productId, btn) {
    if (!btn) return;
    btn.disabled = true;

    fetch('${pageContext.request.contextPath}/favorite', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'productId=' + encodeURIComponent(productId)
    })
    .then(function(r){ return r.json(); })
    .then(function(data){
        if (data.needLogin) {
            window.location.href = '${pageContext.request.contextPath}/login';
            return;
        }
        if (data.success) {
            var svg = btn.querySelector('svg');
            if (data.favorited) {
                svg.setAttribute('fill', 'currentColor');
                svg.classList.remove('text-ink-muted');
                svg.classList.add('text-red-500');
            } else {
                svg.setAttribute('fill', 'none');
                svg.classList.remove('text-red-500');
                svg.classList.add('text-ink-muted');
            }
        } else {
            alert(data.msg || '操作失败');
        }
        btn.disabled = false;
    })
    .catch(function(){
        alert('网络错误，请重试');
        btn.disabled = false;
    });
}
</script>

</body>
</html>
