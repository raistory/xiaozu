<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>错误 - 民大二手交易平台</title>
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
                        surface: { DEFAULT: '#fafaf9', raised: '#ffffff' },
                        ink: { primary: '#1c1917', muted: '#78716c' }
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
<body class="font-body min-h-screen bg-surface flex items-center justify-center p-6">
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-lg p-10 max-w-md w-full text-center">
        <svg class="w-12 h-12 text-red-500 mx-auto mb-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
            <line x1="12" y1="9" x2="12" y2="13"/>
            <line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
        <h1 class="font-display text-xl font-bold text-red-600 mb-3">操作失败</h1>
        <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg p-4 text-sm text-left mb-6">${errorMsg}</div>
        <a href="javascript:history.back()" class="inline-block bg-brand-500 text-white px-6 py-2.5 rounded-lg hover:bg-brand-600 transition-colors btn-press font-medium text-sm">返回上一页</a>
    </div>
</body>
</html>
