<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Map<String, Object>> notifyList = (List<Map<String, Object>>) request.getAttribute("notifyList");
    if (notifyList == null) notifyList = new ArrayList<>();
    int unreadCount = request.getAttribute("unreadCount") != null ? ((Number) request.getAttribute("unreadCount")).intValue() : 0;
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>消息通知 - 民大二手交易平台</title>
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
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 12px 24px rgba(0,0,0,0.1); }
        .btn-press { transition: transform 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }

        /* 通知入场动画 */
        .notification-enter {
            animation: slideInRight 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(20px); }
            to { opacity: 1; transform: translateX(0); }
        }

        /* 未读指示器脉冲 */
        .unread-pulse {
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.7; transform: scale(1.1); }
        }

        /* 删除按钮滑入 */
        .notification-card:hover .delete-btn {
            opacity: 1;
            transform: translateX(0);
        }
        .delete-btn {
            opacity: 0;
            transform: translateX(10px);
            transition: all 0.2s ease;
        }

        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .notification-enter, .unread-pulse { animation: none; transition: none; }
            .hover-lift:hover { transform: none; }
            .btn-press:active { transform: none; }
            .delete-btn { opacity: 1; transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/20 to-stone-100">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="notifications"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-2xl mx-auto px-4 py-8">
    <!-- 标题区 -->
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="font-display text-3xl font-bold text-ink-primary">消息通知</h1>
            <p class="text-ink-muted mt-1">共 <span class="text-ink-primary font-medium"><%= notifyList.size() %></span> 条通知，<span class="text-brand-600 font-medium"><%= unreadCount %></span> 条未读</p>
        </div>
        <% if (unreadCount > 0) { %>
        <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
            <input type="hidden" name="action" value="readAll">
            <button type="submit" class="px-5 py-2.5 bg-gradient-to-r from-brand-500 to-brand-600 text-white text-sm font-medium rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/20 flex items-center gap-2">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
                全部标为已读
            </button>
        </form>
        <% } %>
    </div>

    <% if (errorMsg != null) { %>
    <div class="flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm mb-6">
        <svg class="w-5 h-5 text-red-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <span><%= errorMsg %></span>
    </div>
    <% } %>

    <% if (notifyList.isEmpty()) { %>
    <!-- 空状态 -->
    <div class="bg-surface-raised border border-stone-200 rounded-2xl p-12 text-center">
        <div class="w-16 h-16 bg-stone-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
        </div>
        <p class="text-ink-muted text-sm">暂无通知</p>
    </div>
    <% } else { %>
    <!-- 通知列表 -->
    <div class="space-y-3">
        <% int animDelay = 0;
           for (Map<String, Object> n : notifyList) {
               boolean isRead = n.get("isRead") instanceof Boolean ? (Boolean) n.get("isRead") : false;
               Object notifyId = n.get("notificationId");
               String content = n.get("content") != null ? n.get("content").toString() : "";
               String createdAt = n.get("createdAt") != null ? n.get("createdAt").toString() : "";
               String borderColor = isRead ? "" : "border-l-brand-500";
               String bgColor = isRead ? "opacity-70" : "";
               String badgeBg = isRead ? "bg-stone-100" : "bg-brand-100";
               String badgeText = isRead ? "text-ink-muted" : "text-brand-700";
               String iconGradient = isRead ? "bg-stone-100" : "bg-gradient-to-br from-brand-400 to-brand-600";
               String iconColor = isRead ? "text-ink-muted" : "text-white";
               String dotVisible = isRead ? "hidden" : "";
               String readBtnVisible = isRead ? "hidden" : "";
        %>
        <div class="notification-card notification-enter bg-surface-raised border <%= isRead ? "" : "border-l-4 border-l-brand-500" %> border-stone-200 rounded-2xl p-5 hover-lift relative overflow-hidden group <%= isRead ? "opacity-70" : "" %>" style="animation-delay: <%= 0.05 * animDelay %>s">
            <!-- 背景装饰 -->
            <% if (!isRead) { %>
            <div class="absolute right-0 top-0 w-24 h-24 bg-brand-50 rounded-full -translate-y-1/2 translate-x-1/2 group-hover:scale-150 transition-transform duration-500"></div>
            <% } %>

            <div class="flex gap-4 relative z-10">
                <div class="flex-shrink-0">
                    <div class="w-10 h-10 <%= iconGradient %> rounded-xl flex items-center justify-center <%= isRead ? "" : "shadow-lg shadow-brand-500/20" %>">
                        <svg class="w-5 h-5 <%= iconColor %>" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <% if (isRead) { %>
                            <polyline points="20 6 9 17 4 12"/>
                            <% } else { %>
                            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                            <% } %>
                        </svg>
                    </div>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="px-2 py-0.5 <%= badgeBg %> <%= badgeText %> text-xs font-medium rounded-full">通知</span>
                        <% if (!isRead) { %>
                        <div class="w-2 h-2 bg-brand-500 rounded-full unread-pulse"></div>
                        <% } %>
                    </div>
                    <p class="text-sm <%= isRead ? "text-ink-secondary" : "text-ink-primary" %> leading-relaxed">
                        <%= content %>
                    </p>
                    <p class="text-xs text-ink-faint mt-2 flex items-center gap-1">
                        <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/>
                            <polyline points="12 6 12 12 16 14"/>
                        </svg>
                        <%= createdAt %>
                    </p>
                </div>
                <div class="flex gap-2 flex-shrink-0">
                    <% if (!isRead) { %>
                    <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="read">
                        <input type="hidden" name="notifyId" value="<%= notifyId %>">
                        <button type="submit" class="px-3 py-1.5 bg-stone-100 text-ink-muted text-xs font-medium rounded-lg hover:bg-stone-200 transition-colors btn-press">已读</button>
                    </form>
                    <% } %>
                    <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;" onsubmit="return confirm('确定删除这条通知吗？');" class="<%= isRead ? "" : "delete-btn" %>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="notifyId" value="<%= notifyId %>">
                        <button type="submit" class="px-3 py-1.5 bg-red-50 text-red-600 text-xs font-medium rounded-lg hover:bg-red-100 transition-colors btn-press">删除</button>
                    </form>
                </div>
            </div>
        </div>
        <% animDelay++; } %>
    </div>

    <!-- 清空按钮 -->
    <div class="text-center mt-8">
        <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;display:inline;" onsubmit="return confirm('确定清空所有已读通知吗？');">
            <input type="hidden" name="action" value="deleteRead">
            <button type="submit" class="px-6 py-3 bg-transparent border-2 border-stone-200 text-ink-muted text-sm font-medium rounded-xl hover:border-stone-300 hover:text-ink-primary transition-all btn-press flex items-center gap-2 mx-auto">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="3 6 5 6 21 6"/>
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                </svg>
                清空所有已读通知
            </button>
        </form>
    </div>
    <% } %>
</main>

</body>
</html>
