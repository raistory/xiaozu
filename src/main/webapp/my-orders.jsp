<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> orderList = (List<Map<String, Object>>) request.getAttribute("orderList");
    if (orderList == null) orderList = new ArrayList<>();
    String type = (String) request.getAttribute("type");
    if (type == null) type = "buy";
    int currentPage = request.getAttribute("currentPage") != null ? ((Number) request.getAttribute("currentPage")).intValue() : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? ((Number) request.getAttribute("totalPages")).intValue()  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? ((Number) request.getAttribute("totalCount")).intValue()  : 0;
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 民大二手交易平台</title>
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
    <jsp:param name="active" value="orders"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-4xl mx-auto px-4 py-8">
    <h1 class="font-display text-2xl font-bold text-ink-primary mb-6">我的订单</h1>

    <!-- 标签切换 -->
    <div class="flex gap-3 mb-6">
        <a href="${pageContext.request.contextPath}/orders?type=buy" class="flex items-center gap-2 px-5 py-2.5 <% if("buy".equals(type)){out.print("bg-brand-500 text-white");}else{out.print("bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600");}%> font-medium rounded-full transition-colors btn-press">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
            </svg>
            我买到的
        </a>
        <a href="${pageContext.request.contextPath}/orders?type=sell" class="flex items-center gap-2 px-5 py-2.5 <% if("sell".equals(type)){out.print("bg-brand-500 text-white");}else{out.print("bg-surface-raised border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600");}%> font-medium rounded-full transition-colors btn-press">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
            我卖出的
        </a>
    </div>

    <!-- 成功/错误提示 -->
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

    <!-- 订单列表 -->
    <% if (orderList.isEmpty()) { %>
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-16 text-center shadow-sm">
            <div class="w-16 h-16 mx-auto mb-4 bg-stone-100 rounded-full flex items-center justify-center">
                <svg class="w-8 h-8 text-stone-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
            </div>
            <p class="text-ink-muted text-sm font-medium mb-1">暂无订单记录</p>
            <p class="text-ink-muted text-xs mb-4">你还没有任何订单，去逛逛商品列表吧。</p>
            <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 px-5 py-2.5 bg-brand-500 text-white font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
                去浏览商品
            </a>
        </div>
    <% } else { %>
        <div class="space-y-4">
            <% for (Map<String, Object> o : orderList) { %>
            <%
                String status = (String) o.get("orderStatus");
                String sText;
                String badgeBgClass;
                String badgeTextClass;
                if ("CREATED".equals(status)) {
                    sText = "待交易"; badgeBgClass = "bg-blue-100"; badgeTextClass = "text-blue-700";
                } else if ("PAID_OFFLINE".equals(status)) {
                    sText = "线下已成交"; badgeBgClass = "bg-orange-100"; badgeTextClass = "text-orange-700";
                } else if ("CANCELLED".equals(status)) {
                    sText = "已取消"; badgeBgClass = "bg-stone-100"; badgeTextClass = "text-stone-600";
                } else if ("COMPLETED".equals(status)) {
                    sText = "已完成"; badgeBgClass = "bg-brand-100"; badgeTextClass = "text-brand-700";
                } else if ("DISPUTED".equals(status)) {
                    sText = "纠纷中"; badgeBgClass = "bg-red-100"; badgeTextClass = "text-red-700";
                } else {
                    sText = (status != null ? status : "未知"); badgeBgClass = "bg-stone-100"; badgeTextClass = "text-stone-600";
                }
            %>
            <div class="bg-surface-raised border border-stone-200 rounded-xl p-5 hover-lift">
                <div class="flex gap-4 items-start">
                    <% String coverUrl = (String) o.get("coverImageUrl"); %>
                    <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
                        <img src="<%= coverUrl %>" alt="商品图" class="w-24 h-24 object-cover rounded-lg bg-stone-100 flex-shrink-0" loading="lazy">
                    <% } else { %>
                        <div class="w-24 h-24 rounded-lg bg-stone-100 flex-shrink-0 flex flex-col items-center justify-center gap-1 text-ink-faint">
                            <svg class="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            <span class="text-xs">暂无图片</span>
                        </div>
                    <% } %>
                    <div class="flex-1 min-w-0">
                        <!-- 状态标签 -->
                        <div class="flex items-center gap-2 mb-2">
                            <span class="inline-flex items-center px-3 py-1 <%= badgeBgClass %> <%= badgeTextClass %> text-xs font-semibold rounded-full"><%= sText %></span>
                        </div>
                        <!-- 商品标题 -->
                        <h3 class="font-medium text-ink-primary truncate"><%= o.get("title") != null ? o.get("title") : "商品已删除" %></h3>
                        <!-- 订单信息 -->
                        <div class="mt-2 text-xs text-ink-muted space-y-1">
                            <p>订单号：<%= o.get("orderNo") %> &nbsp;|&nbsp; 成交价：<strong class="text-ink-primary">&yen;<%= o.get("dealPrice") %></strong> &nbsp;|&nbsp; 数量：<%= o.get("quantity") %></p>
                            <p>买家：<%= o.get("buyerName") %> &nbsp;|&nbsp; 卖家：<%= o.get("sellerName") %></p>
                            <p>创建时间：<%= o.get("createdAt") %>
                            <% if (o.get("paidAt") != null) { %> &nbsp;|&nbsp; 成交：<%= o.get("paidAt") %><% } %>
                            <% if (o.get("completedAt") != null) { %> &nbsp;|&nbsp; 完成：<%= o.get("completedAt") %><% } %>
                            <% if (o.get("cancelledAt") != null) { %> &nbsp;|&nbsp; 取消：<%= o.get("cancelledAt") %><% } %>
                            </p>
                            <% if (o.get("buyerNote") != null) { %><p class="text-ink-faint">买家备注：<%= o.get("buyerNote") %></p><% } %>
                            <% if (o.get("sellerNote") != null) { %><p class="text-ink-faint">卖家备注：<%= o.get("sellerNote") %></p><% } %>
                        </div>
                        <%
                            String pc = (String) o.get("pickupCode");
                            boolean showPc = pc != null && !pc.isEmpty()
                                && ("PAID_OFFLINE".equals(status) || "COMPLETED".equals(status));
                        %>
                        <% if (showPc) { %>
                            <div class="mt-3 flex items-center gap-2">
                                <span class="text-xs text-ink-muted">取货码</span>
                                <span class="px-4 py-1 bg-orange-100 border border-orange-200 text-orange-600 text-lg font-bold tracking-wider rounded"><%= pc %></span>
                            </div>
                        <% } %>
                        <!-- 操作按钮 -->
                        <div class="mt-4 flex gap-2 flex-wrap">
                            <% Object pid = o.get("productId"); %>
                            <% if (pid != null) { %>
                                <a href="${pageContext.request.contextPath}/product-detail?id=<%= pid %>" class="inline-flex items-center gap-1.5 px-3 py-2 bg-surface-raised border border-stone-200 text-ink-muted text-sm font-medium rounded-lg hover:border-stone-300 hover:text-ink-primary transition-colors">
                                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                                    </svg>
                                    查看商品
                                </a>
                            <% } %>
                            <% if ("buy".equals(type) && "CREATED".equals(status)) { %>
                                <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确定要取消该订单吗？');" class="inline-flex">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                    <input type="hidden" name="type" value="buy">
                                    <button class="inline-flex items-center gap-1.5 px-3 py-2 bg-red-50 border border-red-200 text-red-600 text-sm font-medium rounded-lg hover:bg-red-100 transition-colors btn-press" type="submit">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                                        </svg>
                                        取消订单
                                    </button>
                                </form>
                            <% } %>
                            <% if ("sell".equals(type) && "CREATED".equals(status)) { %>
                                <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确认已与买家完成线下交易吗？');" class="inline-flex">
                                    <input type="hidden" name="action" value="paid">
                                    <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                    <input type="hidden" name="type" value="sell">
                                    <button class="inline-flex items-center gap-1.5 px-3 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press" type="submit">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <polyline points="20 6 9 17 4 12"/>
                                        </svg>
                                        确认线下成交
                                    </button>
                                </form>
                            <% } %>
                            <% if ("buy".equals(type) && "PAID_OFFLINE".equals(status)) { %>
                                <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确认交易已完成吗？');" class="inline-flex">
                                    <input type="hidden" name="action" value="complete">
                                    <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                    <input type="hidden" name="type" value="buy">
                                    <button class="inline-flex items-center gap-1.5 px-3 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press" type="submit">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <polyline points="20 6 9 17 4 12"/>
                                        </svg>
                                        确认完成
                                    </button>
                                </form>
                            <% } %>
                            <% if ("CREATED".equals(status) || "PAID_OFFLINE".equals(status)) { %>
                                <form id="disputeForm_<%= o.get("orderId") %>" action="${pageContext.request.contextPath}/dispute" method="post" style="margin:0;" class="inline-flex">
                                    <input type="hidden" name="action" value="submit">
                                    <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                    <input type="hidden" name="reason" id="disputeReason_<%= o.get("orderId") %>" value="">
                                    <button class="inline-flex items-center gap-1.5 px-3 py-2 bg-orange-50 border border-orange-200 text-orange-600 text-sm font-medium rounded-lg hover:bg-orange-100 transition-colors btn-press" type="button" onclick="submitDispute('<%= o.get("orderId") %>')">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                                        </svg>
                                        发起纠纷
                                    </button>
                                </form>
                            <% } %>
                            <% if ("COMPLETED".equals(status)) {
                                Boolean hasReviewed = (Boolean) o.get("hasReviewed");
                                if (hasReviewed != null && hasReviewed) { %>
                                    <span class="inline-flex items-center gap-1.5 px-3 py-2 bg-stone-100 text-ink-faint text-sm font-medium rounded-lg">已评价</span>
                                <% } else { %>
                                    <a href="${pageContext.request.contextPath}/review?orderId=<%= o.get("orderId") %>" class="inline-flex items-center gap-1.5 px-3 py-2 bg-brand-500 text-white text-sm font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
                                        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                                        </svg>
                                        去评价
                                    </a>
                                <% }
                            } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>

    <!-- 分页 -->
    <% if (totalPages > 1) { %>
    <nav class="flex justify-center items-center gap-2 mt-8" aria-label="分页">
        <a href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= currentPage-1 %>" class="w-9 h-9 flex items-center justify-center border border-stone-200 rounded-lg text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-colors<% if(currentPage==1){out.print(" pointer-events-none opacity-35");}%>" aria-label="上一页">&lsaquo;</a>
        <%
            int startP = Math.max(1, currentPage - 2);
            int endP   = Math.min(totalPages, currentPage + 2);
        %>
        <% if (startP > 1) { %>
            <a href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=1" class="w-9 h-9 flex items-center justify-center border border-stone-200 rounded-lg text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-colors">1</a>
            <% if (startP > 2) { %><span class="text-xs text-ink-muted px-1">...</span><% } %>
        <% } %>
        <% for (int p = startP; p <= endP; p++) { %>
            <a href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= p %>" class="w-9 h-9 flex items-center justify-center<% if(p==currentPage){out.print(" bg-brand-500 text-white font-semibold");}else{out.print(" border border-stone-200 text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-colors");}%> rounded-lg"><%= p %></a>
        <% } %>
        <% if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span class="text-xs text-ink-muted px-1">...</span><% } %>
            <a href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= totalPages %>" class="w-9 h-9 flex items-center justify-center border border-stone-200 rounded-lg text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-colors"><%= totalPages %></a>
        <% } %>
        <a href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= currentPage+1 %>" class="w-9 h-9 flex items-center justify-center border border-stone-200 rounded-lg text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-colors<% if(currentPage==totalPages){out.print(" pointer-events-none opacity-35");}%>" aria-label="下一页">&rsaquo;</a>
        <span class="text-xs text-ink-muted ml-2">共 <%= totalCount %> 条</span>
    </nav>
    <% } %>
</main>

<script>
function submitDispute(orderId) {
    var reason = prompt('请输入纠纷原因：');
    if (reason === null) {
        return;
    }
    if (reason.trim() === '') {
        alert('请输入纠纷原因！');
        return;
    }
    document.getElementById('disputeReason_' + orderId).value = reason.trim();
    document.getElementById('disputeForm_' + orderId).submit();
}
</script>

</body>
</html>
