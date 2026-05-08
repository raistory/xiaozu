<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.minzu.entity.User" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<User> userList = (List<User>) request.getAttribute("userList");
    if (userList == null) userList = new ArrayList<>();
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    int totalCount = request.getAttribute("totalCount") != null ? (int) request.getAttribute("totalCount") : 0;
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg"); session.removeAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理 - 民大二手交易平台</title>
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
    <jsp:param name="active" value="users"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-5xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6 flex items-center gap-2">
        <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        用户管理
        <span class="text-sm font-normal text-ink-muted ml-2">共 <%= totalCount %> 位用户</span>
    </h1>

    <% if (errMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= errMsg %>
    </div>
    <% } %>
    <% if (sucMsg != null) { %>
    <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <%= sucMsg %>
    </div>
    <% } %>

    <form method="get" action="${pageContext.request.contextPath}/admin/users" class="mb-5 flex gap-2 flex-wrap">
        <input type="text" name="keyword" value="<%= keyword %>" placeholder="搜索学号、姓名或昵称..."
            class="flex-1 min-w-[200px] px-4 py-2.5 bg-surface-raised border border-stone-200 rounded-lg text-sm text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
        <select name="status" class="px-4 py-2.5 bg-surface-raised border border-stone-200 rounded-lg text-sm text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
            <option value="">全部状态</option>
            <option value="ACTIVE" <%= "ACTIVE".equals(statusFilter) ? "selected" : "" %>>活跃</option>
            <option value="DISABLED" <%= "DISABLED".equals(statusFilter) ? "selected" : "" %>>已禁用</option>
        </select>
        <button type="submit" class="px-5 py-2.5 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">筛选</button>
        <% if (!keyword.isEmpty() || !statusFilter.isEmpty()) { %>
        <a href="${pageContext.request.contextPath}/admin/users" class="px-4 py-2.5 border border-stone-200 text-ink-muted text-sm font-medium rounded-lg hover:bg-stone-100 transition-colors">清除</a>
        <% } %>
    </form>

    <% if (userList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        <p class="text-sm text-ink-muted"><%= keyword.isEmpty() && statusFilter.isEmpty() ? "暂无用户" : "未找到匹配用户" %></p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full divide-y divide-stone-200">
                <thead>
                    <tr class="bg-stone-50">
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">学号/工号</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">姓名</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">昵称</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">状态</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">注册时间</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">操作</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-stone-100">
                <% for (User u : userList) { %>
                <tr class="hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-ink-primary"><%= u.getUserId() %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary font-medium"><%= u.getStudentOrStaffNo() %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary"><%= u.getRealName() %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= u.getNickname() != null ? u.getNickname() : "-" %></td>
                    <td class="px-4 py-3">
                        <% if ("ACTIVE".equals(u.getAccountStatus())) { %>
                        <span class="inline-block bg-green-50 text-green-700 border border-green-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">活跃</span>
                        <% } else if ("DISABLED".equals(u.getAccountStatus())) { %>
                        <span class="inline-block bg-red-50 text-red-600 border border-red-200 px-2.5 py-0.5 rounded-full text-xs font-semibold">已禁用</span>
                        <% } else { %>
                        <span class="inline-block bg-stone-100 text-stone-500 border border-stone-200 px-2.5 py-0.5 rounded-full text-xs font-semibold"><%= u.getAccountStatus() %></span>
                        <% } %>
                    </td>
                    <td class="px-4 py-3 text-xs text-ink-muted whitespace-nowrap">—</td>
                    <td class="px-4 py-3 whitespace-nowrap">
                        <% if ("ACTIVE".equals(u.getAccountStatus())) { %>
                        <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline">
                            <input type="hidden" name="action" value="disable">
                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                            <input type="hidden" name="keyword" value="<%= keyword %>">
                            <input type="hidden" name="status" value="<%= statusFilter %>">
                            <button class="bg-red-50 text-red-600 border border-red-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors btn-press" onclick="return confirm('确定禁用该用户？')">禁用</button>
                        </form>
                        <% } else if ("DISABLED".equals(u.getAccountStatus())) { %>
                        <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline">
                            <input type="hidden" name="action" value="enable">
                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                            <input type="hidden" name="keyword" value="<%= keyword %>">
                            <input type="hidden" name="status" value="<%= statusFilter %>">
                            <button class="bg-brand-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-brand-600 transition-colors btn-press">启用</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <% if (totalPages > 1) { %>
    <div class="flex justify-center items-center gap-2 mt-6">
        <% if (currentPage > 1) { %>
        <a href="?page=<%= currentPage - 1 %>&keyword=<%= keyword %>&status=<%= statusFilter %>" class="px-3 py-2 text-sm border border-stone-200 rounded-lg hover:bg-stone-100 transition-colors">上一页</a>
        <% } %>
        <span class="text-sm text-ink-muted px-3">第 <%= currentPage %> / <%= totalPages %> 页</span>
        <% if (currentPage < totalPages) { %>
        <a href="?page=<%= currentPage + 1 %>&keyword=<%= keyword %>&status=<%= statusFilter %>" class="px-3 py-2 text-sm border border-stone-200 rounded-lg hover:bg-stone-100 transition-colors">下一页</a>
        <% } %>
    </div>
    <% } %>
    <% } %>
</main>
</body>
</html>
