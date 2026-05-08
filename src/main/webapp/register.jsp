<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 民大二手交易平台</title>
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
            0%, 100% { transform: translateY(0) rotate(0deg) scale(1); }
            50% { transform: translateY(-25px) rotate(8deg) scale(1.05); }
        }
        @keyframes floatMedium {
            0%, 100% { transform: translateY(0) rotate(0deg) scale(1); }
            50% { transform: translateY(-30px) rotate(-6deg) scale(1.08); }
        }
        @keyframes floatFast {
            0%, 100% { transform: translateY(0) scale(1); }
            50% { transform: translateY(-20px) scale(1.03); }
        }

        .bg-gradient-animate {
            background-size: 300% 300%;
            animation: gradientFlow 8s ease infinite;
        }
        @keyframes gradientFlow {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 100%; }
        }

        .particle {
            position: absolute;
            border-radius: 50%;
            animation: particleFloat 12s ease-in-out infinite;
            pointer-events: none;
        }
        @keyframes particleFloat {
            0% { opacity: 0; transform: translateY(100vh) scale(0); }
            10% { opacity: 0.6; transform: translateY(80vh) scale(0.5); }
            30% { opacity: 0.8; transform: translateY(60vh) scale(0.7); }
            50% { opacity: 1; transform: translateY(40vh) scale(0.8); }
            70% { opacity: 0.8; transform: translateY(20vh) scale(0.9); }
            90% { opacity: 0.6; transform: translateY(0vh) scale(0.7); }
            100% { opacity: 0; transform: translateY(-10vh) scale(0.5); }
        }

        .glow-pulse {
            animation: glowPulse 3s ease-in-out infinite;
        }
        @keyframes glowPulse {
            0%, 100% { opacity: 0.2; transform: scale(1); filter: blur(20px); }
            50% { opacity: 0.5; transform: scale(1.3); filter: blur(16px); }
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
            animation: cardSlideUp 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes cardSlideUp {
            0% { opacity: 0; transform: translateY(50px) scale(0.92); }
            60% { opacity: 0.6; transform: translateY(25px) scale(0.96); }
            100% { opacity: 1; transform: translateY(0) scale(1); }
        }

        .icon-spin-in {
            animation: iconSpinIn 1s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes iconSpinIn {
            0% { opacity: 0; transform: scale(0) rotate(-180deg); }
            50% { opacity: 0.8; transform: scale(0.6) rotate(-90deg); }
            100% { opacity: 1; transform: scale(1) rotate(0deg); }
        }

        .wave {
            animation: wave 6s ease-in-out infinite;
        }
        .wave:nth-child(2) { animation-delay: -1.5s; }
        @keyframes wave {
            0%, 100% { transform: translateX(0) translateY(0); }
            25% { transform: translateX(-3%) translateY(3%); }
            50% { transform: translateX(0) translateY(5%); }
            75% { transform: translateX(3%) translateY(3%); }
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
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transition: left 0.6s ease;
        }
        .btn-glow:hover::before {
            left: 100%;
        }

        .input-wrapper {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .input-wrapper:focus-within {
            transform: scale(1.02);
        }
        .input-wrapper:focus-within input {
            background: #ffffff;
            border-color: #22c55e;
            box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.2), 0 8px 20px rgba(34, 197, 94, 0.1);
        }
        .input-wrapper:focus-within .label-float {
            color: #16a34a;
        }

        .form-card {
            transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .form-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 30px 70px -15px rgba(34, 197, 94, 0.15), 0 15px 30px rgba(0,0,0,0.08);
            border-color: rgba(34, 197, 94, 0.3);
        }

        .logo-wrapper {
            transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .logo-wrapper:hover .logo-bg {
            transform: scale(1.1);
            box-shadow: 0 25px 60px -10px rgba(34, 197, 94, 0.25), 0 10px 25px rgba(34, 197, 94, 0.15);
        }
        .logo-wrapper:hover .logo-icon {
            transform: rotate(360deg);
        }

        .gradient-text-anim {
            background: linear-gradient(90deg, #22c55e, #16a34a, #22c55e);
            background-size: 200% auto;
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            text-fill-color: transparent;
            animation: textGradient 3s ease infinite;
        }
        @keyframes textGradient {
            0%, 100% { background-position: 0% center; }
            50% { background-position: 100% center; }
        }

        .strength-bar {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .strength-bar.active {
            transform: scaleX(1.1);
            filter: brightness(1.1);
        }

        .deco-enter {
            animation: decoFadeIn 1.2s ease-out;
        }
        @keyframes decoFadeIn {
            0% { opacity: 0; transform: translateY(30px); }
            100% { opacity: 1; transform: translateY(0); }
        }

        @media (prefers-reduced-motion: reduce) {
            .float-slow, .float-medium, .float-fast, .bg-gradient-animate, .glow-pulse, .card-enter, .icon-spin-in, .wave, .particle, .deco-enter { animation: none; }
            .btn-press:active, .form-card:hover, .logo-wrapper:hover { transform: none; }
            .btn-glow::before { animation: none; }
            .gradient-text-anim { animation: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen overflow-y-auto">

<!-- Full-screen animated background -->
<div class="fixed inset-0 bg-gradient-animate bg-gradient-to-br from-brand-50 via-emerald-50 to-amber-50">
    <!-- Dynamic particles -->
    <div class="particle w-3 h-3 bg-brand-400/40" style="top: 10%; left: 15%; animation-delay: 0s;"></div>
    <div class="particle w-2 h-2 bg-emerald-400/40" style="top: 20%; left: 25%; animation-delay: 2s;"></div>
    <div class="particle w-2.5 h-2.5 bg-amber-400/40" style="top: 15%; left: 40%; animation-delay: 4s;"></div>
    <div class="particle w-2 h-2 bg-brand-300/40" style="top: 25%; left: 60%; animation-delay: 1s;"></div>
    <div class="particle w-1.5 h-1.5 bg-emerald-300/40" style="top: 30%; left: 75%; animation-delay: 3s;"></div>
    <div class="particle w-2 h-2 bg-amber-300/40" style="top: 35%; left: 85%; animation-delay: 5s;"></div>
    <div class="particle w-1.5 h-1.5 bg-brand-400/40" style="top: 40%; left: 10%; animation-delay: 6s;"></div>
    <div class="particle w-2 h-2 bg-emerald-500/40" style="top: 50%; left: 30%; animation-delay: 2.5s;"></div>
    <div class="particle w-1.5 h-1.5 bg-amber-500/40" style="top: 45%; left: 55%; animation-delay: 4.5s;"></div>
    <div class="particle w-2 h-2 bg-brand-300/40" style="top: 55%; left: 70%; animation-delay: 1.5s;"></div>
    <div class="particle w-1 h-1 bg-emerald-400/40" style="top: 60%; left: 80%; animation-delay: 3s;"></div>
    <div class="particle w-1.5 h-1.5 bg-amber-400/40" style="top: 65%; left: 20%; animation-delay: 5.5s;"></div>
    <div class="particle w-2 h-2 bg-brand-500/40" style="top: 70%; left: 40%; animation-delay: 4.5s;"></div>

    <!-- Glow orbs -->
    <div class="glow-pulse deco-enter absolute top-1/4 left-1/4 w-96 h-96 bg-brand-300/40 rounded-full blur-3xl" style="animation-delay: 0s"></div>
    <div class="glow-pulse deco-enter absolute bottom-1/4 right-1/4 w-80 h-80 bg-amber-200/40 rounded-full blur-3xl" style="animation-delay: 1.5s"></div>
    <div class="glow-pulse deco-enter absolute top-1/2 right-1/3 w-64 h-64 bg-emerald-200/40 rounded-full blur-3xl" style="animation-delay: 2.5s"></div>
    <div class="glow-pulse deco-enter absolute top-1/3 left-1/2 w-48 h-48 bg-orange-100/40 rounded-full blur-3xl" style="animation-delay: 1s"></div>

    <!-- Floating decorative elements -->
    <div class="float-slow deco-enter absolute top-16 left-[8%] w-16 h-16 bg-white/60 backdrop-blur-sm rounded-2xl border border-brand-200/60 shadow-lg"></div>
    <div class="float-medium deco-enter absolute top-32 right-[12%] w-20 h-20 bg-white/50 backdrop-blur-sm rounded-2xl border border-emerald-200/60 shadow-lg" style="animation-delay: 1.5s"></div>
    <div class="float-slow deco-enter absolute bottom-28 left-[15%] w-14 h-14 bg-white/60 backdrop-blur-sm rounded-2xl border border-amber-200/60 shadow-lg" style="animation-delay: 3s"></div>
    <div class="float-fast deco-enter absolute bottom-20 right-[20%] w-12 h-12 bg-white/50 backdrop-blur-sm rounded-2xl border border-brand-200/60 shadow-lg" style="animation-delay: 2s"></div>

    <!-- Floating icons -->
    <div class="float-slow deco-enter absolute top-24 left-[28%]">
        <div class="w-12 h-12 bg-white/70 backdrop-blur-sm rounded-xl flex items-center justify-center border border-brand-200/50 shadow-lg">
            <svg class="w-6 h-6 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
            </svg>
        </div>
    </div>
    <div class="float-medium deco-enter absolute top-1/2 right-[8%]" style="animation-delay: 2s">
        <div class="w-14 h-14 bg-white/70 backdrop-blur-sm rounded-xl flex items-center justify-center border border-emerald-200/50 shadow-lg">
            <svg class="w-7 h-7 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="21" r="1"></circle>
                <circle cx="20" cy="21" r="1"></circle>
                <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2 1.61L23 6H6"></path>
            </svg>
        </div>
    </div>
    <div class="float-fast deco-enter absolute bottom-32 left-[8%]" style="animation-delay: 1s">
        <div class="w-10 h-10 bg-white/70 backdrop-blur-sm rounded-xl flex items-center justify-center border border-amber-200/50 shadow-lg">
            <svg class="w-5 h-5 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
            </svg>
        </div>
    </div>

    <!-- Wave decorations -->
    <svg class="wave absolute bottom-0 left-0 w-full h-32 text-brand-200/30" viewBox="0 0 1440 120" preserveAspectRatio="none">
        <path fill="currentColor" d="M0,64 C480,150,960,-20,1440,64 L1440,120 L0,120 Z"></path>
    </svg>
    <svg class="wave absolute bottom-0 left-0 w-full h-24 text-emerald-200/20" viewBox="0 0 1440 100" preserveAspectRatio="none">
        <path fill="currentColor" d="M0,40 C360,100,720,0,1080,60 C1260,90,1350,50,1440,40 L1440,100 L0,100 Z"></path>
    </svg>
</div>

<!-- Main content -->
<div class="relative z-10 min-h-screen flex items-center justify-center p-4 py-8">
    <div class="w-full max-w-xl">

        <!-- Logo -->
        <div class="text-center mb-8">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo-wrapper inline-flex items-center gap-3 mb-5">
                <div class="logo-bg w-14 h-14 bg-gradient-to-br from-brand-400 to-brand-600 rounded-2xl flex items-center justify-center shadow-xl">
                    <svg class="logo-icon w-8 h-8 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <path d="M16 10a4 4 0 0 1-8 0"></path>
                    </svg>
                </div>
                <span class="gradient-text-anim font-display font-bold text-3xl">民大二手平台</span>
            </a>
            <h1 class="font-display text-4xl font-bold text-ink-primary mb-2">创建账户</h1>
            <p class="text-ink-muted text-lg">加入我们，开启你的二手交易之旅</p>
        </div>

        <!-- Register form card -->
        <div class="card-enter form-card bg-white/80 backdrop-blur-xl rounded-3xl shadow-2xl overflow-hidden border border-white/50">
            <!-- Card header -->
            <div class="p-6 bg-gradient-to-r from-brand-50 to-emerald-50 border-b border-brand-100">
                <h2 class="font-display text-2xl font-bold text-ink-primary">填写注册信息</h2>
                <p class="text-ink-muted mt-1">请确保信息真实有效，用于校内身份验证</p>
            </div>

            <!-- Error message -->
            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="mx-6 mt-6 flex items-center gap-3 p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl text-sm">
                <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="15" y1="9" x2="9" y2="15"/>
                    <line x1="9" y1="9" x2="15" y2="15"/>
                </svg>
                <%= request.getAttribute("errorMsg") %>
            </div>
            <% } %>

            <!-- Register form -->
            <form action="${pageContext.request.contextPath}/register" method="post" class="p-6 space-y-5" novalidate>
                <!-- Student/Staff No -->
                <div class="input-wrapper relative pt-4">
                    <input
                        type="text"
                        id="studentOrStaffNo"
                        name="studentOrStaffNo"
                        placeholder=" "
                        required
                        value="<%= request.getParameter("studentOrStaffNo") == null ? "" : request.getParameter("studentOrStaffNo") %>"
                        class="input-float w-full px-4 py-4 bg-white border-2 border-stone-200/80 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all"
                    >
                    <label for="studentOrStaffNo" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">学号 / 工号 *</label>
                    <div class="absolute left-4 top-4 flex items-center pointer-events-none">
                    </div>
                </div>

                <!-- Real Name -->
                <div class="input-wrapper relative pt-4">
                    <input
                        type="text"
                        id="realName"
                        name="realName"
                        placeholder=" "
                        required
                        value="<%= request.getParameter("realName") == null ? "" : request.getParameter("realName") %>"
                        class="input-float w-full px-4 py-4 bg-white border-2 border-stone-200/80 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all"
                    >
                    <label for="realName" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">真实姓名 *</label>
                </div>

                <!-- Nickname (optional) -->
                <div class="input-wrapper relative pt-4">
                    <input
                        type="text"
                        id="nickname"
                        name="nickname"
                        placeholder=" "
                        value="<%= request.getParameter("nickname") == null ? "" : request.getParameter("nickname") %>"
                        class="input-float w-full px-4 py-4 bg-white border-2 border-stone-200/80 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all"
                    >
                    <label for="nickname" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">昵称（选填）</label>
                </div>

                <!-- Password -->
                <div class="input-wrapper relative pt-4">
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder=" "
                        required
                        class="input-float w-full px-4 py-4 bg-white border-2 border-stone-200/80 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all pr-12"
                        oninput="checkPasswordStrength(this.value)"
                    >
                    <label for="password" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">设置密码 *</label>
                    <button type="button" onclick="togglePassword('password')" class="absolute right-4 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
                <!-- Password strength indicator -->
                <div class="flex gap-2 -mt-2">
                    <div id="strength-1" class="strength-bar h-2 flex-1 rounded-full bg-stone-200/80"></div>
                    <div id="strength-2" class="strength-bar h-2 flex-1 rounded-full bg-stone-200/80"></div>
                    <div id="strength-3" class="strength-bar h-2 flex-1 rounded-full bg-stone-200/80"></div>
                    <div id="strength-4" class="strength-bar h-2 flex-1 rounded-full bg-stone-200/80"></div>
                </div>
                <p id="strength-text" class="text-xs text-ink-faint -mt-1">请设置6-16位字母/数字组合密码</p>

                <!-- Confirm Password -->
                <div class="input-wrapper relative pt-4">
                    <input
                        type="password"
                        id="confirmPassword"
                        name="confirmPassword"
                        placeholder=" "
                        required
                        class="input-float w-full px-4 py-4 bg-white border-2 border-stone-200/80 rounded-xl text-ink-primary input-glow focus:border-brand-500 transition-all pr-12"
                    >
                    <label for="confirmPassword" class="label-float absolute left-4 top-4 text-ink-muted pointer-events-none">确认密码 *</label>
                    <button type="button" onclick="togglePassword('confirmPassword')" class="absolute right-4 top-4 text-ink-faint hover:text-ink-muted transition-colors">
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>

                <!-- Register button -->
                <button type="submit" class="btn-glow w-full py-4 bg-gradient-to-r from-brand-500 to-emerald-500 hover:from-brand-600 hover:to-emerald-600 text-white font-display font-semibold rounded-xl btn-press transition-all shadow-lg shadow-brand-500/30 flex items-center justify-center gap-2 group">
                    <span>立即注册</span>
                    <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                        <polyline points="12 5 19 12 12 19"></polyline>
                    </svg>
                </button>
            </form>

            <!-- Login link -->
            <div class="px-6 pb-4">
                <p class="text-center text-ink-muted">
                    已有账户？
                    <a href="${pageContext.request.contextPath}/login" class="text-brand-600 hover:text-brand-700 font-semibold transition-colors">立即登录</a>
                </p>
            </div>

            <!-- Bottom tip -->
            <div class="px-6 pb-6">
                <div class="p-4 bg-gradient-to-r from-amber-50/80 to-orange-50/60 rounded-xl border border-amber-200/60">
                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 bg-amber-100 rounded-lg flex items-center justify-center flex-shrink-0">
                            <svg class="w-4 h-4 text-amber-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 22s8-4 8-10V5l-8-3-8v7c0 6 8 10 8 10z"></path>
                            </svg>
                        </div>
                        <div>
                            <p class="text-xs text-amber-800 font-medium">注册即表示你同意遵守平台规则</p>
                            <p class="text-xs text-amber-600/80 mt-0.5">请使用真实信息，诚信交易</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

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
    var colors = ['bg-red-500', 'bg-orange-500', 'bg-yellow-500', 'bg-brand-500'];
    var texts = ['弱', '一般', '中等', '强'];
    var textColors = ['text-red-500', 'text-orange-500', 'text-yellow-600', 'text-brand-600'];

    var level = Math.min(Math.floor(strength * 0.8), 4);

    bars.forEach(function(bar, i) {
        var el = document.getElementById(bar);
        if (i < level) {
            el.className = 'strength-bar h-2 flex-1 rounded-full transition-all active ' + colors[level - 1];
        } else {
            el.className = 'strength-bar h-2 flex-1 rounded-full bg-stone-200/80 transition-all';
        }
    });

    var textEl = document.getElementById('strength-text');
    if (password.length === 0) {
        textEl.textContent = '请设置6-16位字母/数字组合密码';
        textEl.className = 'text-xs text-ink-faint -mt-1';
    } else {
        textEl.textContent = '密码强度: ' + (texts[level - 1] || '弱');
        textEl.className = 'text-xs -mt-1 ' + (textColors[level - 1] || 'text-red-500');
    }
}
</script>

</body>
</html>
