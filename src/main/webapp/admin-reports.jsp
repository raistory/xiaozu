<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    List<Map<String, Object>> reportList = (List<Map<String, Object>>) request.getAttribute("reportList");
    if (reportList == null) reportList = new ArrayList<>();
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
    <title>举报管理 - 民大二手交易平台</title>
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
        .btn-press { transition: transform 0.15s ease, box-shadow 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="reports"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-6xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6 flex items-center gap-2">
        <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
        举报管理
    </h1>

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

    <% if (reportList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polyline points="22 12 16 12 14 15 10 15 8 12 2 12"/><path d="M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"/></svg>
        <p class="text-sm text-ink-muted">暂无举报记录</p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full divide-y divide-stone-200">
                <thead>
                    <tr class="bg-stone-50">
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">举报ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">举报人</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">商品</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">商品状态</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">举报原因</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">状态</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">举报时间</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">处理时间</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">操作</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-stone-100">
                <%
                for (Map<String, Object> r : reportList) {
                    String st = (String) r.get("status");
                    String ps = (String) r.get("publishStatus");
                %>
                <tr class="hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-ink-primary font-medium">#<%= r.get("reportId") %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= r.get("reporterName") != null ? r.get("reporterName") : "未知" %></td>
                    <td class="px-4 py-3">
                        <a href="${pageContext.request.contextPath}/product-detail?id=<%= r.get("productId") %>" target="_blank" class="text-sm text-brand-600 hover:underline font-medium">
                            <%= r.get("productTitle") != null ? r.get("productTitle") : "商品已删除" %>
                        </a>
                    </td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= ps != null ? ps : "-" %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary">
                        <%= r.get("reason") != null ? r.get("reason") : "-" %>
                        <% if (r.get("reportDetail") != null && !r.get("reportDetail").toString().isEmpty()) { %>
                        <br><small class="text-ink-muted"><%= r.get("reportDetail") %></small>
                        <% } %>
                    </td>
                    <td class="px-4 py-3">
                        <% if ("PENDING".equals(st)) { %><span class="inline-block bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">待处理</span>
                        <% } else if ("APPROVED".equals(st)) { %><span class="inline-block bg-slate-100 text-slate-600 border border-slate-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已下架</span>
                        <% } else if ("REJECTED".equals(st)) { %><span class="inline-block bg-green-50 text-green-700 border border-green-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已驳回</span>
                        <% } else { %><span class="inline-block bg-stone-100 text-stone-500 border border-stone-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已关闭</span><% } %>
                    </td>
                    <td class="px-4 py-3 text-xs text-ink-muted whitespace-nowrap"><%= r.get("createdAt") != null ? r.get("createdAt").toString().substring(0,16) : "-" %></td>
                    <td class="px-4 py-3 text-xs text-ink-muted whitespace-nowrap"><%= r.get("handledAt") != null ? r.get("handledAt").toString().substring(0,16) : "-" %></td>
                    <td class="px-4 py-3 whitespace-nowrap">
                        <% if ("PENDING".equals(st)) { %>
                            <% if (!"OFF_SHELF".equals(ps) && !"SOLD".equals(ps)) { %>
                            <form action="${pageContext.request.contextPath}/report" method="post" style="display:inline" onsubmit="return confirm('确定下架该商品？');">
                                <input type="hidden" name="action" value="takedown">
                                <input type="hidden" name="productId" value="<%= r.get("productId") %>">
                                <input type="hidden" name="reportId" value="<%= r.get("reportId") %>">
                                <button class="bg-red-50 text-red-600 border border-red-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors btn-press">下架</button>
                            </form>
                            <% } %>
                            <form action="${pageContext.request.contextPath}/report" method="post" style="display:inline;margin-left:6px" onsubmit="return confirm('确定驳回该举报？');">
                                <input type="hidden" name="action" value="dismiss">
                                <input type="hidden" name="reportId" value="<%= r.get("reportId") %>">
                                <button class="bg-stone-100 text-ink-muted border border-stone-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-stone-200 transition-colors btn-press">驳回</button>
                            </form>
                        <% } else if ("OFF_SHELF".equals(ps) || "APPROVED".equals(st)) { %>
                            <span class="text-xs text-ink-muted">已下架</span>
                        <% } else { %>
                            <span class="text-xs text-ink-muted">—</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</main>
</body>
</html>
