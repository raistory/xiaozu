<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Map<String, Object>> disputeList = (List<Map<String, Object>>) request.getAttribute("disputeList");
    if (disputeList == null) disputeList = new ArrayList<>();
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) { request.setAttribute("errorMsg", errorMsg); session.removeAttribute("errorMsg"); }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的纠纷 - 民大二手交易平台</title>
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
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="orders"/>
</jsp:include>

<main class="max-w-3xl mx-auto px-4 py-8">
    <a href="${pageContext.request.contextPath}/orders?type=buy" class="inline-flex items-center gap-1 text-sm text-ink-muted hover:text-brand-600 transition-colors mb-4">
        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        返回我的订单
    </a>
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6">我的纠纷</h1>

    <% if (successMsg != null) { %>
    <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= errorMsg %>
    </div>
    <% } %>

    <% if (disputeList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-green-400 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <p class="text-sm text-ink-muted mb-1">暂无纠纷记录</p>
        <p class="text-xs text-ink-faint">如有交易问题，可在订单页发起纠纷</p>
    </div>
    <% } else { %>
        <% for (Map<String, Object> d : disputeList) {
            String status = (String) d.get("status");
        %>
        <div class="bg-surface-raised border border-stone-200 rounded-xl p-5 mb-3">
            <div class="flex justify-between items-start gap-3 mb-3">
                <div class="text-sm font-bold text-ink-primary"><%= d.get("productTitle") != null ? d.get("productTitle") : "商品已删除" %></div>
                <% if ("PENDING".equals(status)) { %>
                    <span class="inline-block bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap">待处理</span>
                <% } else if ("REFUND".equals(status)) { %>
                    <span class="inline-block bg-green-50 text-green-700 border border-green-200 px-2.5 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap">已退款</span>
                <% } else { %>
                    <span class="inline-block bg-brand-50 text-brand-700 border border-brand-200 px-2.5 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap">已放行</span>
                <% } %>
            </div>
            <div class="flex flex-wrap gap-x-5 gap-y-1 text-xs text-ink-muted mb-3">
                <span>纠纷编号：<strong class="text-ink-primary font-semibold">#<%= d.get("disputeId") %></strong></span>
                <span>订单编号：<strong class="text-ink-primary font-semibold">#<%= d.get("orderId") %></strong></span>
                <span>提交时间：<strong class="text-ink-primary font-semibold"><%= d.get("createdAt") != null ? d.get("createdAt").toString().substring(0,16) : "-" %></strong></span>
                <% if (d.get("resolvedAt") != null) { %>
                <span>处理时间：<strong class="text-ink-primary font-semibold"><%= d.get("resolvedAt").toString().substring(0,16) %></strong></span>
                <% } %>
            </div>
            <div class="bg-amber-50 border-l-4 border-amber-400 rounded-r-lg p-3 text-sm text-ink-primary mb-2">纠纷原因：<%= d.get("reason") %></div>
            <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
            <div class="bg-brand-50 border-l-4 border-brand-500 rounded-r-lg p-3 text-sm text-brand-700">管理员备注：<%= d.get("adminNote") %></div>
            <% } %>
        </div>
        <% } %>
    <% } %>
</main>

</body>
</html>
