<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%
    User navLoginUser = (User) session.getAttribute("loginUser");
    String activePage = request.getParameter("active");
    if (activePage == null) activePage = "";
    String isAdminParam = request.getParameter("isAdmin");
    boolean isNavAdmin = "true".equals(isAdminParam);

    int navUnreadNotifyCount = 0;
    if (navLoginUser != null) {
        try {
            java.sql.Connection navConn = com.minzu.util.DBUtil.getConnection();
            java.sql.PreparedStatement navPs = navConn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0");
            navPs.setInt(1, navLoginUser.getUserId());
            java.sql.ResultSet navRs = navPs.executeQuery();
            if (navRs.next()) navUnreadNotifyCount = navRs.getInt(1);
            navRs.close(); navPs.close(); navConn.close();
        } catch (Exception ignore) {}
    }
%>
<nav class="sticky top-0 bg-surface-raised/80 backdrop-blur-xl border-b border-stone-200/50 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 h-14 flex items-center justify-between">
        <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-2">
            <div class="w-8 h-8 bg-brand-500 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                    <line x1="3" y1="6" x2="21" y2="6"/>
                    <path d="M16 10a4 4 0 0 1-8 0"/>
                </svg>
            </div>
            <span class="font-display font-bold text-ink-primary"><%= isNavAdmin ? "民大二手 · 管理后台" : "民大二手平台" %></span>
        </a>

        <div class="hidden md:flex items-center gap-1">
        <% if (isNavAdmin) { %>
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "dashboard".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">统计面板</a>
            <a href="${pageContext.request.contextPath}/admin/users"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "users".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">用户管理</a>
            <a href="${pageContext.request.contextPath}/admin/products"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "admin-products".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">商品巡查</a>
            <a href="${pageContext.request.contextPath}/report"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "reports".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">举报管理</a>
            <a href="${pageContext.request.contextPath}/dispute?action=admin"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "disputes".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">纠纷管理</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/index.jsp"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "home".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">首页</a>
            <a href="${pageContext.request.contextPath}/pickup-locations.jsp"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "pickup".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">自提点</a>
            <a href="${pageContext.request.contextPath}/product-list"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "products".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">浏览商品</a>
            <a href="${pageContext.request.contextPath}/zone?type=graduation"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "zone".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">专区</a>
            <% if (navLoginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-products"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "my-products".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">我的商品</a>
            <a href="${pageContext.request.contextPath}/orders"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "orders".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">我的订单</a>
            <a href="${pageContext.request.contextPath}/messages"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "messages".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">私信</a>
            <a href="${pageContext.request.contextPath}/my-favorites"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "favorites".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">收藏</a>
            <a href="${pageContext.request.contextPath}/offer"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors <%= "offers".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">出价</a>
            <a href="${pageContext.request.contextPath}/notifications"
               class="px-3 py-2 text-sm font-medium rounded-lg transition-colors relative <%= "notifications".equals(activePage) ? "text-brand-600 bg-brand-50" : "text-ink-muted hover:text-ink-primary hover:bg-stone-100" %>">
                通知
                <% if (navUnreadNotifyCount > 0) { %>
                <span class="absolute -top-1 -right-1 w-4 h-4 bg-red-500 text-white text-xs font-bold rounded-full flex items-center justify-center"><%= navUnreadNotifyCount %></span>
                <% } %>
            </a>
            <% } %>
        <% } %>
        </div>

        <div class="flex items-center gap-2">
        <% if (isNavAdmin) { %>
            <a href="${pageContext.request.contextPath}/index.jsp" class="px-3 py-2 text-sm font-medium text-ink-muted hover:text-ink-primary hover:bg-stone-100 rounded-lg transition-colors">前台首页</a>
            <a href="${pageContext.request.contextPath}/logout" class="px-4 py-2 text-sm font-medium bg-brand-500 text-white rounded-lg hover:bg-brand-600 transition-colors btn-press">退出</a>
        <% } else if (navLoginUser != null) { %>
            <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 mr-1" title="个人信息">
                <%
                    String navAvatarUrl = navLoginUser.getAvatarUrl();
                    String navInitial = (navLoginUser.getRealName() != null && !navLoginUser.getRealName().isEmpty())
                                        ? navLoginUser.getRealName().substring(0, 1) : "?";
                %>
                <% if (navAvatarUrl != null && !navAvatarUrl.isEmpty()) { %>
                    <img src="<%= navAvatarUrl %>" alt="头像" class="w-8 h-8 rounded-full object-cover border-2 border-stone-200">
                <% } else { %>
                    <div class="w-8 h-8 bg-brand-500 rounded-full flex items-center justify-center text-white text-sm font-bold">
                        <%= navInitial %>
                    </div>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product" class="px-4 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press flex items-center gap-1">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                发布商品
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="text-sm text-ink-muted hover:text-red-500 transition-colors px-2 py-1.5">退出</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login" class="text-sm text-ink-muted hover:text-ink-primary transition-colors px-2 py-1.5">登录</a>
        <% } %>
        </div>
    </div>
</nav>
