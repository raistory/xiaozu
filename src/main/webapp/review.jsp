<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    Object orderIdObj      = request.getAttribute("orderId");
    Object productTitleObj = request.getAttribute("productTitle");
    Object roleObj         = request.getAttribute("role");
    int orderId      = orderIdObj != null ? (int) orderIdObj : 0;
    String productTitle = productTitleObj != null ? productTitleObj.toString() : "";
    String role         = roleObj != null ? roleObj.toString() : "BUYER";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评价交易 - 民大二手交易平台</title>
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
        .input-glow:focus { outline: none; box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.15), 0 4px 12px rgba(0,0,0,0.08); }
        .star-group { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: 4px; }
        .star-group input[type=radio] { display: none; }
        .star-group label { font-size: 2rem; color: #d1d5db; cursor: pointer; transition: color 0.12s; margin-bottom: 0; }
        .star-group input[type=radio]:checked ~ label,
        .star-group label:hover,
        .star-group label:hover ~ label { color: #f59e0b; }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="orders"/>
</jsp:include>

<main class="max-w-lg mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6">评价交易</h1>

    <div class="bg-surface-raised border border-stone-200 rounded-xl p-5 mb-5">
        <div class="text-xs text-ink-muted mb-1">商品</div>
        <div class="text-sm font-semibold text-ink-primary"><%=productTitle%></div>
        <div class="mt-2">
            <span class="text-xs text-ink-muted">你的身份：</span>
            <span class="inline-block bg-brand-50 text-brand-600 px-2.5 py-0.5 rounded-full text-xs font-semibold"><%="BUYER".equals(role)?"买家":"卖家"%></span>
        </div>
    </div>

    <div class="bg-surface-raised border border-stone-200 rounded-xl p-6">
        <form method="post" action="<%=request.getContextPath()%>/review">
            <input type="hidden" name="orderId" value="<%=orderId%>">
            <div class="mb-5">
                <label class="block text-sm font-semibold text-ink-primary mb-3">评分（必填）</label>
                <div class="star-group">
                    <input type="radio" id="s5" name="score" value="5"><label for="s5">★</label>
                    <input type="radio" id="s4" name="score" value="4"><label for="s4">★</label>
                    <input type="radio" id="s3" name="score" value="3" checked><label for="s3">★</label>
                    <input type="radio" id="s2" name="score" value="2"><label for="s2">★</label>
                    <input type="radio" id="s1" name="score" value="1"><label for="s1">★</label>
                </div>
            </div>
            <div class="mb-6">
                <label class="block text-sm font-semibold text-ink-primary mb-2">评价内容（可选）</label>
                <textarea name="content" maxlength="300" placeholder="分享你的交易体验..."
                    class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-colors resize-y min-h-[110px]"></textarea>
            </div>
            <div class="flex gap-3">
                <button type="submit" class="bg-brand-500 text-white px-5 py-2.5 rounded-lg hover:bg-brand-600 transition-colors btn-press font-medium text-sm">提交评价</button>
                <a href="<%=request.getContextPath()%>/orders?type=buy" class="border border-stone-200 text-ink-muted px-5 py-2.5 rounded-lg hover:border-brand-500 hover:text-brand-600 transition-colors font-medium text-sm">返回订单</a>
            </div>
        </form>
    </div>
</main>

</body>
</html>
