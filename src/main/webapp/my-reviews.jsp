<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.minzu.entity.Review" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) reviews = new ArrayList<>();
    String view = (String) request.getAttribute("view");
    if (view == null) view = "sent";
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg");
    session.removeAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的评价 - 民大二手交易平台</title>
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
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="my-reviews"/>
</jsp:include>

<main class="max-w-3xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6">我的评价</h1>

    <% if (errMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%=errMsg%>
    </div>
    <% } %>
    <% if (sucMsg != null) { %>
    <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <%=sucMsg%>
    </div>
    <% } %>

    <div class="flex gap-4 border-b border-stone-200 mb-6">
        <a href="<%=request.getContextPath()%>/review?view=sent"
           class="text-sm font-medium pb-2 border-b-2 transition-colors <%="sent".equals(view)?"text-brand-600 border-brand-500":"text-ink-muted border-transparent hover:text-brand-600"%>">我发出的评价</a>
        <a href="<%=request.getContextPath()%>/review?view=received"
           class="text-sm font-medium pb-2 border-b-2 transition-colors <%="received".equals(view)?"text-brand-600 border-brand-500":"text-ink-muted border-transparent hover:text-brand-600"%>">收到的评价</a>
    </div>

    <% if (reviews.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        <p class="text-sm text-ink-muted">暂无评价记录</p>
    </div>
    <% } else { %>
    <div class="flex flex-col gap-3">
        <% for (Review r : reviews) { %>
        <div class="bg-surface-raised border border-stone-200 rounded-xl p-5">
            <div class="flex justify-between items-start gap-3 mb-2">
                <div>
                    <span class="text-sm font-semibold text-ink-primary"><%=r.getProductTitle() != null ? r.getProductTitle() : "已删除商品"%></span>
                    <span class="inline-block bg-brand-50 text-brand-600 px-2.5 py-0.5 rounded-full text-xs font-semibold ml-2"><%="BUYER".equals(r.getRole()) ? "买家评价" : "卖家评价"%></span>
                </div>
                <div class="text-base">
                    <% for (int i = 0; i < r.getScore(); i++) { %><span class="text-amber-400">★</span><% } %>
                    <% for (int i = r.getScore(); i < 5; i++) { %><span class="text-stone-300">★</span><% } %>
                </div>
            </div>
            <% if (r.getContent() != null && !r.getContent().isEmpty()) { %>
            <p class="text-sm text-ink-primary leading-relaxed mb-2"><%=r.getContent()%></p>
            <% } %>
            <div class="text-xs text-ink-muted">
                <% if ("sent".equals(view)) { %>评价对象：<%=r.getReviewedName()%>
                <% } else { %>评价人：<%=r.getReviewerName()%><% } %>
                &nbsp;&middot;&nbsp;<%=r.getCreatedAt()%>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</main>

</body>
</html>
