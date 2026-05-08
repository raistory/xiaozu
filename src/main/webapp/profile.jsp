<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg"); session.removeAttribute("successMsg");
    String uNo       = (String) request.getAttribute("u_no");       if(uNo==null) uNo="";
    String uRealName = (String) request.getAttribute("u_realName"); if(uRealName==null) uRealName="";
    String uNickname = (String) request.getAttribute("u_nickname"); if(uNickname==null) uNickname="";
    String uPhone    = (String) request.getAttribute("u_phone");    if(uPhone==null) uPhone="";
    String uEmail    = (String) request.getAttribute("u_email");    if(uEmail==null) uEmail="";
    String uAvatarUrl = (String) request.getAttribute("u_avatarUrl");

    String firstNameChar = uRealName.isEmpty() ? "?" : uRealName.substring(0, 1);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人信息 - 民大二手交易平台</title>
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
        .hover-lift:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .btn-press { transition: transform 0.15s ease, box-shadow 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }
        .input-glow:focus { outline: none; box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.15), 0 4px 12px rgba(0,0,0,0.08); }

        .gradient-border {
            position: relative;
            background: white;
        }
        .gradient-border::before {
            content: '';
            position: absolute;
            inset: 0;
            padding: 2px;
            border-radius: inherit;
            background: linear-gradient(135deg, #22c55e, #4ade80, #f97316);
            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor;
            mask-composite: exclude;
            pointer-events: none;
        }

        .input-float:focus + .label-float,
        .input-float:not(:placeholder-shown) + .label-float {
            transform: translateY(-28px) scale(0.85);
            color: #22c55e;
        }
        .label-float {
            transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
            transform-origin: left center;
        }

        .card-enter {
            animation: cardSlideUp 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes cardSlideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .strength-bar {
            transition: all 0.3s ease;
        }

        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .card-enter { animation: none; transition: none; }
            .hover-lift:hover { transform: none; }
            .btn-press:active { transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/30 to-stone-100">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value=""/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-2xl mx-auto px-4 py-8">
    <!-- 页面标题 -->
    <div class="mb-8">
        <h1 class="font-display text-3xl font-bold text-ink-primary">个人信息</h1>
        <p class="text-ink-muted mt-1">管理你的账户设置和偏好</p>
    </div>

    <!-- 错误/成功提示 -->
    <% if(errMsg!=null){ %>
    <div class="mb-4 bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
        <svg class="w-5 h-5 text-red-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
        </svg>
        <span class="text-red-700 text-sm"><%=errMsg%></span>
    </div>
    <% } %>
    <% if(sucMsg!=null){ %>
    <div class="mb-4 bg-brand-50 border border-brand-200 rounded-lg px-4 py-3 flex items-center gap-3">
        <svg class="w-5 h-5 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        <span class="text-brand-700 text-sm"><%=sucMsg%></span>
    </div>
    <% } %>

    <!-- 用户头像卡片 -->
    <div class="card-enter bg-gradient-to-r from-brand-500 to-brand-600 rounded-2xl p-6 mb-6 text-white relative overflow-hidden">
        <!-- 装饰图案 -->
        <div class="absolute right-0 top-0 w-32 h-32 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/2"></div>
        <div class="absolute right-20 bottom-0 w-20 h-20 bg-white/5 rounded-full translate-y-1/2"></div>

        <div class="flex items-center gap-4 relative z-10">
            <!-- 头像 (clickable for upload) -->
            <div class="relative cursor-pointer group" onclick="document.getElementById('avatarInput').click()">
                <% if (uAvatarUrl != null && !uAvatarUrl.isEmpty()) { %>
                    <img src="<%= uAvatarUrl %>" alt="头像" class="w-20 h-20 rounded-full object-cover border-2 border-white/30">
                <% } else { %>
                    <div class="w-20 h-20 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-2xl font-display font-bold border-2 border-white/30">
                        <%= firstNameChar %>
                    </div>
                <% } %>
                <!-- Hover overlay: camera icon -->
                <div class="absolute inset-0 bg-black/40 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <svg class="w-8 h-8 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                        <circle cx="12" cy="13" r="4"/>
                    </svg>
                </div>
                <div class="absolute -bottom-1 -right-1 w-6 h-6 bg-accent rounded-full flex items-center justify-center border-2 border-white">
                    <svg class="w-3 h-3 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                </div>
            </div>
            <!-- Hidden form for avatar upload -->
            <form method="post" action="<%= request.getContextPath() %>/profile" enctype="multipart/form-data" id="avatarForm">
                <input type="file" name="avatar" id="avatarInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none" onchange="document.getElementById('avatarForm').submit();">
            </form>
            <div>
                <h2 class="font-display text-xl font-bold"><%= uRealName %></h2>
                <p class="text-white/80 text-sm">学号/工号: <%= uNo %></p>
                <div class="flex items-center gap-2 mt-2">
                    <span class="px-2 py-0.5 bg-white/20 rounded-full text-xs">已认证</span>
                    <span class="px-2 py-0.5 bg-white/20 rounded-full text-xs">信用良好</span>
                </div>
            </div>
        </div>

        <!-- 统计数据 -->
        <div class="flex gap-6 mt-6 pt-4 border-t border-white/20 relative z-10">
            <div class="text-center">
                <p class="font-display text-2xl font-bold"><%= request.getAttribute("productCount") != null ? request.getAttribute("productCount") : "0" %></p>
                <p class="text-white/70 text-xs">在售商品</p>
            </div>
            <div class="text-center">
                <p class="font-display text-2xl font-bold"><%= request.getAttribute("soldCount") != null ? request.getAttribute("soldCount") : "0" %></p>
                <p class="text-white/70 text-xs">已售出</p>
            </div>
            <div class="text-center">
                <p class="font-display text-2xl font-bold"><%= request.getAttribute("userRating") != null ? request.getAttribute("userRating") : "-" %></p>
                <p class="text-white/70 text-xs">用户评分</p>
            </div>
            <div class="text-center">
                <p class="font-display text-2xl font-bold"><%= request.getAttribute("likeCount") != null ? request.getAttribute("likeCount") : "0" %></p>
                <p class="text-white/70 text-xs">获赞数</p>
            </div>
            <div class="text-center">
                <p class="font-display text-2xl font-bold"><%= request.getAttribute("favoriteCount") != null ? request.getAttribute("favoriteCount") : "0" %></p>
                <p class="text-white/70 text-xs">收藏商品</p>
            </div>
        </div>
    </div>

    <!-- 基本资料卡片 -->
    <div class="gradient-border rounded-2xl overflow-hidden mb-6 hover-lift">
        <div class="bg-surface-raised">
            <div class="px-6 py-4 border-b border-stone-100 bg-gradient-to-r from-brand-50/50 to-transparent">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-brand-100 rounded-lg flex items-center justify-center">
                        <svg class="w-4 h-4 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </div>
                    <h2 class="font-display font-semibold text-ink-primary">基本资料</h2>
                </div>
            </div>
            <form method="post" action="<%=request.getContextPath()%>/profile" class="p-6 space-y-5">
                <!-- 学号/工号 -->
                <div>
                    <label class="block text-sm font-medium text-ink-primary mb-2">学号 / 工号</label>
                    <div class="relative">
                        <input type="text" value="<%=uNo%>" disabled class="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-ink-muted cursor-not-allowed">
                        <div class="absolute right-3 top-1/2 -translate-y-1/2">
                            <svg class="w-4 h-4 text-ink-faint" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                        </div>
                    </div>
                </div>

                <!-- 真实姓名 -->
                <div>
                    <label class="block text-sm font-medium text-ink-primary mb-2">真实姓名</label>
                    <div class="relative">
                        <input type="text" value="<%=uRealName%>" disabled class="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-ink-muted cursor-not-allowed">
                        <div class="absolute right-3 top-1/2 -translate-y-1/2">
                            <svg class="w-4 h-4 text-ink-faint" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                        </div>
                    </div>
                </div>

                <!-- 昵称 -->
                <div class="relative pt-4">
                    <input type="text" id="nickname" name="nickname" value="<%=uNickname%>" maxlength="30" placeholder=" " class="input-float w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all">
                    <label for="nickname" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">昵称（选填）</label>
                </div>

                <!-- 手机号 -->
                <div>
                    <label class="block text-sm font-medium text-ink-primary mb-2">手机号</label>
                    <input type="tel" name="phone" value="<%=uPhone%>" maxlength="20" placeholder="联系手机（选填）" class="w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all">
                </div>

                <!-- 邮箱 -->
                <div class="relative pt-4">
                    <input type="email" id="email" name="email" value="<%=uEmail%>" maxlength="100" placeholder=" " class="input-float w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all">
                    <label for="email" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">邮箱（选填）</label>
                </div>

                <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-brand-500 to-brand-600 hover:from-brand-600 hover:to-brand-700 text-white font-display font-semibold rounded-xl btn-press transition-all shadow-lg shadow-brand-500/25 flex items-center justify-center gap-2">
                    <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                        <polyline points="17 21 17 13 7 13 7 21"/>
                        <polyline points="7 3 7 8 15 8"/>
                    </svg>
                    保存基本资料
                </button>
            </form>
        </div>
    </div>

    <!-- 修改密码卡片 -->
    <div class="gradient-border rounded-2xl overflow-hidden hover-lift">
        <div class="bg-surface-raised">
            <div class="px-6 py-4 border-b border-stone-100 bg-gradient-to-r from-orange-50/50 to-transparent">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                        <svg class="w-4 h-4 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </div>
                    <div>
                        <h2 class="font-display font-semibold text-ink-primary">修改密码</h2>
                        <p class="text-xs text-ink-muted">不修改则留空</p>
                    </div>
                </div>
            </div>
            <form method="post" action="<%=request.getContextPath()%>/profile" class="p-6 space-y-5">
                <input type="hidden" name="nickname" value="<%=uNickname%>">
                <input type="hidden" name="phone"    value="<%=uPhone%>">
                <input type="hidden" name="email"    value="<%=uEmail%>">

                <!-- 当前密码 -->
                <div class="relative pt-4">
                    <input type="password" id="oldPassword" name="oldPassword" placeholder=" " class="input-float w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all pr-10">
                    <label for="oldPassword" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">当前密码</label>
                    <button type="button" onclick="togglePassword('oldPassword')" class="absolute right-3 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>

                <!-- 新密码 -->
                <div>
                    <div class="relative pt-4">
                        <input type="password" id="newPassword" name="newPassword" placeholder=" " class="input-float w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all pr-10" oninput="checkPasswordStrength(this.value)">
                        <label for="newPassword" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">新密码</label>
                        <button type="button" onclick="togglePassword('newPassword')" class="absolute right-3 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                    <!-- 密码强度指示器 -->
                    <div class="flex gap-1 mt-3">
                        <div id="strength-1" class="strength-bar h-1.5 flex-1 rounded-full bg-stone-200"></div>
                        <div id="strength-2" class="strength-bar h-1.5 flex-1 rounded-full bg-stone-200"></div>
                        <div id="strength-3" class="strength-bar h-1.5 flex-1 rounded-full bg-stone-200"></div>
                        <div id="strength-4" class="strength-bar h-1.5 flex-1 rounded-full bg-stone-200"></div>
                    </div>
                    <p id="strength-text" class="text-xs text-ink-faint mt-1.5">请输入新密码</p>
                </div>

                <!-- 确认新密码 -->
                <div class="relative pt-4">
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder=" " class="input-float w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-ink-primary placeholder:text-ink-faint input-glow focus:border-brand-500 transition-all pr-10">
                    <label for="confirmPassword" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">确认新密码</label>
                    <button type="button" onclick="togglePassword('confirmPassword')" class="absolute right-3 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>

                <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-display font-semibold rounded-xl btn-press transition-all shadow-lg shadow-orange-500/25 flex items-center justify-center gap-2">
                    <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    修改密码
                </button>
            </form>
        </div>
    </div>

    <!-- 账户安全提示 -->
    <div class="mt-6 p-4 bg-brand-50/50 border border-brand-200/50 rounded-xl">
        <div class="flex items-start gap-3">
            <div class="w-8 h-8 bg-brand-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <svg class="w-4 h-4 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                </svg>
            </div>
            <div>
                <h3 class="text-sm font-medium text-brand-700">账户安全提示</h3>
                <p class="text-xs text-brand-600/80 mt-1">建议定期修改密码，使用字母、数字和符号的组合以提高账户安全性。</p>
            </div>
        </div>
    </div>
</main>

<script>
function togglePassword(id) {
    var input = document.getElementById(id);
    input.type = input.type === 'password' ? 'text' : 'password';
}

function checkPasswordStrength(password) {
    var strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (/[A-Z]/.test(password) && /[a-z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[^A-Za-z0-9]/.test(password)) strength++;

    var bars = ['strength-1', 'strength-2', 'strength-3', 'strength-4'];
    var colors = ['bg-red-400', 'bg-orange-400', 'bg-yellow-400', 'bg-brand-400'];
    var texts = ['弱', '一般', '中等', '强'];
    var textColors = ['text-red-600', 'text-orange-600', 'text-yellow-600', 'text-brand-600'];

    var level = Math.min(Math.floor(strength * 0.8), 4);

    bars.forEach(function(bar, i) {
        var el = document.getElementById(bar);
        el.className = 'strength-bar h-1.5 flex-1 rounded-full ' + (i < level ? colors[level - 1] : 'bg-stone-200');
    });

    var textEl = document.getElementById('strength-text');
    if (password.length === 0) {
        textEl.textContent = '请输入新密码';
        textEl.className = 'text-xs text-ink-faint mt-1.5';
    } else {
        textEl.textContent = '密码强度: ' + (texts[level - 1] || '弱');
        textEl.className = 'text-xs mt-1.5 ' + (textColors[level - 1] || 'text-red-600');
    }
}
</script>

</body>
</html>
