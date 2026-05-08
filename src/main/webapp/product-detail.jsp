<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Comment" %>
<%
    Product product = (Product) request.getAttribute("product");
    List<String> detailImages = (List<String>) request.getAttribute("detailImages");
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    User loginUser = (User) session.getAttribute("loginUser");

    int unreadNotifyCount = 0;
    if (loginUser != null) {
        try {
            java.sql.Connection nConn = com.minzu.util.DBUtil.getConnection();
            java.sql.PreparedStatement nPs = nConn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0");
            nPs.setInt(1, loginUser.getUserId());
            java.sql.ResultSet nRs = nPs.executeQuery();
            if (nRs.next()) unreadNotifyCount = nRs.getInt(1);
            nRs.close(); nPs.close(); nConn.close();
        } catch (Exception ignore) {}
    }

    boolean canDelete = false;
    boolean isOwner = false;
    boolean isFavorited = false;
    boolean isSold = false;
    if (loginUser != null && product != null) {
        boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
        isOwner = loginUser.getUserId() == product.getSellerId();
        canDelete = isAdmin || isOwner;
        Boolean favAttr = (Boolean) request.getAttribute("isFavorited");
        isFavorited = favAttr != null && favAttr;
        isSold = "SOLD".equals(product.getProductStatus());
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品详情 - 民大二手交易平台</title>
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
                        accent: { light: '#fed7aa', DEFAULT: '#f97316', dark: '#ea580c' },
                        surface: { DEFAULT: '#fafaf9', raised: '#ffffff', muted: '#f5f5f4' },
                        ink: { primary: '#1c1917', secondary: '#44403c', muted: '#78716c', faint: '#a8a29e' },
                        stroke: { DEFAULT: '#e7e5e4', subtle: '#f5f5f4' },
                    },
                    fontFamily: {
                        display: ['Outfit', 'sans-serif'],
                        body: ['Noto Sans SC', 'sans-serif']
                    },
                    borderRadius: {
                        'soft': '12px',
                        'card': '16px',
                        'xl': '20px',
                        'hero': '24px'
                    },
                    boxShadow: {
                        'soft': '0 2px 8px rgba(28, 25, 23, 0.06)',
                        'card': '0 4px 16px rgba(28, 25, 23, 0.08)',
                        'raised': '0 8px 32px rgba(28, 25, 23, 0.12)',
                        'glow': '0 0 0 4px rgba(34, 197, 94, 0.15)'
                    },
                }
            }
        }
    </script>
    <style>
        @media (prefers-reduced-motion: no-preference) {
            .hover-lift { transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.25s cubic-bezier(0.16, 1, 0.3, 1); }
            .hover-lift:hover { transform: translateY(-6px); box-shadow: 0 12px 40px rgba(28, 25, 23, 0.15); }
            .btn-press { transition: transform 0.15s cubic-bezier(0.16, 1, 0.3, 1), background-color 0.15s ease; }
            .btn-press:active { transform: scale(0.97); }
            .img-zoom { transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1); }
            .img-zoom:hover { transform: scale(1.05); }
            .animate-up { animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) both; }
            .animate-fade { animation: fadeIn 0.5s ease-out both; }
            @keyframes slideUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
            @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
            .carousel-dot-active { background: white; transform: scale(1.2); }
        }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        }
        ::-webkit-scrollbar { width: 10px; height: 10px; }
        ::-webkit-scrollbar-track { background: #f5f5f4; border-radius: 10px; }
        ::-webkit-scrollbar-thumb { background: #d6d3d1; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #a8a29e; }
        .price-tag { background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%); padding: 4px 14px; border-radius: 8px; }
        .thumb-active { border-color: #22c55e; box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.2); }
        .fav-btn-active { background: #fff1f2; color: #e11d48; border-color: #fecdd3; }
        .fav-btn-active:hover { background: #ffe4e6; }
        .notif-badge {
            background: #ef4444; color: #fff;
            border-radius: 10px; font-size: 10px; line-height: 1;
            padding: 1px 5px; font-weight: 700;
            min-width: 16px; text-align: center;
        }
    </style>
</head>
<body class="bg-surface font-body text-ink-primary antialiased">

<!-- Nav -->
<nav class="fixed top-4 left-4 right-4 z-50 animate-up">
    <div class="bg-surface-raised/95 backdrop-blur-xl rounded-hero border border-stroke shadow-soft">
        <div class="max-w-7xl mx-auto px-5 h-14 flex items-center justify-between">
            <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-3 group cursor-pointer">
                <div class="w-9 h-9 bg-brand-500 rounded-soft flex items-center justify-center shadow-glow">
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </div>
                <div class="flex flex-col">
                    <span class="font-display font-bold text-ink-primary text-sm tracking-tight">民大二手</span>
                    <span class="text-xs text-ink-muted -mt-0.5">让闲置流通</span>
                </div>
            </a>
            <div class="hidden md:flex items-center gap-1 flex-wrap">
                <a href="${pageContext.request.contextPath}/index.jsp" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">首页</a>
                <a href="${pageContext.request.contextPath}/pickup-locations.jsp" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">自提点</a>
                <a href="${pageContext.request.contextPath}/product-list" class="px-3 py-2 rounded-lg text-sm font-medium text-brand-600 bg-brand-50 transition-colors cursor-pointer">浏览商品</a>
                <% if (loginUser != null) { %>
                <a href="${pageContext.request.contextPath}/my-favorites" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">我的收藏</a>
                <a href="${pageContext.request.contextPath}/messages" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">私信</a>
                <a href="${pageContext.request.contextPath}/my-products" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">我的商品</a>
                <a href="${pageContext.request.contextPath}/orders" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer">我的订单</a>
                <a href="${pageContext.request.contextPath}/notifications" class="px-3 py-2 rounded-lg text-sm font-medium text-ink-secondary hover:text-ink-primary hover:bg-surface-muted transition-colors cursor-pointer relative">
                    通知
                    <% if (unreadNotifyCount > 0) { %>
                    <span class="notif-badge absolute -top-0.5 -right-0.5"><%= unreadNotifyCount %></span>
                    <% } %>
                </a>
                <% } %>
            </div>
            <div class="flex items-center gap-3">
                <% if (loginUser != null) { %>
                    <a href="${pageContext.request.contextPath}/publish-product" class="px-3 py-2 text-sm font-medium bg-gradient-to-r from-brand-500 to-brand-600 text-white rounded-lg hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-sm shadow-brand-500/20 flex items-center gap-1">发布商品</a>
                    <a href="${pageContext.request.contextPath}/logout" class="text-sm text-ink-muted hover:text-red-500 transition-colors px-2 py-1.5 cursor-pointer">退出</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="text-sm text-ink-muted hover:text-ink-primary transition-colors px-2 py-1.5 cursor-pointer">登录</a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<!-- Main content -->
<main class="pt-24 pb-16 px-4">
    <div class="max-w-6xl mx-auto space-y-6">

        <!-- Back link -->
        <section class="animate-up">
            <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 text-sm text-ink-muted hover:text-brand-600 cursor-pointer transition-colors">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                返回商品列表
            </a>
        </section>

        <% if (product == null) { %>
        <!-- Empty state -->
        <section class="animate-up">
            <div class="bg-surface-raised rounded-hero border border-stroke shadow-card p-16 text-center">
                <div class="mx-auto mb-4 w-16 h-16 bg-stone-100 rounded-2xl flex items-center justify-center">
                    <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
                <h3 class="font-display font-bold text-lg text-ink-primary mb-2">商品不存在</h3>
                <p class="text-ink-muted text-sm">该商品可能已下架或不存在。</p>
                <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 mt-4 px-5 py-2.5 bg-brand-500 text-white font-semibold rounded-soft hover:bg-brand-600 transition-all btn-press">浏览其他商品</a>
            </div>
        </section>
        <% } else {
            String cover = product.getCoverImageUrl();

            String detailConditionText = "未填写";
            if (product.getConditionLevel() != null) {
                switch (product.getConditionLevel()) {
                    case "NEW": detailConditionText = "全新"; break;
                    case "NINETY_NEW": detailConditionText = "九成新"; break;
                    case "EIGHTY_NEW": detailConditionText = "八成新"; break;
                    case "SEVENTY_NEW": detailConditionText = "七成新及以下"; break;
                    default: detailConditionText = product.getConditionLevel();
                }
            }
        %>

        <!-- Product detail main section -->
        <section class="animate-up" style="animation-delay: 0.1s;">
            <div class="bg-surface-raised rounded-hero border border-stroke shadow-card overflow-hidden">
                <div class="flex flex-col lg:flex-row gap-8 p-8">

                    <!-- Left: Image area -->
                    <div class="lg:w-1/2 space-y-4">
                        <!-- Main image -->
                        <div class="aspect-[4/3] bg-gradient-to-br from-slate-100 to-slate-50 rounded-card overflow-hidden relative">
                            <% if (cover != null && !"".equals(cover)) { %>
                                <img id="mainImage" src="<%= cover %>" alt="商品主图" class="w-full h-full object-cover img-zoom cursor-zoom-in" onclick="openImagePreview('<%= cover %>')">
                            <% } else if (detailImages != null && !detailImages.isEmpty()) { %>
                                <img id="mainImage" src="<%= detailImages.get(0) %>" alt="商品主图" class="w-full h-full object-cover img-zoom cursor-zoom-in" onclick="openImagePreview('<%= detailImages.get(0) %>')">
                            <% } else { %>
                                <div class="w-full h-full flex items-center justify-center text-ink-faint">
                                    <svg class="w-16 h-16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                </div>
                            <% } %>
                            <!-- Sold badge -->
                            <% if (isSold) { %>
                            <div class="absolute top-4 right-4 px-4 py-2 bg-slate-600 text-white font-semibold rounded-lg shadow-raised">已售出</div>
                            <% } %>
                        </div>

                        <!-- Thumbnails -->
                        <div class="flex gap-3 flex-wrap">
                            <% if (cover != null && !"".equals(cover)) { %>
                                <button class="w-20 h-20 rounded-soft overflow-hidden border-2 thumb-active cursor-pointer transition-all hover:border-brand-400" onclick="changeMainImage('<%= cover %>', this)">
                                    <img src="<%= cover %>" alt="封面图" class="w-full h-full object-cover">
                                </button>
                            <% } %>
                            <% if (detailImages != null && !detailImages.isEmpty()) {
                                   for (String img : detailImages) { %>
                                <button class="w-20 h-20 rounded-soft overflow-hidden border-2 border-stroke cursor-pointer transition-all hover:border-brand-400" onclick="changeMainImage('<%= img %>', this)">
                                    <img src="<%= img %>" alt="详情图" class="w-full h-full object-cover">
                                </button>
                            <%     }
                               } %>
                            <% if ((cover == null || "".equals(cover)) && (detailImages == null || detailImages.isEmpty())) { %>
                                <div class="w-20 h-20 rounded-soft bg-stone-100 flex items-center justify-center text-ink-faint text-xs">暂无图片</div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Right: Info area -->
                    <div class="lg:w-1/2 space-y-6">
                        <!-- Title -->
                        <div>
                            <div class="flex items-center gap-3 mb-2 flex-wrap">
                                <h1 class="font-display font-bold text-2xl lg:text-3xl text-ink-primary"><%= product.getTitle() %></h1>
                                <% if (isSold) { %>
                                <span class="px-3 py-1 bg-slate-200 text-slate-600 text-sm font-semibold rounded-lg">已售出</span>
                                <% } %>
                            </div>
                            <%-- Tags --%>
                            <%
                                String detailTags = product.getTags();
                                if (detailTags != null && !detailTags.trim().isEmpty()) {
                                    String[] tagArr = detailTags.split(",");
                                    String[] tagBgs = {"#dbeafe","#fce7f3","#d1fae5","#fef3c7","#ede9fe","#ffedd5"};
                                    String[] tagTexts = {"#1d4ed8","#be185d","#065f46","#92400e","#5b21b6","#9a3412"};
                                    String[] tagBorders = {"#93c5fd","#f9a8d4","#6ee7b7","#fcd34d","#c4b5fd","#fdba74"};
                            %>
                            <div class="flex flex-wrap gap-2 mt-2">
                                <% for (int ti = 0; ti < tagArr.length; ti++) {
                                    String tagName = tagArr[ti].trim();
                                    if (tagName.isEmpty()) continue;
                                    int ci = Math.abs(tagName.hashCode()) % 6;
                                %>
                                <a href="${pageContext.request.contextPath}/product-list?tag=<%= java.net.URLEncoder.encode(tagName, "UTF-8") %>"
                                   class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium hover:shadow-md transition-all"
                                   style="background:<%= tagBgs[ci] %>;color:<%= tagTexts[ci] %>;border:1px solid <%= tagBorders[ci] %>">
                                    <%= tagName %>
                                </a>
                                <% } %>
                            </div>
                            <% } %>
                        </div>

                        <!-- Price -->
                        <div class="bg-gradient-to-r from-amber-50 to-orange-50 rounded-card border border-amber-200 p-5">
                            <div class="flex items-baseline gap-2">
                                <span class="text-3xl font-bold text-amber-700">¥<%= product.getPrice() %></span>
                                <% if (product.getOriginalPrice() != null) { %>
                                <span class="text-lg text-ink-faint line-through">原价 ¥<%= product.getOriginalPrice() %></span>
                                <% } %>
                            </div>
                            <% if (isSold) { %>
                            <p class="text-sm text-ink-muted mt-3">该商品已售出，您可以浏览其他商品或联系卖家了解更多。</p>
                            <% } %>
                        </div>

                        <!-- Meta panel -->
                        <div class="bg-surface-muted rounded-card border border-stroke-subtle divide-y divide-stroke">
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">商品成色</span>
                                <span class="text-sm font-semibold text-ink-primary"><%= detailConditionText %></span>
                            </div>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">商品分类</span>
                                <span class="text-sm font-semibold text-ink-primary"><%= product.getCategoryName() != null ? product.getCategoryName() : "未分类" %></span>
                            </div>
                            <% if (product.getPickupPointName() != null && !product.getPickupPointName().isEmpty()) { %>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">自提点</span>
                                <span class="text-sm font-semibold text-brand-600 flex items-center gap-1">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                                    <%= product.getPickupPointName() %>
                                </span>
                            </div>
                            <% } %>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">卖家</span>
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
                            </div>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">浏览量</span>
                                <span class="text-sm font-semibold text-ink-primary"><%= product.getViewCount() %> 次</span>
                            </div>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">收藏量</span>
                                <span class="text-sm font-semibold text-ink-primary" id="favCountDisplay"><%= product.getFavoriteCount() %> 人</span>
                            </div>
                            <div class="flex items-center py-4 px-5">
                                <span class="w-24 text-sm text-ink-muted">发布时间</span>
                                <span class="text-sm font-semibold text-ink-primary"><%= product.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(product.getCreatedAt()) : "暂无" %></span>
                            </div>
                        </div>

                        <!-- Action buttons -->
                        <div class="flex flex-wrap gap-3">
                            <a href="${pageContext.request.contextPath}/product-list" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-surface-raised text-ink-secondary font-semibold rounded-soft border border-stroke cursor-pointer hover:border-brand-400 hover:text-brand-600">
                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                                返回列表
                            </a>

                            <%-- Favorite button (not owner's own product) --%>
                            <% if (loginUser != null && !isOwner) { %>
                                <button id="favBtn"
                                        class="btn-press inline-flex items-center gap-2 px-5 py-3 <%= isFavorited ? "fav-btn-active" : "bg-surface-raised text-ink-muted border border-stroke hover:border-rose-300 hover:text-rose-500" %> font-semibold rounded-soft cursor-pointer"
                                        onclick="toggleFavorite(<%= product.getProductId() %>)">
                                    <svg id="favIcon" class="w-4 h-4" viewBox="0 0 24 24" <%= isFavorited ? "fill=" : "" %>"currentColor" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                                    <span id="favBtnText"><%= isFavorited ? "已收藏" : "收藏" %></span>
                                </button>
                            <% } else if (loginUser == null) { %>
                                <a href="${pageContext.request.contextPath}/login" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-surface-raised text-ink-muted font-semibold rounded-soft border border-stroke cursor-pointer hover:border-rose-300 hover:text-rose-500">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                                    登录后收藏
                                </a>
                            <% } %>

                            <%-- Initiate transaction button: not owner, logged in, not sold --%>
                            <% if (loginUser == null) { %>
                                <a href="${pageContext.request.contextPath}/login" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-brand-500 text-white font-semibold rounded-soft shadow-soft cursor-pointer hover:bg-brand-600">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                                    登录后发起交易
                                </a>
                            <% } else if (!isOwner && !isSold) { %>
                                <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;margin:0;"
                                      onsubmit="return confirm('确定要向卖家发起交易请求吗？');">
                                    <input type="hidden" name="action" value="create">
                                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                    <button type="submit" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-brand-500 text-white font-semibold rounded-soft shadow-soft cursor-pointer hover:bg-brand-600">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                                        发起交易
                                    </button>
                                </form>
                                <button type="button" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-surface-raised text-amber-600 font-semibold rounded-soft border border-amber-300 cursor-pointer hover:bg-amber-50 hover:border-amber-400" onclick="document.getElementById('offerModal').classList.remove('hidden');document.getElementById('offerModal').classList.add('flex');">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                                    出价
                                </button>
                            <% } %>

                            <%-- Contact seller / Edit product --%>
                            <% if (loginUser == null) { %>
                                <a href="${pageContext.request.contextPath}/login" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-blue-50 text-blue-600 font-semibold rounded-soft border border-blue-200 cursor-pointer hover:bg-blue-100">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                                    登录后联系卖家
                                </a>
                            <% } else if (isOwner) { %>
                                <a href="${pageContext.request.contextPath}/edit-product?id=<%= product.getProductId() %>" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-blue-50 text-blue-600 font-semibold rounded-soft border border-blue-200 cursor-pointer hover:bg-blue-100">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    编辑商品
                                </a>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/messages?with=<%= product.getSellerId() %>&productId=<%= product.getProductId() %>" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-blue-50 text-blue-600 font-semibold rounded-soft border border-blue-200 cursor-pointer hover:bg-blue-100">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                                    联系卖家
                                </a>
                            <% } %>

                            <%-- Delete button --%>
                            <% if (canDelete) { %>
                                <form action="${pageContext.request.contextPath}/delete-product"
                                      method="post" style="display:inline;margin:0;"
                                      onsubmit="return confirm('确定要删除这个商品吗？');">
                                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                    <button type="submit" class="btn-press inline-flex items-center gap-2 px-5 py-3 bg-rose-50 text-rose-600 font-semibold rounded-soft border border-rose-200 cursor-pointer hover:bg-rose-100">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                        删除商品
                                    </button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <%-- Report section (logged in, not owner, not sold) --%>
        <% if (loginUser != null && !isOwner && !isSold) { %>
        <section class="animate-fade" style="animation-delay: 0.25s;">
            <div class="bg-rose-50 rounded-card border border-rose-200 p-6">
                <h2 class="font-display font-bold text-lg text-rose-700 mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    举报此商品
                </h2>
                <form action="${pageContext.request.contextPath}/report" method="post"
                      onsubmit="return confirm('确定要举报该商品吗？请确认举报内容属实。');">
                    <input type="hidden" name="action" value="submit">
                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                    <div class="flex flex-col md:flex-row gap-4">
                        <textarea name="reason" rows="3" required class="flex-1 px-4 py-3 bg-surface-raised border border-rose-200 rounded-soft text-sm resize-none focus:outline-none focus:border-rose-400" placeholder="请描述举报原因，如：虚假信息、违禁品、欺诈行为等"></textarea>
                        <button type="submit" class="btn-press px-6 py-3 bg-rose-500 text-white font-semibold rounded-soft cursor-pointer hover:bg-rose-600 self-start md:self-end">提交举报</button>
                    </div>
                </form>
                <p class="text-xs text-ink-muted mt-3 flex items-center gap-1">
                    <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    举报后管理员将尽快审核处理。请确保举报内容真实有效，恶意举报可能导致账号受限。
                </p>
            </div>
        </section>
        <% } %>

        <%-- Carousel from imageUrls --%>
        <%
            String imageUrls = product.getImageUrls();
            if (imageUrls != null && !imageUrls.trim().isEmpty()) {
                String[] urls = imageUrls.split(",");
                java.util.List<String> carouselImages = new java.util.ArrayList<>();
                if (product.getCoverImageUrl() != null && !product.getCoverImageUrl().isEmpty()) {
                    carouselImages.add(product.getCoverImageUrl());
                }
                for (String url : urls) {
                    String trimmed = url.trim();
                    if (!trimmed.isEmpty()) {
                        carouselImages.add(trimmed);
                    }
                }
                if (!carouselImages.isEmpty()) {
        %>
        <section class="animate-fade" style="animation-delay: 0.2s;">
            <div class="bg-surface-raised rounded-card border border-stroke shadow-soft p-6">
                <h2 class="font-display font-bold text-lg text-ink-primary mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    商品图片轮播
                </h2>
                <div class="relative overflow-hidden rounded-soft" id="carousel">
                    <div class="flex transition-transform duration-400" id="carouselTrack" style="transform: translateX(-0%)">
                        <% for (String img : carouselImages) { %>
                        <div class="w-full flex-shrink-0">
                            <img src="<%= img %>" alt="商品图片" class="w-full h-48 object-cover cursor-zoom-in" onclick="openImagePreview('<%= img %>')">
                        </div>
                        <% } %>
                    </div>
                    <% if (carouselImages.size() > 1) { %>
                    <button class="absolute left-2 top-1/2 -translate-y-1/2 w-10 h-10 bg-black/40 text-white rounded-full flex items-center justify-center hover:bg-black/60 cursor-pointer" onclick="slideCarousel(-1)">&lsaquo;</button>
                    <button class="absolute right-2 top-1/2 -translate-y-1/2 w-10 h-10 bg-black/40 text-white rounded-full flex items-center justify-center hover:bg-black/60 cursor-pointer" onclick="slideCarousel(1)">&rsaquo;</button>
                    <div class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-2">
                        <% for (int idx = 0; idx < carouselImages.size(); idx++) { %>
                        <span class="<%= idx == 0 ? "carousel-dot-active " : "" %>w-2.5 h-2.5 bg-white/50 rounded-full cursor-pointer" onclick="goToSlide(<%= idx %>)"></span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
        </section>
        <%  }
        } %>

        <%-- Description --%>
        <section class="animate-fade" style="animation-delay: 0.15s;">
            <div class="bg-surface-raised rounded-card border border-stroke shadow-soft p-6">
                <h2 class="font-display font-bold text-lg text-ink-primary mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                    商品描述
                </h2>
                <p class="text-sm text-ink-secondary leading-relaxed whitespace-pre-wrap">
                    <%= product.getDescription() != null && !"".equals(product.getDescription().trim())
                            ? product.getDescription() : "卖家暂时没有填写商品描述。" %>
                </p>
            </div>
        </section>

        <%-- Detail images --%>
        <section class="animate-fade" style="animation-delay: 0.2s;">
            <div class="bg-surface-raised rounded-card border border-stroke shadow-soft p-6">
                <h2 class="font-display font-bold text-lg text-ink-primary mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    详情图片
                </h2>
                <% if (detailImages != null && !detailImages.isEmpty()) { %>
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    <% for (String img : detailImages) { %>
                    <div class="aspect-square bg-gradient-to-br from-slate-100 to-slate-50 rounded-soft overflow-hidden">
                        <img src="<%= img %>" alt="商品详情图" class="w-full h-full object-cover img-zoom cursor-zoom-in" onclick="openImagePreview('<%= img %>')">
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <p class="text-sm text-ink-muted">暂无详情图片。</p>
                <% } %>
            </div>
        </section>

        <%-- Comments Section --%>
        <section class="animate-fade" style="animation-delay: 0.25s;">
            <div class="bg-surface-raised rounded-card border border-stroke shadow-soft p-6">
                <h2 class="font-display text-lg font-bold text-ink-primary mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    留言区 (<%= comments != null ? comments.size() : 0 %>)
                </h2>

                <% if (comments != null && !comments.isEmpty()) { %>
                    <% for (Comment comment : comments) {
                        String displayName = comment.getDisplayName();
                        String initial = displayName.substring(0, Math.min(1, displayName.length()));
                        boolean isSellerComment = comment.getUserId() == product.getSellerId();
                    %>
                    <div class="bg-surface-muted border border-stone-200 rounded-xl p-4 mb-3">
                        <div class="flex items-center gap-2 mb-2">
                            <div class="w-8 h-8 bg-brand-100 rounded-full flex items-center justify-center text-brand-600 text-sm font-bold"><%= initial %></div>
                            <span class="text-sm font-semibold text-ink-primary"><%= displayName %></span>
                            <% if (isSellerComment) { %><span class="text-xs bg-brand-50 text-brand-600 px-2 py-0.5 rounded-full">卖家</span><% } %>
                            <span class="text-xs text-ink-muted"><%= comment.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(comment.getCreatedAt()) : "" %></span>
                        </div>
                        <p class="text-sm text-ink-primary"><%= comment.getContent() %></p>

                        <%-- Replies --%>
                        <% if (comment.getReplies() != null && !comment.getReplies().isEmpty()) { %>
                            <% for (Comment reply : comment.getReplies()) {
                                String replyName = reply.getDisplayName();
                                String replyInitial = replyName.substring(0, Math.min(1, replyName.length()));
                                boolean isSellerReply = reply.getUserId() == product.getSellerId();
                            %>
                            <div class="ml-8 mt-2 bg-stone-50 rounded-lg p-3">
                                <div class="flex items-center gap-2 mb-1">
                                    <div class="w-6 h-6 bg-brand-100 rounded-full flex items-center justify-center text-brand-600 text-xs font-bold"><%= replyInitial %></div>
                                    <span class="text-sm font-semibold text-ink-primary"><%= replyName %></span>
                                    <% if (isSellerReply) { %><span class="text-xs bg-brand-50 text-brand-600 px-2 py-0.5 rounded-full">卖家</span><% } %>
                                    <span class="text-xs text-ink-muted"><%= reply.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(reply.getCreatedAt()) : "" %></span>
                                </div>
                                <p class="text-sm text-ink-primary"><%= reply.getContent() %></p>
                            </div>
                            <% } %>
                        <% } %>

                        <%-- Reply button + form --%>
                        <% if (loginUser != null) { %>
                        <button onclick="toggleReply(<%= comment.getCommentId() %>)" class="text-xs text-brand-600 mt-2 hover:text-brand-700 cursor-pointer">回复</button>
                        <form method="post" action="${pageContext.request.contextPath}/comment" class="hidden mt-2" id="reply-form-<%= comment.getCommentId() %>">
                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                            <input type="hidden" name="parentId" value="<%= comment.getCommentId() %>">
                            <textarea name="content" class="w-full px-3 py-2 border border-stone-200 rounded-lg text-sm input-focus-ring focus:border-brand-500 transition-colors" rows="2" placeholder="回复 <%= displayName %>..." maxlength="500"></textarea>
                            <button type="submit" class="mt-1 px-3 py-1.5 bg-brand-500 text-white text-xs rounded-lg hover:bg-brand-600 transition-colors btn-press">发送</button>
                        </form>
                        <% } %>
                    </div>
                    <% } %>
                <% } else { %>
                <p class="text-sm text-ink-muted py-4 text-center">暂无留言，快来抢沙发吧~</p>
                <% } %>

                <%-- New comment form --%>
                <% if (loginUser != null) { %>
                <form method="post" action="${pageContext.request.contextPath}/comment" class="mt-4">
                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                    <textarea name="content" maxlength="500" placeholder="写下你的留言..." rows="3"
                        class="w-full px-4 py-3 bg-surface-muted border border-stone-200 rounded-lg text-sm input-focus-ring focus:border-brand-500 transition-colors"></textarea>
                    <div class="flex justify-between items-center mt-2">
                        <span class="text-xs text-ink-faint">最多500字</span>
                        <button type="submit" class="px-5 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">发表留言</button>
                    </div>
                </form>
                <% } else { %>
                <p class="text-sm text-ink-muted mt-4 text-center">
                    <a href="${pageContext.request.contextPath}/login" class="text-brand-600 hover:text-brand-700">登录</a>后即可留言
                </p>
                <% } %>
            </div>
        </section>

        <% } %>

    </div>
</main>

<!-- Image Lightbox -->
<div id="imageModal" class="fixed inset-0 bg-black/80 z-50 items-center justify-center hidden" onclick="if(event.target===this)closeLightbox()">
    <button class="absolute top-6 right-6 text-white/80 hover:text-white cursor-pointer z-10" onclick="closeLightbox()">
        <svg class="w-8 h-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </button>
    <div class="absolute top-6 left-1/2 -translate-x-1/2 text-white/80 text-sm font-medium" id="lightboxCounter">1 / 1</div>
    <button class="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 hover:bg-white/20 text-white rounded-full flex items-center justify-center cursor-pointer transition-colors" onclick="lightboxPrev()">
        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <button class="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 hover:bg-white/20 text-white rounded-full flex items-center justify-center cursor-pointer transition-colors" onclick="lightboxNext()">
        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </button>
    <img id="modalImage" src="" class="max-w-4xl max-h-[85vh] object-contain rounded-card shadow-raised">
</div>

<!-- Offer Modal -->
<% if (loginUser != null && !isOwner && !isSold) { %>
<div id="offerModal" class="fixed inset-0 bg-black/50 z-50 items-center justify-center hidden" onclick="if(event.target===this)closeOfferModal()">
    <div class="bg-surface-raised rounded-hero shadow-raised w-full max-w-md mx-4 p-6 relative">
        <button type="button" class="absolute top-4 right-4 text-ink-muted hover:text-ink-primary cursor-pointer" onclick="closeOfferModal()">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
        <h3 class="font-display font-bold text-lg text-ink-primary mb-4">向卖家出价</h3>
        <form action="${pageContext.request.contextPath}/offer" method="post" onsubmit="return validateOfferForm()">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-ink-secondary mb-1.5">出价金额 <span class="text-red-500">*</span></label>
                    <div class="relative">
                        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-ink-muted font-medium">¥</span>
                        <input type="number" name="offerPrice" id="offerPriceInput" min="0.01" step="0.01" required
                               class="w-full pl-8 pr-4 py-2.5 bg-surface border border-stone-200 rounded-soft text-sm focus:outline-none focus:border-brand-400 focus:ring-2 focus:ring-brand-100"
                               placeholder="输入你的出价">
                    </div>
                    <p class="text-xs text-ink-muted mt-1">商品标价：¥<%= product.getPrice() %></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-ink-secondary mb-1.5">留言 <span class="text-ink-faint">(可选)</span></label>
                    <textarea name="message" rows="3" maxlength="200"
                              class="w-full px-4 py-2.5 bg-surface border border-stone-200 rounded-soft text-sm resize-none focus:outline-none focus:border-brand-400 focus:ring-2 focus:ring-brand-100"
                              placeholder="给卖家留言，说明你的出价理由..."></textarea>
                    <p class="text-xs text-ink-muted mt-1">最多200字</p>
                </div>
            </div>
            <div class="flex gap-3 mt-6">
                <button type="button" onclick="closeOfferModal()" class="flex-1 px-4 py-2.5 bg-surface border border-stone-200 text-ink-muted font-medium rounded-soft text-sm hover:border-stone-300 hover:text-ink-primary transition-colors cursor-pointer">取消</button>
                <button type="submit" class="flex-1 px-4 py-2.5 bg-amber-500 text-white font-medium rounded-soft text-sm hover:bg-amber-600 transition-colors btn-press cursor-pointer">提交出价</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<script>
function closeOfferModal() {
    var modal = document.getElementById('offerModal');
    if (modal) { modal.classList.add('hidden'); modal.classList.remove('flex'); }
}
function validateOfferForm() {
    var price = document.getElementById('offerPriceInput').value;
    if (!price || parseFloat(price) <= 0) {
        alert('请输入有效的出价金额');
        return false;
    }
    return true;
}
document.addEventListener('keydown', function(e) {
    var modal = document.getElementById('offerModal');
    if (modal && !modal.classList.contains('hidden') && e.key === 'Escape') closeOfferModal();
});
</script>

<script>
/* ====================================================
   Bug fix: Use URLSearchParams + explicit Content-Type
   Reason: FormData sends content-type as multipart/form-data,
           Servlet request.getParameter() cannot read it
   ==================================================== */
function toggleFavorite(productId) {
    var btn = document.getElementById('favBtn');
    var icon = document.getElementById('favIcon');
    var text = document.getElementById('favBtnText');
    var countEl = document.getElementById('favCountDisplay');
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
            if (data.favorited) {
                btn.className = 'btn-press inline-flex items-center gap-2 px-5 py-3 fav-btn-active font-semibold rounded-soft cursor-pointer';
                icon.setAttribute('fill', 'currentColor');
                text.textContent = '已收藏';
            } else {
                btn.className = 'btn-press inline-flex items-center gap-2 px-5 py-3 bg-surface-raised text-ink-muted border border-stroke hover:border-rose-300 hover:text-rose-500 font-semibold rounded-soft cursor-pointer';
                icon.removeAttribute('fill');
                text.textContent = '收藏';
            }
            if (countEl && data.count !== undefined) {
                countEl.textContent = data.count + ' 人';
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

function changeMainImage(src, btn) {
    var mainImg = document.getElementById('mainImage');
    if (mainImg) mainImg.src = src;
    document.querySelectorAll('.thumb-active').forEach(function(t){ t.classList.remove('thumb-active'); });
    if (btn) btn.classList.add('thumb-active');
}

/* Carousel */
var currentSlide = 0;
var totalSlides = document.querySelectorAll('#carouselTrack .w-full').length;
function slideCarousel(dir) {
    if (totalSlides === 0) return;
    currentSlide = (currentSlide + dir + totalSlides) % totalSlides;
    updateCarousel();
}
function goToSlide(index) {
    currentSlide = index;
    updateCarousel();
}
function updateCarousel() {
    var track = document.getElementById('carouselTrack');
    if (track) track.style.transform = 'translateX(-' + (currentSlide * 100) + '%)';
    var dots = document.querySelectorAll('#carousel .rounded-full');
    dots.forEach(function(d, i) {
        d.classList.toggle('carousel-dot-active', i === currentSlide);
        d.style.background = i === currentSlide ? 'white' : 'rgba(255,255,255,0.5)';
    });
}

/* Image Lightbox */
var lightboxImages = [];
var lightboxIndex = 0;
<% if (product != null) { %>
<%     String lbCover = product.getCoverImageUrl(); %>
<%     if (lbCover != null && !lbCover.isEmpty()) { %>
lightboxImages.push('<%= lbCover %>');
<%     } %>
<%     String lbUrls = product.getImageUrls(); %>
<%     if (lbUrls != null && !lbUrls.trim().isEmpty()) { %>
<%         for (String u : lbUrls.split(",")) { %>
<%             String t = u.trim(); %>
<%             if (!t.isEmpty()) { %>
lightboxImages.push('<%= t %>');
<%             } %>
<%         } %>
<%     } %>
<% } %>

function openImagePreview(src) {
    if (lightboxImages.length === 0) lightboxImages = [src];
    var idx = lightboxImages.indexOf(src);
    if (idx === -1) { lightboxImages.push(src); idx = lightboxImages.length - 1; }
    lightboxIndex = idx;
    updateLightbox();
    var modal = document.getElementById('imageModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
}
function closeLightbox() {
    var modal = document.getElementById('imageModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
    document.getElementById('modalImage').src = '';
}
function lightboxPrev() {
    if (lightboxImages.length <= 1) return;
    lightboxIndex = (lightboxIndex - 1 + lightboxImages.length) % lightboxImages.length;
    updateLightbox();
}
function lightboxNext() {
    if (lightboxImages.length <= 1) return;
    lightboxIndex = (lightboxIndex + 1) % lightboxImages.length;
    updateLightbox();
}
function updateLightbox() {
    document.getElementById('modalImage').src = lightboxImages[lightboxIndex];
    document.getElementById('lightboxCounter').textContent = (lightboxIndex + 1) + ' / ' + lightboxImages.length;
}
document.addEventListener('keydown', function(e) {
    var modal = document.getElementById('imageModal');
    if (modal.classList.contains('hidden')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowLeft') lightboxPrev();
    if (e.key === 'ArrowRight') lightboxNext();
});

function toggleReply(commentId) {
    var form = document.getElementById('reply-form-' + commentId);
    if (form) form.classList.toggle('hidden');
}
</script>

</body>
</html>
