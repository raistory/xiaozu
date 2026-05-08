<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    boolean isLoggedIn = loginUser != null;
    boolean isAdmin = isLoggedIn && "ADMIN".equals(loginUser.getRoleCode());
    String displayInitial = isLoggedIn && loginUser.getRealName() != null && !loginUser.getRealName().isEmpty()
            ? loginUser.getRealName().substring(0,1) : "U";
    String displayName = isLoggedIn && loginUser.getRealName() != null && !loginUser.getRealName().isEmpty()
            ? loginUser.getRealName() : "游客";
    String displaySubtitle = isLoggedIn
            ? "学号: " + loginUser.getStudentOrStaffNo()
            : "登录后可发布商品、收藏和交易";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>民大二手交易平台 - 校园二手交易，安全便捷</title>
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
        .hover-lift:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.12); }
        .btn-press { transition: transform 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }
        .img-zoom { transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1); }
        .img-zoom:hover { transform: scale(1.08); }

        .product-enter {
            animation: productIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes productIn {
            from { opacity: 0; transform: translateY(30px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .mini-panel {
            position: fixed;
            left: 0;
            top: 50%;
            transform: translateY(-50%) translateX(-52px);
            width: 64px;
            background: linear-gradient(180deg, #ffffff 0%, #f8faf8 100%);
            border-radius: 0 24px 24px 0;
            box-shadow: 4px 0 20px rgba(0,0,0,0.08), 2px 0 8px rgba(0,0,0,0.04);
            z-index: 40;
            transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s ease;
        }
        .mini-panel:hover,
        .mini-panel.nearby {
            transform: translateY(-50%) translateX(0);
            box-shadow: 4px 0 30px rgba(34, 197, 94, 0.15), 2px 0 12px rgba(0,0,0,0.06);
        }
        .mini-panel-trigger {
            position: fixed;
            left: 0;
            top: 0;
            width: 80px;
            height: 100%;
            z-index: 39;
        }
        .drawer-handle {
            position: absolute;
            right: -12px;
            top: 50%;
            transform: translateY(-50%);
            width: 12px;
            height: 80px;
            background: linear-gradient(180deg, #22c55e 0%, #16a34a 100%);
            border-radius: 0 8px 8px 0;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            box-shadow: 2px 0 8px rgba(34, 197, 94, 0.3);
        }
        .drawer-handle:hover {
            width: 16px;
            height: 100px;
            background: linear-gradient(180deg, #16a34a 0%, #15803d 100%);
            box-shadow: 2px 0 12px rgba(34, 197, 94, 0.5);
        }
        .drawer-handle::before {
            content: '';
            position: absolute;
            left: 2px;
            top: 50%;
            transform: translateY(-50%);
            width: 2px;
            height: 40px;
            background: rgba(255,255,255,0.5);
            border-radius: 1px;
        }
        .drawer-handle svg {
            position: absolute;
            right: 2px;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        .mini-panel:hover .drawer-handle svg {
            opacity: 1;
        }
        .quick-icon {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            cursor: pointer;
        }
        .quick-icon:hover {
            transform: scale(1.15);
        }
        .drawer-panel {
            position: fixed;
            left: 0;
            top: 0;
            width: 280px;
            height: 100%;
            background: #ffffff;
            z-index: 50;
            transform: translateX(-100%);
            transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
            box-shadow: 0 0 0 rgba(0,0,0,0);
        }
        .drawer-panel.open {
            transform: translateX(0);
            box-shadow: 20px 0 60px rgba(0,0,0,0.2);
        }
        .drawer-menu-item {
            opacity: 0;
            transform: translateX(-20px);
            transition: all 0.3s ease;
        }
        .drawer-panel.open .drawer-menu-item {
            opacity: 1;
            transform: translateX(0);
        }
        .drawer-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.4);
            backdrop-filter: blur(4px);
            z-index: 45;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        .drawer-overlay.visible {
            opacity: 1;
            visibility: visible;
        }
        .user-info-enter {
            animation: userInfoIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes userInfoIn {
            0% { opacity: 0; transform: translateY(-20px) scale(0.9); }
            100% { opacity: 1; transform: translateY(0) scale(1); }
        }
        .category-icon {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .category-icon:hover {
            transform: scale(1.1) rotate(-5deg);
        }
        .banner-gradient {
            background-size: 200% 200%;
            animation: gradientMove 8s ease infinite;
        }
        @keyframes gradientMove {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }
        .price-tag {
            position: relative;
            overflow: hidden;
        }
        .price-tag::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transform: translateX(-100%);
            animation: shimmer 2.5s infinite;
        }
        @keyframes shimmer {
            100% { transform: translateX(100%); }
        }
        .hamburger-line {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            transform-origin: center;
        }
        .hamburger-active .hamburger-line:nth-child(1) {
            transform: translateY(6px) rotate(45deg);
        }
        .hamburger-active .hamburger-line:nth-child(2) {
            opacity: 0;
            transform: scaleX(0);
        }
        .hamburger-active .hamburger-line:nth-child(3) {
            transform: translateY(-6px) rotate(-45deg);
        }

        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .img-zoom, .product-enter, .category-icon { animation: none; transition: none; }
            .hover-lift:hover, .img-zoom:hover, .category-icon:hover { transform: none; }
            .btn-press:active { transform: none; }
            .price-tag::after, .banner-gradient { animation: none; }
        }
        @media (max-width: 1023px) {
            .mini-panel { display: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<!-- 迷你面板触发区域 -->
<div class="mini-panel-trigger hidden lg:block" id="miniPanelTrigger"></div>

<!-- 迷你面板 -->
<div id="miniPanel" class="mini-panel hidden lg:block">
    <div class="py-4 px-2 flex flex-col items-center gap-3">
        <div class="w-11 h-11 bg-gradient-to-br from-brand-400 to-brand-600 rounded-full flex items-center justify-center text-white font-display font-bold text-lg shadow-lg shadow-brand-500/30">
            <%= displayInitial %>
        </div>
        <div class="w-8 h-px bg-stone-200"></div>
        <a href="${pageContext.request.contextPath}/orders" class="quick-icon bg-brand-100 group" title="订单">
            <svg class="w-5 h-5 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
                <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
            </svg>
        </a>
        <a href="${pageContext.request.contextPath}/my-favorites" class="quick-icon bg-red-100 group" title="收藏">
            <svg class="w-5 h-5 text-red-500" viewBox="0 0 24 24" fill="currentColor">
                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
            </svg>
        </a>
        <a href="${pageContext.request.contextPath}/my-products" class="quick-icon bg-orange-100 group" title="商品">
            <svg class="w-5 h-5 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                <line x1="3" y1="9" x2="21" y2="9"/>
                <line x1="9" y1="21" x2="9" y2="9"/>
            </svg>
        </a>
        <a href="${pageContext.request.contextPath}/messages" class="quick-icon bg-blue-100 group" title="私信">
            <svg class="w-5 h-5 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            </svg>
        </a>
        <a href="${pageContext.request.contextPath}/notifications" class="quick-icon bg-purple-100 group relative" title="通知">
            <svg class="w-5 h-5 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
            <span class="absolute -top-1 -right-1 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white"></span>
        </a>
    </div>
    <!-- 抽屉把手 -->
    <div class="drawer-handle" onclick="openDrawer()">
        <svg class="w-3 h-3 text-white/80" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 18 15 12 9 6"/>
        </svg>
    </div>
</div>

<!-- 抽屉遮罩 -->
<div id="drawerOverlay" class="drawer-overlay" onclick="closeDrawer()"></div>

<!-- 抽屉面板 -->
<aside id="drawerPanel" class="drawer-panel">
    <div class="h-full flex flex-col overflow-hidden">
        <div class="user-info-enter p-6 bg-gradient-to-br from-brand-500 to-brand-600 text-white">
            <div class="flex items-center gap-4">
                <div class="w-14 h-14 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-2xl font-display font-bold shadow-lg">
                    <%= displayInitial %>
                </div>
                <div>
                    <h3 class="font-display font-semibold text-lg"><%= displayName %></h3>
                    <p class="text-white/80 text-sm"><%= displaySubtitle %></p>
                </div>
            </div>
            <div class="flex gap-4 mt-4">
                <div class="text-center">
                    <p class="text-2xl font-display font-bold"><%= isLoggedIn ? "—" : "0" %></p>
                    <p class="text-xs text-white/70">在售</p>
                </div>
                <div class="text-center">
                    <p class="text-2xl font-display font-bold"><%= isAdmin ? "管理员" : (isLoggedIn ? "用户" : "游客") %></p>
                    <p class="text-xs text-white/70">角色</p>
                </div>
            </div>
        </div>

        <div class="p-4 border-b border-stone-100">
            <p class="text-xs text-ink-faint font-medium mb-3 px-2">快捷入口</p>
            <div class="grid grid-cols-3 gap-2">
                <a href="${pageContext.request.contextPath}/orders" class="drawer-menu-item flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-brand-50 transition-colors group" style="transition-delay: 0.05s">
                    <div class="w-10 h-10 bg-brand-100 rounded-xl flex items-center justify-center group-hover:bg-brand-200 transition-colors">
                        <svg class="w-5 h-5 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                    </div>
                    <span class="text-xs text-ink-secondary">订单</span>
                </a>
                <a href="${pageContext.request.contextPath}/my-favorites" class="drawer-menu-item flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-red-50 transition-colors group" style="transition-delay: 0.1s">
                    <div class="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center group-hover:bg-red-200 transition-colors">
                        <svg class="w-5 h-5 text-red-500" viewBox="0 0 24 24" fill="currentColor"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                    </div>
                    <span class="text-xs text-ink-secondary">收藏</span>
                </a>
                <a href="${pageContext.request.contextPath}/my-products" class="drawer-menu-item flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-orange-50 transition-colors group" style="transition-delay: 0.15s">
                    <div class="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center group-hover:bg-orange-200 transition-colors">
                        <svg class="w-5 h-5 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                    </div>
                    <span class="text-xs text-ink-secondary">商品</span>
                </a>
                <a href="${pageContext.request.contextPath}/messages" class="drawer-menu-item flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-blue-50 transition-colors group" style="transition-delay: 0.2s">
                    <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center group-hover:bg-blue-200 transition-colors">
                        <svg class="w-5 h-5 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <span class="text-xs text-ink-secondary">私信</span>
                </a>
                <a href="${pageContext.request.contextPath}/notifications" class="drawer-menu-item flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-purple-50 transition-colors group relative" style="transition-delay: 0.25s">
                    <div class="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center group-hover:bg-purple-200 transition-colors">
                        <svg class="w-5 h-5 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                    </div>
                    <span class="text-xs text-ink-secondary">通知</span>
                    <span class="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
                </a>
            </div>
        </div>

        <nav class="flex-1 p-4 overflow-y-auto">
            <p class="text-xs text-ink-faint font-medium mb-2 px-2">导航</p>
            <a href="${pageContext.request.contextPath}/index.jsp" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl bg-brand-50 text-brand-600 font-medium" style="transition-delay: 0.35s">
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                <span class="text-sm">首页</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-ink-primary hover:bg-stone-100 transition-colors" style="transition-delay: 0.4s">
                <svg class="w-5 h-5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <span class="text-sm font-medium">浏览商品</span>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-ink-primary hover:bg-stone-100 transition-colors" style="transition-delay: 0.45s">
                <svg class="w-5 h-5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                <span class="text-sm font-medium">发布商品</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-ink-primary hover:bg-stone-100 transition-colors" style="transition-delay: 0.5s">
                <svg class="w-5 h-5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <span class="text-sm font-medium">个人中心</span>
            </a>
            <a href="${pageContext.request.contextPath}/pickup-locations.jsp" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-ink-primary hover:bg-stone-100 transition-colors" style="transition-delay: 0.55s">
                <svg class="w-5 h-5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <span class="text-sm font-medium">自提点</span>
            </a>
        </nav>

        <div class="p-4 border-t border-stone-100">
            <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-ink-muted hover:bg-stone-100 transition-colors" style="transition-delay: 0.6s">
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                <span class="text-sm">管理员后台</span>
            </a>
            <% } %>
            <a href="${pageContext.request.contextPath}/logout" class="drawer-menu-item flex items-center gap-3 px-3 py-2.5 rounded-xl text-red-600 hover:bg-red-50 transition-colors" style="transition-delay: 0.65s">
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                <span class="text-sm font-medium">退出登录</span>
            </a>
        </div>
    </div>
</aside>

<!-- 顶部导航 -->
<nav class="sticky top-0 bg-surface-raised/80 backdrop-blur-xl border-b border-stone-200/50 z-30 transition-all duration-300">
    <div class="max-w-7xl mx-auto px-4 h-14 flex items-center justify-between">
        <div class="flex items-center gap-4">
            <button id="hamburgerBtn" onclick="toggleMobileDrawer()" class="lg:hidden w-10 h-10 flex items-center justify-center rounded-xl hover:bg-stone-100 transition-colors">
                <div class="flex flex-col gap-1.5">
                    <span class="hamburger-line w-5 h-0.5 bg-ink-primary rounded-full"></span>
                    <span class="hamburger-line w-5 h-0.5 bg-ink-primary rounded-full"></span>
                    <span class="hamburger-line w-5 h-0.5 bg-ink-primary rounded-full"></span>
                </div>
            </button>
            <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-2">
                <div class="w-8 h-8 bg-gradient-to-br from-brand-400 to-brand-600 rounded-lg flex items-center justify-center shadow-lg shadow-brand-500/20">
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </div>
                <span class="font-display font-bold text-ink-primary hidden sm:inline">民大二手平台</span>
            </a>
        </div>
        <div class="flex-1 max-w-xl mx-4">
            <form action="${pageContext.request.contextPath}/product-list" method="get" class="relative">
                <input type="text" name="keyword" placeholder="搜索商品..." class="w-full pl-10 pr-4 py-2 bg-stone-100 border border-transparent rounded-xl text-sm text-ink-primary placeholder:text-ink-faint focus:bg-white focus:border-brand-300 focus:outline-none transition-all">
                <svg class="w-5 h-5 text-ink-faint absolute left-3 top-1/2 -translate-y-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            </form>
        </div>
        <div class="flex items-center gap-2">
            <a href="${pageContext.request.contextPath}/notifications" class="relative w-10 h-10 flex items-center justify-center rounded-xl hover:bg-stone-100 transition-colors">
                <svg class="w-5 h-5 text-ink-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product" class="px-4 py-2 bg-gradient-to-r from-brand-500 to-brand-600 text-white text-sm font-medium rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/20 flex items-center gap-1">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                <span class="hidden sm:inline">发布</span>
            </a>
        </div>
    </div>
</nav>

<!-- 主内容区 -->
<main class="max-w-7xl mx-auto px-4 py-6 transition-all duration-300">
    <!-- Banner轮播区 -->
    <div class="relative rounded-2xl overflow-hidden mb-6 h-48 md:h-64">
        <div class="banner-gradient absolute inset-0 bg-gradient-to-r from-brand-600 via-brand-500 to-accent"></div>
        <div class="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg%20width%3D%2260%22%20height%3D%2260%22%20viewBox%3D%220%200%2060%2060%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%3E%3Cg%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%3Cg%20fill%3D%22%23ffffff%22%20fill-opacity%3D%220.08%22%3E%3Cpath%20d%3D%22M36%2034v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6%2034v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6%204V0H4v4H0v2h4v4h2V6h4V4H6z%22%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E')] opacity-30"></div>
        <div class="relative z-10 h-full flex items-center justify-between px-8 md:px-12">
            <div class="text-white">
                <h2 class="font-display text-2xl md:text-4xl font-bold mb-2">校园二手交易</h2>
                <p class="text-white/80 text-sm md:text-base mb-4">安全便捷 · 实名认证 · 价格实惠</p>
                <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 px-6 py-3 bg-white text-brand-600 font-semibold rounded-xl hover:bg-brand-50 transition-colors btn-press shadow-lg">
                    <span>立即浏览</span>
                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </a>
            </div>
            <div class="hidden md:block">
                <div class="w-48 h-48 bg-white/10 backdrop-blur-sm rounded-3xl flex items-center justify-center">
                    <svg class="w-24 h-24 text-white/80" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </div>
            </div>
        </div>
        <div class="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2">
            <span class="w-6 h-1.5 bg-white rounded-full"></span>
            <span class="w-1.5 h-1.5 bg-white/50 rounded-full"></span>
            <span class="w-1.5 h-1.5 bg-white/50 rounded-full"></span>
        </div>
    </div>

    <!-- 分类导航 -->
    <div class="bg-surface-raised rounded-2xl shadow-sm p-4 mb-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="font-display font-semibold text-ink-primary">商品分类</h3>
            <a href="${pageContext.request.contextPath}/product-list" class="text-sm text-brand-600 hover:text-brand-700 transition-colors">全部分类 →</a>
        </div>
        <div class="grid grid-cols-4 md:grid-cols-8 gap-4">
            <a href="${pageContext.request.contextPath}/product-list?category=教材书籍" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-brand-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-brand-100 to-brand-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">教材书籍</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=数码电子" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-purple-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-purple-100 to-purple-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">数码电子</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=生活用品" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-blue-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-blue-100 to-blue-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">生活用品</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=运动户外" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-orange-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-orange-100 to-orange-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">运动户外</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=服饰鞋包" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-pink-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-pink-100 to-pink-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-pink-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.38 3.46L16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">服饰鞋包</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=娱乐休闲" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-cyan-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-cyan-100 to-cyan-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-cyan-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">娱乐休闲</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list?category=票券卡券" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-yellow-50 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-yellow-100 to-yellow-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-yellow-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">票券卡券</span>
            </a>
            <a href="${pageContext.request.contextPath}/product-list" class="category-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-stone-100 transition-colors">
                <div class="w-12 h-12 bg-gradient-to-br from-stone-100 to-stone-200 rounded-2xl flex items-center justify-center">
                    <svg class="w-6 h-6 text-stone-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 12h8M12 8v8"/></svg>
                </div>
                <span class="text-xs text-ink-secondary font-medium">其他</span>
            </a>
        </div>
    </div>

    <!-- 管理员入口 -->
    <% if (isAdmin) { %>
    <div class="bg-purple-50 border border-purple-200 rounded-2xl p-5 mb-6 flex items-center gap-4 flex-wrap">
        <div class="w-10 h-10 bg-purple-500 rounded-xl flex items-center justify-center flex-shrink-0">
            <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <div class="flex-1">
            <h4 class="font-display font-semibold text-purple-700 text-sm">管理员控制台</h4>
            <p class="text-purple-600/70 text-xs">你拥有管理员权限，可以审核用户与商品、查看数据报告</p>
        </div>
        <div class="flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/user-review" class="px-4 py-2 bg-purple-500 text-white text-sm font-medium rounded-xl hover:bg-purple-600 transition-colors btn-press">用户审核</a>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="px-4 py-2 bg-purple-500 text-white text-sm font-medium rounded-xl hover:bg-purple-600 transition-colors btn-press">数据面板</a>
        </div>
    </div>
    <% } %>

    <!-- 快捷入口 -->
    <div class="mb-6">
        <h3 class="font-display font-semibold text-ink-primary text-lg mb-4">快捷入口</h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <a href="${pageContext.request.contextPath}/product-list" class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift flex flex-col items-center gap-3 text-center group">
                <div class="w-12 h-12 bg-brand-100 rounded-2xl flex items-center justify-center group-hover:bg-brand-200 transition-colors">
                    <svg class="w-6 h-6 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                </div>
                <div>
                    <h4 class="font-medium text-ink-primary text-sm">浏览商品</h4>
                    <p class="text-xs text-ink-muted mt-1">查看全部在售二手好物</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product" class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift flex flex-col items-center gap-3 text-center group">
                <div class="w-12 h-12 bg-orange-100 rounded-2xl flex items-center justify-center group-hover:bg-orange-200 transition-colors">
                    <svg class="w-6 h-6 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                </div>
                <div>
                    <h4 class="font-medium text-ink-primary text-sm">发布商品</h4>
                    <p class="text-xs text-ink-muted mt-1">把闲置挂出来，让它找到新主人</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/my-products" class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift flex flex-col items-center gap-3 text-center group">
                <div class="w-12 h-12 bg-blue-100 rounded-2xl flex items-center justify-center group-hover:bg-blue-200 transition-colors">
                    <svg class="w-6 h-6 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                </div>
                <div>
                    <h4 class="font-medium text-ink-primary text-sm">我的商品</h4>
                    <p class="text-xs text-ink-muted mt-1">管理已发布的商品</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/orders" class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift flex flex-col items-center gap-3 text-center group">
                <div class="w-12 h-12 bg-purple-100 rounded-2xl flex items-center justify-center group-hover:bg-purple-200 transition-colors">
                    <svg class="w-6 h-6 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                </div>
                <div>
                    <h4 class="font-medium text-ink-primary text-sm">我的订单</h4>
                    <p class="text-xs text-ink-muted mt-1">查看买卖交易记录</p>
                </div>
            </a>
        </div>
    </div>

    <!-- 最新上架 -->
    <%
        List<Product> latestProducts = (List<Product>) request.getAttribute("latestProducts");
        if (latestProducts != null && !latestProducts.isEmpty()) {
    %>
    <div class="mb-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="font-display font-semibold text-ink-primary text-lg">最新上架</h3>
            <a href="${pageContext.request.contextPath}/product-list" class="text-sm text-brand-600 hover:text-brand-700 transition-colors flex items-center gap-1">
                查看更多
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
            <% int delayIdx = 0;
               for (Product p : latestProducts) {
                String condText = "成色未填";
                if (p.getConditionLevel() != null) {
                    switch (p.getConditionLevel()) {
                        case "NEW": condText = "全新"; break;
                        case "NINETY_NEW": condText = "九成新"; break;
                        case "EIGHTY_NEW": condText = "八成新"; break;
                        case "SEVENTY_NEW": condText = "七成新及以下"; break;
                        default: condText = p.getConditionLevel();
                    }
                }
            %>
            <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="product-enter bg-surface-raised border border-stone-200 rounded-2xl overflow-hidden hover-lift flex flex-col group" style="animation-delay: <%= 0.05 * delayIdx %>s">
                <div class="relative overflow-hidden">
                    <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                        <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" class="w-full h-36 object-cover img-zoom" loading="lazy">
                    <% } else { %>
                        <div class="w-full h-36 bg-stone-100 flex items-center justify-center">
                            <svg class="w-10 h-10 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        </div>
                    <% } %>
                </div>
                <div class="p-3 flex-1 flex flex-col">
                    <h4 class="text-sm font-medium text-ink-primary truncate group-hover:text-brand-600 transition-colors"><%= p.getTitle() %></h4>
                    <div class="mt-1.5">
                        <span class="price-tag text-lg font-bold text-red-600">¥<%= p.getPrice() %></span>
                    </div>
                    <p class="text-xs text-ink-muted mt-1.5 flex items-center gap-1">
                        <span class="px-1.5 py-0.5 bg-stone-100 rounded text-xs text-ink-muted"><%= condText %></span>
                        <span class="px-1.5 py-0.5 bg-stone-100 rounded text-xs text-ink-muted"><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                    </p>
                </div>
            </a>
            <% delayIdx++; } %>
        </div>
    </div>
    <% } else { %>
    <!-- 无商品时显示空状态 -->
    <div class="mb-6">
        <h3 class="font-display font-semibold text-ink-primary text-lg mb-4">最新上架</h3>
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-12 text-center">
            <svg class="w-16 h-16 text-stone-200 mx-auto mb-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
            <p class="text-ink-muted">暂无上架商品</p>
            <a href="${pageContext.request.contextPath}/publish-product" class="inline-block mt-4 px-6 py-2.5 bg-brand-500 text-white rounded-xl font-medium hover:bg-brand-600 transition-colors btn-press">发布第一件商品</a>
        </div>
    </div>
    <% } %>
</main>

<!-- 页脚 -->
<footer class="bg-surface-raised border-t border-stone-200 mt-12 transition-all duration-300">
    <div class="max-w-7xl mx-auto px-4 py-8">
        <div class="flex flex-col md:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 bg-gradient-to-br from-brand-400 to-brand-600 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </div>
                <span class="font-display font-bold text-ink-primary">民大二手平台</span>
            </div>
            <div class="flex items-center gap-6 text-sm text-ink-muted">
                <a href="#" class="hover:text-ink-primary transition-colors">关于我们</a>
                <a href="#" class="hover:text-ink-primary transition-colors">帮助中心</a>
                <a href="#" class="hover:text-ink-primary transition-colors">用户协议</a>
                <a href="#" class="hover:text-ink-primary transition-colors">隐私政策</a>
            </div>
            <p class="text-xs text-ink-faint">© 2024 民大二手交易平台 · 校园二手交易，安全便捷</p>
        </div>
    </div>
</footer>

<script>
let drawerOpen = false;

const miniPanelTrigger = document.getElementById('miniPanelTrigger');
const miniPanel = document.getElementById('miniPanel');

if (miniPanelTrigger && miniPanel) {
    miniPanelTrigger.addEventListener('mouseenter', () => { miniPanel.classList.add('nearby'); });
    miniPanelTrigger.addEventListener('mouseleave', () => { miniPanel.classList.remove('nearby'); });
    miniPanel.addEventListener('mouseenter', () => { miniPanel.classList.add('nearby'); });
    miniPanel.addEventListener('mouseleave', () => { miniPanel.classList.remove('nearby'); });
}

function openDrawer() {
    document.getElementById('drawerPanel').classList.add('open');
    document.getElementById('drawerOverlay').classList.add('visible');
    drawerOpen = true;
}

function closeDrawer() {
    document.getElementById('drawerPanel').classList.remove('open');
    document.getElementById('drawerOverlay').classList.remove('visible');
    drawerOpen = false;
}

function toggleMobileDrawer() {
    const hamburgerBtn = document.getElementById('hamburgerBtn');
    if (drawerOpen) {
        closeDrawer();
        hamburgerBtn.classList.remove('hamburger-active');
    } else {
        openDrawer();
        hamburgerBtn.classList.add('hamburger-active');
    }
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && drawerOpen) {
        closeDrawer();
        document.getElementById('hamburgerBtn').classList.remove('hamburger-active');
    }
});

window.addEventListener('resize', function() {
    if (window.innerWidth >= 1024 && drawerOpen) {
        closeDrawer();
        document.getElementById('hamburgerBtn').classList.remove('hamburger-active');
    }
});
</script>

</body>
</html>
