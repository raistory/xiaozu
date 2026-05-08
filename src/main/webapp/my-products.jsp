<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%!
    private String statusText(String status) {
        if ("ON_SALE".equals(status))        return "在售";
        if ("OFF_SHELF".equals(status))      return "已下架";
        if ("SOLD".equals(status))           return "已售出";
        if ("PENDING_REVIEW".equals(status)) return "待审核";
        if ("REJECTED".equals(status))       return "已驳回";
        return status == null ? "-" : status;
    }
%>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的商品 - 民大二手交易平台</title>
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
        .hover-lift:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.15); }
        .btn-press { transition: transform 0.1s ease; }
        .btn-press:active { transform: scale(0.97); }
        .img-zoom { transition: transform 0.4s ease; }
        .img-zoom:hover { transform: scale(1.08); }

        /* 状态卡片渐变 */
        .stat-gradient {
            background: linear-gradient(135deg, var(--tw-gradient-stops));
        }

        /* 玻璃态效果 */
        .glass {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(12px);
        }

        .product-enter {
            animation: productIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes productIn {
            from { opacity: 0; transform: translateY(30px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .img-zoom, .product-enter { animation: none; transition: none; }
            .hover-lift:hover, .img-zoom:hover { transform: none; }
            .btn-press:active { transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/30 to-stone-50">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="my-products"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-5xl mx-auto px-4 py-8">
    <!-- 标题区 -->
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="font-display text-3xl font-bold text-ink-primary">我的商品</h1>
            <p class="text-sm text-ink-muted mt-1">管理你发布的所有商品</p>
        </div>
        <a href="${pageContext.request.contextPath}/publish-product" class="inline-flex items-center gap-2 px-5 py-3 bg-gradient-to-r from-brand-500 to-brand-600 text-white font-display font-semibold rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/30">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="5" x2="12" y2="19"/>
                <line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            发布新商品
        </a>
    </div>

    <!-- 成功/错误消息 -->
    <% if (successMsg != null) { %>
    <div class="mb-6 bg-brand-50 border border-brand-200 rounded-lg px-4 py-3 flex items-center gap-3">
        <svg class="w-5 h-5 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        <span class="text-brand-700 text-sm"><%= successMsg %></span>
    </div>
    <% } %>
    <% if (sessionErrorMsg != null) { %>
    <div class="mb-6 bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
        <svg class="w-5 h-5 text-red-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
        </svg>
        <span class="text-red-700 text-sm"><%= sessionErrorMsg %></span>
    </div>
    <% } else if (request.getAttribute("errorMsg") != null) { %>
    <div class="mb-6 bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
        <svg class="w-5 h-5 text-red-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
        </svg>
        <span class="text-red-700 text-sm"><%= request.getAttribute("errorMsg") %></span>
    </div>
    <% } %>

    <!-- 状态筛选 -->
    <div class="flex flex-wrap gap-2 mb-6">
        <a href="${pageContext.request.contextPath}/my-products" class="px-4 py-2 <%= "".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %> font-medium rounded-full text-sm transition-colors btn-press">全部</a>
        <a href="${pageContext.request.contextPath}/my-products?status=ON_SALE" class="px-4 py-2 <%= "ON_SALE".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %> font-medium rounded-full text-sm transition-colors">在售</a>
        <a href="${pageContext.request.contextPath}/my-products?status=OFF_SHELF" class="px-4 py-2 <%= "OFF_SHELF".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %> font-medium rounded-full text-sm transition-colors">已下架</a>
        <a href="${pageContext.request.contextPath}/my-products?status=SOLD" class="px-4 py-2 <%= "SOLD".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %> font-medium rounded-full text-sm transition-colors">已售出</a>
        <a href="${pageContext.request.contextPath}/my-products?status=PENDING_REVIEW" class="px-4 py-2 <%= "PENDING_REVIEW".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600" %> font-medium rounded-full text-sm transition-colors">待审核</a>
        <a href="${pageContext.request.contextPath}/my-products?status=REJECTED" class="px-4 py-2 <%= "REJECTED".equals(statusFilter) ? "bg-brand-500 text-white shadow-md shadow-brand-500/20" : "bg-surface-raised border border-stone-200 text-ink-muted hover:border-red-300 hover:text-red-600" %> font-medium rounded-full text-sm transition-colors">已驳回</a>
    </div>

    <!-- 空状态 -->
    <% if (productList == null || productList.isEmpty()) { %>
    <div class="text-center py-24 bg-surface-raised border border-stone-200 rounded-2xl shadow-lg">
        <div class="w-20 h-20 mx-auto bg-stone-100 rounded-full flex items-center justify-center mb-4">
            <svg class="w-10 h-10 text-ink-faint" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
        </div>
        <p class="text-ink-muted text-sm mb-6">你还没有发布任何商品</p>
        <a href="${pageContext.request.contextPath}/publish-product" class="px-6 py-3 bg-brand-500 hover:bg-brand-600 text-white font-display font-semibold rounded-xl btn-press transition-colors shadow-lg shadow-brand-500/25">
            立即发布
        </a>
    </div>
    <% } else { %>

    <!-- 商品网格 -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <% for (Product p : productList) { %>
        <%
            String pStatus = p.getProductStatus();
            String statusTextVal = statusText(pStatus);
            // status badge colors
            String badgeBg = "";
            String badgeText = "";
            if ("ON_SALE".equals(pStatus))        { badgeBg = "bg-brand-500"; badgeText = "text-white"; }
            else if ("OFF_SHELF".equals(pStatus))   { badgeBg = "bg-stone-500"; badgeText = "text-white"; }
            else if ("SOLD".equals(pStatus))        { badgeBg = "bg-yellow-500"; badgeText = "text-white"; }
            else if ("PENDING_REVIEW".equals(pStatus)) { badgeBg = "bg-amber-500"; badgeText = "text-white"; }
            else if ("REJECTED".equals(pStatus))    { badgeBg = "bg-red-500"; badgeText = "text-white"; }
            boolean isSold = "SOLD".equals(pStatus);
            boolean isRejected = "REJECTED".equals(pStatus);
        %>
        <div class="bg-surface-raised rounded-2xl overflow-hidden shadow-lg hover-lift group <%= isSold ? "opacity-80" : "" %> <%= isRejected ? "border-2 border-red-200" : "" %> product-enter">
            <div class="relative overflow-hidden">
                <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" loading="lazy" class="w-full h-44 object-cover img-zoom <%= isSold ? "grayscale" : "" %>">
                <% } else { %>
                    <div class="w-full h-44 bg-stone-100 flex items-center justify-center">
                        <svg class="w-12 h-12 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                            <circle cx="8.5" cy="8.5" r="1.5"/>
                            <polyline points="21 15 16 10 5 21"/>
                        </svg>
                    </div>
                <% } %>

                <% if (isSold) { %>
                <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent"></div>
                <% } %>

                <!-- 状态角标 -->
                <div class="absolute top-3 left-3 px-3 py-1.5 <%= badgeBg %> <%= badgeText %> text-xs font-semibold rounded-full shadow-lg <%= "PENDING_REVIEW".equals(pStatus) ? "animate-pulse" : "" %>">
                    <%= statusTextVal %>
                </div>

                <% if (isSold) { %>
                <div class="absolute bottom-3 left-3 right-3 text-center">
                    <span class="text-white font-display font-bold text-lg">成交价 &yen;<%= p.getPrice() %></span>
                </div>
                <% } %>

                <!-- 浏览量 -->
                <div class="absolute bottom-3 right-3 px-2 py-1 glass rounded-lg text-xs text-ink-secondary">
                    <svg class="w-3 h-3 inline mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    <%= p.getViewCount() %>次
                </div>
            </div>
            <div class="p-4">
                <h3 class="font-medium text-ink-primary truncate mb-2"><%= p.getTitle() %></h3>
                <div class="flex items-baseline gap-2 mb-3">
                    <span class="font-display text-xl font-bold text-red-600">&yen;<%= p.getPrice() %></span>
                    <% if (p.getOriginalPrice() != null) { %>
                    <span class="text-xs text-ink-faint line-through">&yen;<%= p.getOriginalPrice() %></span>
                    <% } %>
                </div>
                <div class="flex items-center gap-2 text-xs text-ink-muted mb-4">
                    <span class="px-2 py-0.5 bg-stone-100 rounded"><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                    <span>收藏 <%= p.getFavoriteCount() %></span>
                    <span><%= p.getCreatedAt() != null ? p.getCreatedAt().toString().substring(0,10) : "" %></span>
                </div>
                <div class="flex gap-2 pt-3 border-t border-stone-100">
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="flex-1 py-2 bg-stone-100 text-ink-muted text-xs font-medium rounded-lg text-center hover:bg-stone-200 transition-colors">查看详情</a>
                    <% if (!"SOLD".equals(pStatus)) { %>
                    <a href="${pageContext.request.contextPath}/edit-product?id=<%= p.getProductId() %>" class="flex-1 py-2 bg-brand-50 text-brand-600 text-xs font-medium rounded-lg text-center hover:bg-brand-100 transition-colors">编辑</a>
                    <% } %>
                    <% if ("ON_SALE".equals(pStatus)) { %>
                    <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                        <input type="hidden" name="action" value="offshelf">
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                        <button type="submit" class="px-3 py-2 bg-orange-50 text-orange-600 text-xs font-medium rounded-lg hover:bg-orange-100 transition-colors" onclick="return confirm('确定下架该商品吗？');">下架</button>
                    </form>
                    <% } else if ("OFF_SHELF".equals(pStatus)) { %>
                    <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                        <input type="hidden" name="action" value="onshelf">
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                        <button type="submit" class="px-3 py-2 bg-brand-500 text-white text-xs font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press" onclick="return confirm('确定重新上架该商品吗？');">重新上架</button>
                    </form>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</main>

</body>
</html>
