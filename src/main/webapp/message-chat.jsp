<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Message" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    int me = loginUser.getUserId();
    int otherId = (Integer) request.getAttribute("otherId");
    String otherNickname = (String) request.getAttribute("otherNickname");
    Map<String, Object> product = (Map<String, Object>) request.getAttribute("product");
    List<Message> chatList = (List<Message>) request.getAttribute("chatList");
    Long conversationId = (Long) request.getAttribute("conversationId");
    Object pidObj = request.getAttribute("productId");
    Integer productId = null;
    if (pidObj instanceof Long) productId = ((Long) pidObj).intValue();
    else if (pidObj instanceof Integer) productId = (Integer) pidObj;
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = (String) request.getAttribute("errorMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");

    // Compute other user initial for avatar
    String otherInitial = "?";
    if (otherNickname != null && otherNickname.length() > 0) {
        otherInitial = String.valueOf(otherNickname.charAt(0)).toUpperCase();
    }
    // Compute my initial
    String myInitial = "U";
    String myName = loginUser.getRealName();
    if (myName != null && myName.length() > 0) {
        myInitial = String.valueOf(myName.charAt(0)).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>与<%= otherNickname %>的私信 - 民大二手交易平台</title>
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
        /* 消息气泡动画 */
        .bubble-enter {
            animation: bubbleIn 0.3s ease-out;
        }
        @keyframes bubbleIn {
            from { opacity: 0; transform: translateY(10px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* 输入框聚焦效果 */
        .input-glow:focus {
            box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.15), 0 4px 12px rgba(0,0,0,0.08);
        }

        /* 时间分隔线 */
        .time-divider {
            position: relative;
        }
        .time-divider::before,
        .time-divider::after {
            content: '';
            position: absolute;
            top: 50%;
            width: calc(50% - 60px);
            height: 1px;
            background: linear-gradient(to right, transparent, #e7e5e4);
        }
        .time-divider::before { left: 0; }
        .time-divider::after { right: 0; background: linear-gradient(to left, transparent, #e7e5e4); }

        /* 滚动条美化 */
        .chat-scroll::-webkit-scrollbar { width: 6px; }
        .chat-scroll::-webkit-scrollbar-track { background: transparent; }
        .chat-scroll::-webkit-scrollbar-thumb { background: #d6d3d1; border-radius: 3px; }
        .chat-scroll::-webkit-scrollbar-thumb:hover { background: #a8a29e; }

        .btn-press { transition: transform 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }

        @media (prefers-reduced-motion: reduce) {
            .bubble-enter { animation: none; }
        }
    </style>
</head>
<body class="font-body h-screen flex flex-col bg-gradient-to-b from-stone-50 to-surface-DEFAULT">

<!-- 顶部导航 -->
<header class="bg-surface-raised/95 backdrop-blur-xl border-b border-stone-200/50 px-4 py-3 flex items-center justify-between flex-shrink-0 sticky top-0 z-50">
    <div class="flex items-center gap-4">
        <a href="${pageContext.request.contextPath}/messages" class="flex items-center gap-1 text-ink-muted hover:text-brand-600 transition-colors group">
            <svg class="w-5 h-5 transition-transform group-hover:-translate-x-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="15 18 9 12 15 6"/>
            </svg>
            <span class="text-sm font-medium">返回</span>
        </a>
        <!-- 对话者信息 -->
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-gradient-to-br from-brand-400 to-brand-600 rounded-full flex items-center justify-center text-white font-display font-bold text-lg shadow-lg shadow-brand-500/25">
                <%= otherInitial %>
            </div>
            <div>
                <h2 class="font-display font-semibold text-ink-primary"><%= otherNickname %></h2>
            </div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-2 text-ink-muted hover:text-ink-primary transition-colors">
        <div class="w-7 h-7 bg-brand-500 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
        </div>
        <span class="text-sm font-medium hidden sm:inline">民大二手</span>
    </a>
</header>

<% if (successMsg != null) { %>
<div class="flex-shrink-0 flex items-center gap-2 px-4 py-3 bg-brand-50 border-b border-brand-200 text-brand-700 text-sm">
    <svg class="w-5 h-5 text-brand-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
    <span><%= successMsg %></span>
</div>
<% } %>
<% if (errorMsg != null) { %>
<div class="flex-shrink-0 flex items-center gap-2 px-4 py-3 bg-red-50 border-b border-red-200 text-red-700 text-sm">
    <svg class="w-5 h-5 text-red-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
    <span><%= errorMsg %></span>
</div>
<% } %>

<% if (product != null) { %>
<!-- 商品信息栏 -->
<div class="bg-surface-raised border-b border-stone-100 px-4 py-3 flex-shrink-0">
    <div class="flex items-center gap-3 max-w-2xl mx-auto">
        <% String coverUrl = (String) product.get("coverUrl"); %>
        <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
            <img src="<%= coverUrl %>" alt="" class="w-12 h-12 rounded-xl object-cover shadow-md">
        <% } else { %>
            <div class="w-12 h-12 rounded-xl bg-stone-100 flex items-center justify-center shadow-md">
                <svg class="w-6 h-6 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                    <line x1="3" y1="6" x2="21" y2="6"/>
                    <path d="M16 10a4 4 0 0 1-8 0"/>
                </svg>
            </div>
        <% } %>
        <div class="flex-1 min-w-0">
            <h3 class="text-sm font-medium text-ink-primary truncate"><%= product.get("title") %></h3>
            <p class="text-sm font-display font-bold text-red-600">&yen;<%= product.get("price") %></p>
        </div>
        <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.get("productId") %>" class="px-4 py-2 bg-brand-50 text-brand-600 text-xs font-semibold rounded-full hover:bg-brand-100 transition-colors border border-brand-200">
            查看商品详情
        </a>
    </div>
</div>
<% } %>

<!-- 聊天区域 -->
<main class="flex-1 overflow-y-auto chat-scroll px-4 py-6" id="chatBody">
    <div class="max-w-2xl mx-auto space-y-4">
    <% if (chatList == null || chatList.isEmpty()) { %>
        <div class="flex items-center justify-center h-full py-20">
            <div class="text-center">
                <div class="w-16 h-16 bg-stone-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                    </svg>
                </div>
                <p class="text-ink-muted text-sm">还没有消息，发一条开始聊天吧</p>
            </div>
        </div>
    <% } else {
        for (Message msg : chatList) {
            boolean isMine = msg.getSenderId() == me;
            String senderInitial = msg.getSenderNickname() != null && msg.getSenderNickname().length() > 0
                ? String.valueOf(msg.getSenderNickname().charAt(0)).toUpperCase() : "?";
            String timeStr = "";
            if (msg.getCreatedAt() != null) timeStr = msg.getCreatedAt().toString().substring(0, 16);
    %>
        <% if (isMine) { %>
        <!-- 我的消息 -->
        <div class="flex gap-3 justify-end bubble-enter">
            <div class="flex flex-col gap-1 max-w-[70%] items-end">
                <div class="bg-gradient-to-r from-brand-500 to-brand-600 rounded-2xl rounded-tr-md px-4 py-3 shadow-lg shadow-brand-500/20">
                    <p class="text-sm text-white leading-relaxed"><%= msg.getContent() %></p>
                </div>
                <span class="text-xs text-ink-faint pr-2"><%= timeStr %></span>
            </div>
            <div class="w-9 h-9 bg-gradient-to-br from-accent to-orange-600 rounded-full flex items-center justify-center text-white font-display font-bold text-sm flex-shrink-0 shadow-md">
                <%= myInitial %>
            </div>
        </div>
        <% } else { %>
        <!-- 对方消息 -->
        <div class="flex gap-3 bubble-enter">
            <div class="w-9 h-9 bg-gradient-to-br from-brand-400 to-brand-600 rounded-full flex items-center justify-center text-white font-display font-bold text-sm flex-shrink-0 shadow-md">
                <%= senderInitial %>
            </div>
            <div class="flex flex-col gap-1 max-w-[70%]">
                <div class="bg-surface-raised border border-stone-200 rounded-2xl rounded-tl-md px-4 py-3 shadow-sm">
                    <p class="text-sm text-ink-primary leading-relaxed"><%= msg.getContent() %></p>
                </div>
                <span class="text-xs text-ink-faint pl-2"><%= timeStr %></span>
            </div>
        </div>
        <% } %>
    <% } } %>
    </div>
</main>

<!-- 输入区域 -->
<footer class="bg-surface-raised border-t border-stone-200 px-4 py-4 flex-shrink-0">
    <form class="max-w-2xl mx-auto flex gap-3 items-end" method="post" action="${pageContext.request.contextPath}/messages" id="msgForm"
          onsubmit="var v=document.getElementById('msgInput').value.trim(); if(!v){alert('消息内容不能为空');return false;}">
        <% if (conversationId != null) { %>
            <input type="hidden" name="conversationId" value="<%= conversationId %>">
        <% } %>
        <input type="hidden" name="receiverId" value="<%= otherId %>">
        <% if (productId != null) { %>
            <input type="hidden" name="productId" value="<%= productId %>">
        <% } %>
        <div class="flex-1 relative">
            <textarea
                name="content"
                id="msgInput"
                placeholder="输入消息..."
                rows="1"
                class="w-full px-4 py-3 bg-surface-DEFAULT border border-stone-200 rounded-xl text-sm text-ink-primary placeholder:text-ink-faint resize-none input-glow focus:border-brand-500 transition-all outline-none"
                style="min-height: 48px; max-height: 120px;"
                onkeydown="handleKey(event)"
            ></textarea>
        </div>
        <button
            type="submit"
            class="px-6 py-3 bg-gradient-to-r from-brand-500 to-brand-600 text-white font-display font-semibold rounded-xl hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/25 flex items-center gap-2"
        >
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="22" y1="2" x2="11" y2="13"/>
                <polygon points="22 2 15 22 11 13 2 9 22 2"/>
            </svg>
            <span class="hidden sm:inline">发送</span>
        </button>
    </form>
    <p class="text-xs text-ink-faint text-center mt-2 max-w-2xl mx-auto">按 Enter 发送，Shift + Enter 换行</p>
</footer>

<script>
// 滚动到底部
(function() { var b = document.getElementById('chatBody'); if (b) b.scrollTop = b.scrollHeight; })();

// Enter发送，Shift+Enter换行
function handleKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        if (!document.getElementById('msgInput').value.trim()) { alert('消息内容不能为空'); return; }
        document.getElementById('msgForm').submit();
    }
}

// 自动调整输入框高度
var textarea = document.getElementById('msgInput');
textarea.addEventListener('input', function() {
    this.style.height = 'auto';
    this.style.height = Math.min(this.scrollHeight, 120) + 'px';
});

// 半实时刷新：每5秒拉取新消息
var lastMessageCount = <%= chatList != null ? chatList.size() : 0 %>;
var chatBody = document.getElementById('chatBody');
var currentUrl = window.location.href;

function checkNewMessages() {
    fetch(currentUrl, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    .then(function(response) { return response.text(); })
    .then(function(html) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        var newChatBody = doc.getElementById('chatBody');
        if (newChatBody) {
            var newMessages = newChatBody.querySelectorAll('.bubble-enter');
            if (newMessages.length > lastMessageCount) {
                chatBody.innerHTML = newChatBody.innerHTML;
                lastMessageCount = newMessages.length;
                chatBody.scrollTop = chatBody.scrollHeight;
            }
        }
    })
    .catch(function() {});
}

// 每5秒检查一次新消息
setInterval(checkNewMessages, 5000);
</script>

</body>
</html>
