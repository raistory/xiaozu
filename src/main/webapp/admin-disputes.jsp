<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
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
    <title>纠纷管理 - 民大二手交易平台</title>
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
        .input-focus-ring:focus { outline: none; box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.15); }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="disputes"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-6xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6 flex items-center gap-2">
        <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="3" x2="12" y2="21"/><polyline points="17 8 12 3 7 8"/><path d="M3 14h4l3 8h4l3-8h4"/></svg>
        订单纠纷管理
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

    <% if (disputeList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-green-400 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <p class="text-sm text-ink-muted">暂无待处理纠纷</p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full divide-y divide-stone-200">
                <thead>
                    <tr class="bg-stone-50">
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">纠纷ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">订单ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">商品</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">买家</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">卖家</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">纠纷原因</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">状态</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">提交时间</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">操作</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-stone-100">
                <% for (Map<String, Object> d : disputeList) { String status = (String) d.get("status"); %>
                <tr class="hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-ink-primary font-medium">#<%= d.get("disputeId") %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted">#<%= d.get("orderId") %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary"><%= d.get("productTitle") != null ? d.get("productTitle") : "-" %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= d.get("buyerName") != null ? d.get("buyerName") : "-" %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= d.get("sellerName") != null ? d.get("sellerName") : "-" %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary" style="max-width:200px;">
                        <%= d.get("reason") %>
                        <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
                        <br><small class="text-ink-muted">备注：<%= d.get("adminNote") %></small>
                        <% } %>
                    </td>
                    <td class="px-4 py-3">
                        <% if ("PENDING".equals(status)) { %><span class="inline-block bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">待处理</span>
                        <% } else if ("REFUND".equals(status)) { %><span class="inline-block bg-green-50 text-green-700 border border-green-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已退款</span>
                        <% } else { %><span class="inline-block bg-brand-50 text-brand-700 border border-brand-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已放行</span><% } %>
                    </td>
                    <td class="px-4 py-3 text-xs text-ink-muted whitespace-nowrap"><%= d.get("createdAt") != null ? d.get("createdAt").toString().substring(0,16) : "-" %></td>
                    <td class="px-4 py-3">
                        <% if ("PENDING".equals(status)) { %>
                        <form action="${pageContext.request.contextPath}/dispute" method="post" style="margin:0">
                            <input type="hidden" name="action" value="resolve">
                            <input type="hidden" name="disputeId" value="<%= d.get("disputeId") %>">
                            <div class="flex items-center gap-2 flex-wrap">
                                <input type="text" name="adminNote" placeholder="备注（选填）"
                                    class="border border-stone-200 rounded-lg px-3 py-1.5 text-xs w-40 input-focus-ring font-body">
                                <button type="submit" name="result" value="REFUND" class="bg-green-50 text-green-700 border border-green-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors btn-press" onclick="return confirm('确定裁决退款？')">退款</button>
                                <button type="submit" name="result" value="RELEASE" class="bg-brand-50 text-brand-700 border border-brand-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-brand-100 transition-colors btn-press" onclick="return confirm('确定放行？')">放行</button>
                            </div>
                        </form>
                        <% } else { %><span class="text-xs text-ink-muted">已处理</span><% } %>
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
