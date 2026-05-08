<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.minzu.entity.User" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Map<String, Object>> pointList = (List<Map<String, Object>>) request.getAttribute("pointList");
    if (pointList == null) pointList = new ArrayList<>();
    String errMsg = (String) request.getAttribute("errorMsg");
    String sucMsg = (String) request.getAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>自提点管理 - 民大二手交易平台</title>
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
    <jsp:param name="active" value="admin"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-5xl mx-auto px-4 py-8">
    <div class="flex items-center justify-between mb-6">
        <h1 class="font-display text-xl font-bold text-ink-primary flex items-center gap-2">
            <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            自提点管理
            <span class="text-sm font-normal text-ink-muted ml-2">共 <%= pointList.size() %> 个自提点</span>
        </h1>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="text-sm text-ink-muted hover:text-brand-600 transition-colors">
            <svg class="w-4 h-4 inline-block mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
            返回管理后台
        </a>
    </div>

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

    <!-- 添加自提点表单 -->
    <div class="bg-surface-raised border border-stone-200 rounded-xl p-6 mb-6">
        <h2 class="font-display font-semibold text-lg text-ink-primary mb-4 flex items-center gap-2">
            <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            添加新自提点
        </h2>
        <form method="post" action="${pageContext.request.contextPath}/admin/pickup-points" class="space-y-4">
            <input type="hidden" name="action" value="add">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                        自提点名称 <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="pointName" required maxlength="100" placeholder="例如：北区宿舍门口"
                        class="w-full px-4 py-3 bg-surface border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div>
                    <label class="text-sm font-medium text-ink-primary mb-2 block">校区区域</label>
                    <input type="text" name="campusArea" maxlength="100" placeholder="例如：北校区"
                        class="w-full px-4 py-3 bg-surface border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div>
                    <label class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                        详细地址 <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="addressDetail" required maxlength="255" placeholder="例如：学生宿舍7号楼北侧小广场"
                        class="w-full px-4 py-3 bg-surface border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div>
                    <label class="text-sm font-medium text-ink-primary mb-2 block">联系电话</label>
                    <input type="text" name="contactPhone" maxlength="20" placeholder="例如：13800138000"
                        class="w-full px-4 py-3 bg-surface border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div class="md:col-span-2">
                    <label class="text-sm font-medium text-ink-primary mb-2 block">营业时间</label>
                    <input type="text" name="openTimeDesc" maxlength="100" placeholder="例如：周一至周五 9:00-18:00"
                        class="w-full px-4 py-3 bg-surface border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
            </div>
            <button type="submit" class="px-5 py-2.5 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
                添加自提点
            </button>
        </form>
    </div>

    <!-- 自提点列表 -->
    <% if (pointList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
        <p class="text-sm text-ink-muted">暂无自提点，请在上方添加</p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl overflow-hidden">
        <table class="w-full text-sm">
            <thead>
                <tr class="bg-stone-50 border-b border-stone-200">
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">ID</th>
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">名称</th>
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">校区</th>
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">地址</th>
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">电话</th>
                    <th class="text-left px-4 py-3 font-semibold text-ink-primary">营业时间</th>
                    <th class="text-center px-4 py-3 font-semibold text-ink-primary">状态</th>
                    <th class="text-center px-4 py-3 font-semibold text-ink-primary">操作</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> point : pointList) { %>
                <tr class="border-b border-stone-100 hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-ink-secondary"><%= point.get("id") %></td>
                    <td class="px-4 py-3 font-medium text-ink-primary"><%= point.get("name") %></td>
                    <td class="px-4 py-3 text-ink-secondary">
                        <% if (point.get("campusArea") != null && !((String) point.get("campusArea")).isEmpty()) { %>
                        <span class="inline-block px-2 py-0.5 bg-brand-50 text-brand-700 text-xs rounded-full"><%= point.get("campusArea") %></span>
                        <% } else { %>
                        <span class="text-ink-faint">-</span>
                        <% } %>
                    </td>
                    <td class="px-4 py-3 text-ink-secondary"><%= point.get("address") %></td>
                    <td class="px-4 py-3 text-ink-secondary">
                        <%= point.get("phone") != null && !((String) point.get("phone")).isEmpty() ? point.get("phone") : "-" %>
                    </td>
                    <td class="px-4 py-3 text-ink-secondary">
                        <%= point.get("openTime") != null && !((String) point.get("openTime")).isEmpty() ? point.get("openTime") : "-" %>
                    </td>
                    <td class="px-4 py-3 text-center">
                        <% if ((Boolean) point.get("enabled")) { %>
                        <span class="inline-block px-2 py-0.5 bg-green-100 text-green-700 text-xs font-medium rounded-full">启用</span>
                        <% } else { %>
                        <span class="inline-block px-2 py-0.5 bg-stone-100 text-stone-500 text-xs font-medium rounded-full">禁用</span>
                        <% } %>
                    </td>
                    <td class="px-4 py-3 text-center">
                        <div class="flex items-center justify-center gap-2">
                            <form method="post" action="${pageContext.request.contextPath}/admin/pickup-points" style="display:inline">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="pointId" value="<%= point.get("id") %>">
                                <button type="submit" class="px-3 py-1.5 text-xs font-medium rounded-lg transition-colors btn-press
                                    <%= (Boolean) point.get("enabled")
                                        ? "bg-amber-50 text-amber-600 border border-amber-200 hover:bg-amber-100"
                                        : "bg-green-50 text-green-600 border border-green-200 hover:bg-green-100" %>">
                                    <%= (Boolean) point.get("enabled") ? "禁用" : "启用" %>
                                </button>
                            </form>
                            <form method="post" action="${pageContext.request.contextPath}/admin/pickup-points" style="display:inline"
                                  onsubmit="return confirm('确定要删除自提点「<%= point.get("name") %>」吗？');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="pointId" value="<%= point.get("id") %>">
                                <button type="submit" class="px-3 py-1.5 text-xs font-medium bg-rose-50 text-rose-600 border border-rose-200 rounded-lg hover:bg-rose-100 transition-colors btn-press">
                                    删除
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    <% } %>
</main>

</body>
</html>
