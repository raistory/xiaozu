<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="java.util.*" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Map<String, Object>> conversations = (List<Map<String, Object>>) request.getAttribute("conversations");
    if (conversations == null) conversations = new ArrayList<>();
    String successMsg = (String) request.getAttribute("successMsg");
    if (successMsg == null) successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>私信 - 民大二手交易平台</title>
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
    <jsp:param name="active" value="messages"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-2xl mx-auto px-4 py-8">
    <div class="mb-6">
        <h1 class="font-display text-2xl font-bold text-ink-primary">私信</h1>
        <p class="text-sm text-ink-muted mt-1">与买家 / 卖家的沟通记录</p>
    </div>

    <!-- 提示消息 -->
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

    <!-- 对话列表 -->
    <% if (conversations.isEmpty()) { %>
    <div class="bg-surface-raised border border-stone-200 rounded-2xl p-16 text-center shadow-sm">
        <div class="w-16 h-16 mx-auto mb-4 bg-stone-100 rounded-full flex items-center justify-center">
            <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            </svg>
        </div>
        <p class="text-ink-muted text-sm mb-4">还没有私信，去浏览商品并联系卖家吧</p>
        <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 px-5 py-2.5 bg-brand-500 text-white font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>
            </svg>
            浏览商品
        </a>
    </div>
    <% } else { %>
    <div class="space-y-3">
        <%
            String[] avatarColors = {"bg-brand-500", "bg-accent", "bg-brand-600", "bg-stone-400", "bg-brand-400", "bg-blue-500", "bg-purple-500", "bg-pink-500"};
            int colorIdx = 0;
            for (Map<String, Object> conv : conversations) {
                int otherId   = ((Number) conv.get("otherId")).intValue();
                int unread    = ((Number) conv.get("unreadCount")).intValue();
                String otherNickname = (String) conv.get("otherNickname");
                String lastContent   = (String) conv.get("lastContent");
                Object lastTime      = conv.get("lastTime");
                String initial = (otherNickname != null && otherNickname.length() > 0)
                    ? String.valueOf(otherNickname.charAt(0)).toUpperCase() : "?";
                String timeStr = "";
                if (lastTime != null) {
                    String ts = lastTime.toString();
                    timeStr = ts.length() >= 16 ? ts.substring(5, 16) : ts;
                }
                String avatarColor = avatarColors[colorIdx % avatarColors.length];
                colorIdx++;
        %>
        <a href="${pageContext.request.contextPath}/messages?conversationId=<%= conv.get("conversationId") %>" class="bg-surface-raised border border-stone-200 rounded-xl p-4 flex items-center gap-4 hover-lift hover:border-brand-200 transition-colors">
            <div class="w-12 h-12 <%= avatarColor %> rounded-full flex items-center justify-center text-white font-display font-bold text-lg flex-shrink-0"><%= initial %></div>
            <div class="flex-1 min-w-0">
                <div class="font-medium text-ink-primary"><%= otherNickname %></div>
                <p class="text-sm text-ink-muted truncate mt-1"><%= lastContent != null ? lastContent : "" %></p>
            </div>
            <div class="text-right flex-shrink-0">
                <div class="text-xs text-ink-faint<%= unread > 0 ? " mb-2" : "" %>"><%= timeStr %></div>
                <% if (unread > 0) { %>
                <span class="inline-flex items-center px-2 py-1 bg-red-500 text-white text-xs font-bold rounded-full min-w-[20px] justify-center"><%= unread > 99 ? "99+" : unread %></span>
                <% } %>
            </div>
        </a>
        <% } %>
    </div>
    <% } %>
</main>

</body>
</html>
