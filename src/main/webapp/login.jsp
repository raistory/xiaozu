<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 民大二手交易平台</title>
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

        .float-slow { animation: floatSlow 8s ease-in-out infinite; }
        .float-medium { animation: floatMedium 6s ease-in-out infinite; }
        .float-fast { animation: floatFast 4s ease-in-out infinite; }
        @keyframes floatSlow {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-15px) rotate(5deg); }
        }
        @keyframes floatMedium {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(-5deg); }
        }
        @keyframes floatFast {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .gradient-animate {
            background-size: 400% 400%;
            animation: gradientFlow 12s ease infinite;
        }
        @keyframes gradientFlow {
            0%, 100% { background-position: 0% 50%; }
            25% { background-position: 100% 50%; }
            50% { background-position: 100% 100%; }
            75% { background-position: 0% 100%; }
        }

        .glow-pulse {
            animation: glowPulse 3s ease-in-out infinite;
        }
        @keyframes glowPulse {
            0%, 100% { opacity: 0.3; transform: scale(1); }
            50% { opacity: 0.6; transform: scale(1.1); }
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
            animation: cardSlideUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes cardSlideUp {
            from { opacity: 0; transform: translateY(40px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .btn-glow {
            position: relative;
            overflow: hidden;
        }
        .btn-glow::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.5s ease;
        }
        .btn-glow:hover::before {
            left: 100%;
        }

        @media (prefers-reduced-motion: reduce) {
            .float-slow, .float-medium, .float-fast, .gradient-animate, .glow-pulse, .card-enter { animation: none; }
            .btn-press:active { transform: none; }
            .btn-glow::before { animation: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen overflow-hidden">

<%
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
%>

<!-- 全屏动态背景 -->
<div class="fixed inset-0 gradient-animate bg-gradient-to-br from-brand-700 via-brand-500 to-accent">
    <div class="glow-pulse absolute top-1/4 left-1/4 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
    <div class="glow-pulse absolute bottom-1/4 right-1/4 w-80 h-80 bg-white/10 rounded-full blur-3xl" style="animation-delay: 1.5s"></div>
    <div class="glow-pulse absolute top-1/2 right-1/3 w-64 h-64 bg-accent/20 rounded-full blur-3xl" style="animation-delay: 3s"></div>
    <div class="glow-pulse absolute top-1/3 left-1/3 w-48 h-48 bg-brand-400/20 rounded-full blur-3xl" style="animation-delay: 2s"></div>

    <div class="float-slow absolute top-20 left-[10%] w-16 h-16 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20"></div>
    <div class="float-medium absolute top-40 right-[15%] w-20 h-20 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20" style="animation-delay: 2s"></div>
    <div class="float-slow absolute bottom-32 left-[20%] w-14 h-14 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20" style="animation-delay: 4s"></div>
    <div class="float-fast absolute bottom-20 right-[25%] w-12 h-12 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20" style="animation-delay: 1s"></div>
    <div class="float-medium absolute top-1/3 left-[5%] w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full border border-white/20" style="animation-delay: 3s"></div>
    <div class="float-slow absolute bottom-1/3 right-[8%] w-8 h-8 bg-white/10 backdrop-blur-sm rounded-full border border-white/20" style="animation-delay: 5s"></div>

    <div class="float-slow absolute top-28 left-[30%]">
        <div class="w-12 h-12 bg-white/15 backdrop-blur-sm rounded-xl flex items-center justify-center border border-white/20">
            <svg class="w-6 h-6 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/></svg>
        </div>
    </div>
    <div class="float-medium absolute top-1/2 right-[10%]" style="animation-delay: 2s">
        <div class="w-14 h-14 bg-white/15 backdrop-blur-sm rounded-xl flex items-center justify-center border border-white/20">
            <svg class="w-7 h-7 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
        </div>
    </div>

    <svg class="wave absolute bottom-0 left-0 w-full h-32 text-white/5" viewBox="0 0 1440 120" preserveAspectRatio="none">
        <path fill="currentColor" d="M0,64 C480,150,960,-20,1440,64 L1440,120 L0,120 Z"/>
    </svg>
    <svg class="wave absolute bottom-0 left-0 w-full h-24 text-white/5" viewBox="0 0 1440 100" preserveAspectRatio="none">
        <path fill="currentColor" d="M0,40 C360,100,720,0,1080,60 C1260,90,1350,50,1440,40 L1440,100 L0,100 Z"/>
    </svg>
</div>

<!-- 主内容 -->
<div class="relative z-10 min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-5xl flex items-stretch gap-8">

        <!-- 左侧品牌区 -->
        <div class="hidden lg:flex flex-col justify-center w-1/2 text-white py-8">
            <div class="mb-8">
                <div class="w-24 h-24 bg-white/20 backdrop-blur-sm rounded-3xl flex items-center justify-center shadow-2xl border border-white/30">
                    <svg class="w-14 h-14 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                        <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                        <line x1="3" y1="6" x2="21" y2="6"/>
                        <path d="M16 10a4 4 0 0 1-8 0"/>
                    </svg>
                </div>
            </div>

            <h1 class="font-display text-5xl font-bold mb-4 leading-tight">
                民大二手<br>交易平台
            </h1>
            <p class="text-white/80 text-lg mb-8 max-w-md">
                校园二手交易，安全便捷。实名认证保障交易安全，让闲置物品找到新主人。
            </p>

            <div class="space-y-4 max-w-md">
                <div class="flex items-center gap-4 p-4 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20">
                    <div class="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center flex-shrink-0">
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <div>
                        <h3 class="font-semibold">实名认证</h3>
                        <p class="text-white/70 text-sm">学校统一认证，安全可靠</p>
                    </div>
                </div>
                <div class="flex items-center gap-4 p-4 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20">
                    <div class="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center flex-shrink-0">
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <div>
                        <h3 class="font-semibold">即时通讯</h3>
                        <p class="text-white/70 text-sm">内置私信功能，沟通便捷</p>
                    </div>
                </div>
                <div class="flex items-center gap-4 p-4 bg-white/10 backdrop-blur-sm rounded-2xl border border-white/20">
                    <div class="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center flex-shrink-0">
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                    </div>
                    <div>
                        <h3 class="font-semibold">价格实惠</h3>
                        <p class="text-white/70 text-sm">校园二手，物超所值</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 右侧登录卡片 -->
        <div class="w-full lg:w-[420px] flex-shrink-0">
            <div class="card-enter bg-white/95 backdrop-blur-xl rounded-3xl shadow-2xl overflow-hidden border border-white/20 h-full flex flex-col">
                <div class="p-6 bg-gradient-to-r from-brand-500/10 to-accent/10 border-b border-stone-100">
                    <div class="lg:hidden flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 bg-gradient-to-br from-brand-400 to-brand-600 rounded-xl flex items-center justify-center shadow-lg">
                            <svg class="w-6 h-6 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                                <line x1="3" y1="6" x2="21" y2="6"/>
                                <path d="M16 10a4 4 0 0 1-8 0"/>
                            </svg>
                        </div>
                        <span class="font-display font-bold text-xl text-ink-primary">民大二手平台</span>
                    </div>
                    <h2 class="font-display text-2xl font-bold text-ink-primary">欢迎回来</h2>
                    <p class="text-ink-muted mt-1">登录你的账户，开始交易之旅</p>
                </div>

                <!-- 消息提示 -->
                <% if (successMsg != null) { %>
                <div class="mx-6 mt-4 flex items-center gap-2 px-4 py-3 bg-brand-50 border border-brand-200 rounded-xl text-brand-700 text-sm">
                    <svg class="w-5 h-5 text-brand-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    <span><%= successMsg %></span>
                </div>
                <% } %>
                <% if (sessionErrorMsg != null) { %>
                <div class="mx-6 mt-4 flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">
                    <svg class="w-5 h-5 text-red-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    <span><%= sessionErrorMsg %></span>
                </div>
                <% } else if (request.getAttribute("errorMsg") != null) { %>
                <div class="mx-6 mt-4 flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">
                    <svg class="w-5 h-5 text-red-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    <span><%= request.getAttribute("errorMsg") %></span>
                </div>
                <% } %>

                <!-- 登录表单 -->
                <form action="${pageContext.request.contextPath}/login" method="post" class="p-6 space-y-5">
                    <div class="relative pt-4">
                        <input
                            type="text"
                            id="username"
                            name="account"
                            placeholder=" "
                            value="<%= request.getParameter("account") == null ? "" : request.getParameter("account") %>"
                            required
                            autocomplete="username"
                            class="input-float w-full px-4 py-4 bg-stone-50 border border-stone-200 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all"
                        >
                        <label for="username" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">学号 / 工号</label>
                    </div>

                    <div class="relative pt-4">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder=" "
                            required
                            autocomplete="current-password"
                            class="input-float w-full px-4 py-4 bg-stone-50 border border-stone-200 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all pr-12"
                        >
                        <label for="password" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">密码</label>
                        <button type="button" onclick="togglePassword()" class="absolute right-4 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                            <svg id="eyeIcon" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>

                    <div class="flex items-center justify-between">
                        <label class="flex items-center gap-2 cursor-pointer group">
                            <input type="checkbox" name="remember" class="w-4 h-4 text-brand-500 border-stone-300 rounded focus:ring-brand-500">
                            <span class="text-sm text-ink-muted group-hover:text-ink-primary transition-colors">记住我</span>
                        </label>
                        <a href="#" class="text-sm text-brand-600 hover:text-brand-700 transition-colors font-medium">忘记密码？</a>
                    </div>

                    <button type="submit" class="btn-glow w-full py-4 bg-gradient-to-r from-brand-500 to-brand-600 hover:from-brand-600 hover:to-brand-700 text-white font-display font-semibold rounded-xl btn-press transition-all shadow-lg shadow-brand-500/30 flex items-center justify-center gap-2 group">
                        <span>登录</span>
                        <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"/>
                            <polyline points="12 5 19 12 12 19"/>
                        </svg>
                    </button>
                </form>

                <div class="px-6">
                    <div class="flex items-center gap-4">
                        <div class="flex-1 h-px bg-stone-200"></div>
                        <span class="text-xs text-ink-faint">或</span>
                        <div class="flex-1 h-px bg-stone-200"></div>
                    </div>
                </div>

                <div class="p-6 pt-4">
                    <p class="text-center text-ink-muted">
                        还没有账户？
                        <a href="${pageContext.request.contextPath}/register" class="text-brand-600 hover:text-brand-700 font-semibold transition-colors">立即注册</a>
                    </p>
                </div>

                <div class="px-6 pb-6">
                    <div class="p-4 bg-brand-50/50 rounded-xl border border-brand-100">
                        <div class="flex items-start gap-3">
                            <div class="w-8 h-8 bg-brand-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                <svg class="w-4 h-4 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="10"/>
                                    <line x1="12" y1="16" x2="12" y2="12"/>
                                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                                </svg>
                            </div>
                            <div>
                                <p class="text-xs text-brand-700 font-medium">首次登录使用学校统一认证账号</p>
                                <p class="text-xs text-brand-600/70 mt-0.5">如遇问题请联系管理员</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function togglePassword() {
    const input = document.getElementById('password');
    const icon = document.getElementById('eyeIcon');
    if (input.type === 'password') {
        input.type = 'text';
        icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>';
    } else {
        input.type = 'password';
        icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
    }
}
</script>

</body>
</html>
