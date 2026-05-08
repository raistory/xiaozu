<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    List<Map<String, Object>> locations = (List<Map<String, Object>>) request.getAttribute("locationList");
    if (locations == null) locations = new ArrayList<>();
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园自提点 - 民大二手交易平台</title>
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
        .hover-lift { transition: transform 0.18s ease, box-shadow 0.18s ease; }
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(0,0,0,0.09); }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="pickup"/>
</jsp:include>

<main class="max-w-4xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-1">
        <svg class="w-5 h-5 inline-block text-brand-500 -mt-0.5 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
        校园自提点位
    </h1>
    <p class="text-sm text-ink-muted mb-7">以下是西南民族大学校内推荐的自提交易地点，方便买卖双方线下安全交易</p>

    <% if (errorMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-5 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= errorMsg %>
    </div>
    <% } %>

    <% if (locations.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
        <p class="text-sm text-ink-muted">暂无自提点信息</p>
    </div>
    <% } else { %>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <% for (Map<String, Object> loc : locations) { %>
        <div class="bg-surface-raised border-l-4 border-brand-500 rounded-xl p-5 hover-lift">
            <svg class="w-6 h-6 text-brand-500 mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            <div class="text-base font-bold text-brand-600 mb-2"><%= loc.get("name") %></div>
            <% if (loc.get("campusArea") != null && !((String) loc.get("campusArea")).isEmpty()) { %>
            <div class="inline-block px-2 py-0.5 bg-brand-50 text-brand-700 text-xs rounded-full mb-2"><%= loc.get("campusArea") %></div>
            <% } %>
            <div class="flex items-start gap-1.5 text-sm text-ink-primary mb-1.5">
                <svg class="w-3.5 h-3.5 flex-shrink-0 mt-0.5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <%= loc.get("address") %>
            </div>
            <% if (loc.get("phone") != null && !((String) loc.get("phone")).isEmpty()) { %>
            <div class="flex items-center gap-1.5 text-sm text-ink-secondary mb-1.5">
                <svg class="w-3.5 h-3.5 flex-shrink-0 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                <%= loc.get("phone") %>
            </div>
            <% } %>
            <% if (loc.get("openTime") != null && !((String) loc.get("openTime")).isEmpty()) { %>
            <div class="flex items-center gap-1.5 text-sm text-ink-secondary mb-1.5">
                <svg class="w-3.5 h-3.5 flex-shrink-0 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                <%= loc.get("openTime") %>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
    <% } %>

    <div class="mt-7 bg-amber-50 border border-amber-200 rounded-xl p-5 text-sm text-amber-800 leading-relaxed">
        <strong class="text-amber-700">
            <svg class="w-4 h-4 inline-block -mt-0.5 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18h6"/><path d="M10 22h4"/><path d="M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14"/></svg>
            安全交易小贴士：
        </strong>
        建议选择校内人流量大的公共区域进行面交，尽量避开偏僻地点。交易前确认商品状况，当面清点金额。如遇到问题可联系平台客服。
    </div>
</main>

</body>
</html>
