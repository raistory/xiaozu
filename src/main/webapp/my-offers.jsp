<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    List<Map<String, Object>> offerList = (List<Map<String, Object>>) request.getAttribute("offerList");
    if (offerList == null) offerList = new ArrayList<>();
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "received";
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的出价 - 民大二手交易平台</title>
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
        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press { transition: none; }
            .hover-lift:hover { transform: none; }
            .btn-press:active { transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value=""/>
</jsp:include>

<main class="max-w-4xl mx-auto px-4 py-8">
    <h1 class="font-display text-2xl font-bold text-ink-primary mb-6">我的出价</h1>

    <div class="flex gap-3 mb-6">
        <a href="${pageContext.request.contextPath}/offer?tab=received" class="flex items-center gap-2 px-5 py-2.5 <% if("received".equals(tab)){out.print("bg-brand-500 text-white");}else{out.print("bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600");}%> font-medium rounded-full transition-colors btn-press">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
            收到的出价
        </a>
        <a href="${pageContext.request.contextPath}/offer?tab=sent" class="flex items-center gap-2 px-5 py-2.5 <% if("sent".equals(tab)){out.print("bg-brand-500 text-white");}else{out.print("bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600");}%> font-medium rounded-full transition-colors btn-press">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/>
            </svg>
            发出的出价
        </a>
    </div>

    <% if (successMsg != null) { %>
        <div class="bg-brand-50 border border-brand-200 rounded-lg px-4 py-3 mb-4 flex items-center gap-3" role="alert">
            <svg class="w-5 h-5 text-brand-600 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
            </svg>
            <span class="text-brand-700 text-sm"><%= successMsg %></span>
        </div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="bg-red-50 border border-red-200 rounded-lg px-4 py-3 mb-4 flex items-center gap-3" role="alert">
            <svg class="w-5 h-5 text-red-600 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
            </svg>
            <span class="text-red-700 text-sm"><%= errorMsg %></span>
        </div>
    <% } %>

    <% if (offerList.isEmpty()) { %>
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-16 text-center shadow-sm">
            <div class="w-16 h-16 mx-auto mb-4 bg-stone-100 rounded-full flex items-center justify-center">
                <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                </svg>
            </div>
            <p class="text-ink-muted text-sm font-medium mb-1">
                <% if ("sent".equals(tab)) { %>
                    暂无发出的出价
                <% } else { %>
                    暂无收到的出价
                <% } %>
            </p>
            <p class="text-ink-muted text-xs mb-4">
                <% if ("sent".equals(tab)) { %>
                    你还没有对任何商品出价，去浏览商品吧。
                <% } else { %>
                    还没有买家对你的商品出价。
                <% } %>
            </p>
            <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 px-5 py-2.5 bg-brand-500 text-white font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
                去浏览商品
            </a>
        </div>
    <% } else { %>
        <div class="space-y-4">
            <% for (Map<String, Object> o : offerList) {
                String status = (String) o.get("status");
                String sText, badgeBg, badgeText;
                if ("PENDING".equals(status)) {
                    sText = "待处理"; badgeBg = "bg-amber-100"; badgeText = "text-amber-700";
                } else if ("ACCEPTED".equals(status)) {
                    sText = "已接受"; badgeBg = "bg-brand-100"; badgeText = "text-brand-700";
                } else if ("REJECTED".equals(status)) {
                    sText = "已拒绝"; badgeBg = "bg-red-100"; badgeText = "text-red-700";
                } else {
                    sText = status; badgeBg = "bg-stone-100"; badgeText = "text-stone-600";
                }
                BigDecimal offerPrice = (BigDecimal) o.get("offerPrice");
            %>
            <div class="bg-surface-raised border border-stone-200 rounded-xl p-5 hover-lift">
                <div class="flex gap-4 items-start">
                    <% String coverUrl = (String) o.get("coverImageUrl"); %>
                    <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
                        <a href="${pageContext.request.contextPath}/product-detail?id=<%= o.get("productId") %>">
                            <img src="<%= coverUrl %>" alt="商品图" class="w-24 h-24 object-cover rounded-lg bg-stone-100 flex-shrink-0" loading="lazy">
                        </a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/product-detail?id=<%= o.get("productId") %>">
                            <div class="w-24 h-24 rounded-lg bg-stone-100 flex-shrink-0 flex flex-col items-center justify-center gap-1 text-ink-faint">
                                <svg class="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                <span class="text-xs">暂无图片</span>
                            </div>
                        </a>
                    <% } %>
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-2">
                            <span class="inline-flex items-center px-3 py-1 <%= badgeBg %> <%= badgeText %> text-xs font-semibold rounded-full"><%= sText %></span>
                        </div>
                        <h3 class="font-medium text-ink-primary truncate">
                            <a href="${pageContext.request.contextPath}/product-detail?id=<%= o.get("productId") %>" class="hover:text-brand-600 transition-colors">
                                <%= o.get("productTitle") != null ? o.get("productTitle") : "商品已删除" %>
                            </a>
                        </h3>
                        <div class="mt-2 text-xs text-ink-muted space-y-1">
                            <p>
                                <% if ("received".equals(tab)) { %>
                                    买家：<strong class="text-ink-primary"><%= o.get("buyerName") %></strong>
                                <% } else { %>
                                    卖家：<strong class="text-ink-primary"><%= o.get("sellerName") %></strong>
                                <% } %>
                                &nbsp;|&nbsp;
                                出价时间：<%= o.get("createdAt") %>
                            </p>
                            <% if (o.get("message") != null) { %>
                                <p class="text-ink-faint">留言：<%= o.get("message") %></p>
                            <% } %>
                        </div>
                        <div class="mt-3 flex items-center gap-4">
                            <span class="text-2xl font-bold text-amber-700">&yen;<%= offerPrice != null ? offerPrice.toPlainString() : "0" %></span>
                        </div>
                        <% if ("received".equals(tab) && "PENDING".equals(status)) { %>
                        <div class="mt-4 flex gap-2 flex-wrap">
                            <form action="${pageContext.request.contextPath}/offer" method="post" style="margin:0;" onsubmit="return confirm('接受此出价将自动创建订单并拒绝其他出价，确认接受吗？');" class="inline-flex">
                                <input type="hidden" name="action" value="accept">
                                <input type="hidden" name="offerId" value="<%= o.get("offerId") %>">
                                <button type="submit" class="inline-flex items-center gap-1.5 px-4 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <polyline points="20 6 9 17 4 12"/>
                                    </svg>
                                    接受出价
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/offer" method="post" style="margin:0;" onsubmit="return confirm('确定拒绝此出价吗？');" class="inline-flex">
                                <input type="hidden" name="action" value="reject">
                                <input type="hidden" name="offerId" value="<%= o.get("offerId") %>">
                                <button type="submit" class="inline-flex items-center gap-1.5 px-4 py-2 bg-red-50 border border-red-200 text-red-600 text-sm font-medium rounded-lg hover:bg-red-100 transition-colors btn-press">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                                    </svg>
                                    拒绝出价
                                </button>
                            </form>
                        </div>
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
