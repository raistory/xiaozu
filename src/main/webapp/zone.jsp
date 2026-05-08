<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.Product" %>
<%
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    String type = request.getAttribute("type") != null ? (String) request.getAttribute("type") : "graduation";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int) request.getAttribute("totalPages")  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? (int) request.getAttribute("totalCount")  : 0;

    boolean isGraduation = "graduation".equals(type);
    String zoneTitle = isGraduation ? "毕业季专区" : "教材专区";
    String zoneSubtitle = isGraduation
            ? "毕业不闲置，好物传下去。发现学长学姐们的优质二手好物。"
            : "教材不必买新的，学长学姐的笔记更珍贵。找到你需要的教材吧。";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= zoneTitle %> - 民大二手交易平台</title>
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
        .card-enter { animation: cardIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) both; }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(30px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .price-tag { position: relative; overflow: hidden; }
        .price-tag::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transform: translateX(-100%);
            animation: shimmer 2.5s infinite;
        }
        @keyframes shimmer { 100% { transform: translateX(100%); } }
        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .img-zoom, .card-enter { animation: none; transition: none; }
            .hover-lift:hover, .img-zoom:hover { transform: none; }
            .btn-press:active { transform: none; }
            .price-tag::after { animation: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/20 to-stone-100">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value=""/>
</jsp:include>

<main class="max-w-7xl mx-auto px-4 py-6">

    <!-- Hero Banner -->
    <div class="bg-gradient-to-br from-brand-500 to-brand-700 rounded-2xl p-8 md:p-12 mb-8 text-white relative overflow-hidden">
        <div class="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/4"></div>
        <div class="absolute bottom-0 left-0 w-40 h-40 bg-white/5 rounded-full translate-y-1/2 -translate-x-1/4"></div>
        <div class="relative z-10">
            <h1 class="font-display text-3xl md:text-4xl font-bold mb-3"><%= zoneTitle %></h1>
            <p class="text-brand-100 text-lg max-w-xl"><%= zoneSubtitle %></p>
            <div class="mt-4 flex gap-3">
                <a href="${pageContext.request.contextPath}/zone?type=graduation"
                   class="px-5 py-2 rounded-full text-sm font-medium transition-all btn-press
                          <%= isGraduation ? "bg-white text-brand-700 shadow-lg" : "bg-white/20 text-white hover:bg-white/30" %>">
                    毕业季专区
                </a>
                <a href="${pageContext.request.contextPath}/zone?type=textbook"
                   class="px-5 py-2 rounded-full text-sm font-medium transition-all btn-press
                          <%= !isGraduation ? "bg-white text-brand-700 shadow-lg" : "bg-white/20 text-white hover:bg-white/30" %>">
                    教材专区
                </a>
            </div>
        </div>
    </div>

    <!-- Result info -->
    <div class="flex items-center justify-between mb-6">
        <span class="text-sm text-ink-muted">
            <span class="text-ink-primary font-semibold"><%= zoneTitle %></span> · 共 <span class="text-ink-primary font-semibold"><%= totalCount %></span> 件商品
        </span>
    </div>

    <!-- Product Grid -->
    <% if (productList != null && !productList.isEmpty()) { %>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
    <% int delayIdx = 0;
       for (Product p : productList) {
           delayIdx++;
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
        <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>"
           class="card-enter bg-surface-raised border border-stone-200 rounded-xl overflow-hidden hover-lift flex flex-col group"
           style="animation-delay: <%= delayIdx * 0.05 %>s; text-decoration: none; color: inherit;">
            <div class="relative overflow-hidden">
                <% if (p.getCoverImageUrl() != null && !"".equals(p.getCoverImageUrl())) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" class="w-full h-44 object-cover img-zoom" loading="lazy">
                <% } else { %>
                    <div class="w-full h-44 bg-stone-100 flex items-center justify-center">
                        <svg class="w-12 h-12 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    </div>
                <% } %>
                <div class="absolute bottom-3 left-3">
                    <span class="px-2.5 py-1 bg-brand-500/90 backdrop-blur-sm text-white text-xs font-medium rounded-full"><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                </div>
            </div>
            <div class="p-4 flex-1 flex flex-col">
                <h3 class="text-sm font-medium text-ink-primary line-clamp-2 group-hover:text-brand-600 transition-colors"><%= p.getTitle() %></h3>
                <div class="mt-2">
                    <span class="price-tag text-xl font-bold text-red-600 bg-red-50 px-2 py-0.5 rounded">¥<%= p.getPrice() %></span>
                </div>
                <div class="flex items-center gap-3 mt-2 text-xs text-ink-muted">
                    <span><%= conditionText %></span>
                    <span class="w-1 h-1 bg-stone-300 rounded-full"></span>
                    <span><%= p.getSellerName() != null ? p.getSellerName() : "未知" %></span>
                </div>
            </div>
        </a>
    <% } %>
    </div>

    <!-- Pagination -->
    <% if (totalPages > 1) { %>
    <nav class="flex justify-center items-center gap-2 mt-10 flex-wrap">
        <a href="<%= request.getContextPath() %>/zone?type=<%= type %>&page=<%= currentPage - 1 %>">
            <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press <%= currentPage == 1 ? "opacity-35 pointer-events-none" : "" %>">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
            </span>
        </a>

        <% int startP = Math.max(1, currentPage - 2);
           int endP   = Math.min(totalPages, currentPage + 2);
           if (startP > 1) { %>
            <a href="<%= request.getContextPath() %>/zone?type=<%= type %>&page=1">
                <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press">1</span>
            </a>
            <% if (startP > 2) { %><span class="text-ink-faint px-1">...</span><% } %>
        <% }
           for (int pp = startP; pp <= endP; pp++) { %>
            <a href="<%= request.getContextPath() %>/zone?type=<%= type %>&page=<%= pp %>">
                <span class="w-10 h-10 flex items-center justify-center rounded-xl font-semibold transition-all btn-press <%= pp == currentPage ? "bg-gradient-to-r from-brand-500 to-brand-600 text-white shadow-lg shadow-brand-500/20" : "border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %>"><%= pp %></span>
            </a>
        <% }
           if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span class="text-ink-faint px-1">...</span><% } %>
            <a href="<%= request.getContextPath() %>/zone?type=<%= type %>&page=<%= totalPages %>">
                <span class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press"><%= totalPages %></span>
            </a>
        <% } %>

        <a href="<%= request.getContextPath() %>/zone?type=<%= type %>&page=<%= currentPage + 1 %>">
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
            <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
            </svg>
        </div>
        <h3 class="text-lg font-display font-semibold text-ink-primary mb-2">
            <% if (isGraduation) { %>
                暂时没有毕业季商品
            <% } else { %>
                暂时没有教材商品
            <% } %>
        </h3>
        <p class="text-ink-muted text-sm">
            该专区还没有商品，快去发布吧
        </p>
        <a href="${pageContext.request.contextPath}/publish-product.jsp" class="inline-block mt-4 px-6 py-2.5 bg-gradient-to-r from-brand-500 to-brand-600 text-white text-sm font-medium rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/20">
            发布商品
        </a>
    </div>
    <% } %>

</main>

</body>
</html>
