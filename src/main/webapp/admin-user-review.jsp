<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.User" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
    List<User> userList = (List<User>) request.getAttribute("userList");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户审核 - 民大二手交易平台</title>
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
    <jsp:param name="active" value="user-review"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-5xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-1 flex items-center gap-2">
        <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        用户审核
    </h1>
    <p class="text-sm text-ink-muted mb-6">管理员可对新注册用户进行审核，通过后用户即可正常登录系统。</p>

    <% if (successMsg != null) { %>
    <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <%= successMsg %>
    </div>
    <% } %>
    <% if (sessionErrorMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= sessionErrorMsg %>
    </div>
    <% } else if (request.getAttribute("errorMsg") != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= request.getAttribute("errorMsg") %>
    </div>
    <% } %>

    <% if (userList == null || userList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-green-400 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <p class="text-sm text-ink-muted">当前没有待审核用户。</p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full divide-y divide-stone-200">
                <thead>
                    <tr class="bg-stone-50">
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">用户ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">学号/工号</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">真实姓名</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">昵称</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">角色</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">状态</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">操作</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-stone-100">
                <% for (User u : userList) { %>
                <tr class="hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-ink-primary"><%= u.getUserId() %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary"><%= u.getStudentOrStaffNo() %></td>
                    <td class="px-4 py-3 text-sm text-ink-primary font-medium"><%= u.getRealName() %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= u.getNickname() == null ? "-" : u.getNickname() %></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%= u.getRoleCode() %></td>
                    <td class="px-4 py-3"><span class="inline-block bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-0.5 rounded-full text-xs font-semibold"><%= u.getAccountStatus() %></span></td>
                    <td class="px-4 py-3 whitespace-nowrap">
                        <a class="bg-brand-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-brand-600 transition-colors btn-press inline-block"
                           href="${pageContext.request.contextPath}/admin/approve-user?userId=<%= u.getUserId() %>"
                           onclick="return confirm('确定审核通过该用户吗？')">通过</a>
                        <a class="bg-red-50 text-red-600 border border-red-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors btn-press inline-block ml-1.5"
                           href="${pageContext.request.contextPath}/admin/reject-user?userId=<%= u.getUserId() %>"
                           onclick="return confirm('确定将该用户设为禁用吗？')">禁用</a>
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
