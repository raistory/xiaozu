<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布商品 - 民大二手交易平台</title>
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
        .input-focus-ring:focus { outline: none; box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.15); }
        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press { transition: none; }
            .hover-lift:hover { transform: none; }
            .btn-press:active { transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value=""/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-3xl mx-auto px-4 py-8">
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-lg overflow-hidden hover-lift">
        <!-- 卡片头部 -->
        <div class="px-8 py-6 border-b border-stone-100 bg-gradient-to-br from-brand-50 to-transparent">
            <h1 class="font-display text-xl font-bold text-ink-primary mb-1">发布商品</h1>
            <p class="text-sm text-ink-muted">填写商品基本信息后，提交即可上架到平台展示。</p>
        </div>

        <!-- 错误提示 -->
        <c:if test="${not empty errorMsg}">
            <div class="px-8 pt-4">
                <div class="bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
                    <svg class="w-5 h-5 text-red-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                    </svg>
                    <span class="text-red-700 text-sm">${errorMsg}</span>
                </div>
            </div>
        </c:if>

        <!-- 表单区 -->
        <form action="${pageContext.request.contextPath}/publish-product" method="post" enctype="multipart/form-data" class="px-8 py-6 space-y-6">
            <!-- 分段标题 -->
            <div class="flex items-center gap-2 text-brand-600 font-display font-semibold text-sm uppercase tracking-wide">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="18" height="18" rx="2"/><line x1="9" y1="3" x2="9" y2="21"/>
                </svg>
                商品信息
            </div>

            <!-- 商品标题 -->
            <div>
                <label for="title" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                    商品标题
                    <span class="text-red-500">*</span>
                </label>
                <input type="text" id="title" name="title" maxlength="120" required value="${param.title}" placeholder="例如：高等数学教材、宿舍小电扇" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                <p class="mt-2 text-xs text-ink-faint">标题尽量简洁清楚，方便别人搜索到。</p>
            </div>

            <!-- 价格行 -->
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label for="price" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                        售价
                        <span class="text-red-500">*</span>
                    </label>
                    <input type="number" id="price" name="price" step="0.01" min="0" required value="${param.price}" placeholder="请输入售价" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div>
                    <label for="originalPrice" class="text-sm font-medium text-ink-primary mb-2">原价</label>
                    <input type="number" id="originalPrice" name="originalPrice" step="0.01" min="0" value="${param.originalPrice}" placeholder="选填" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
            </div>

            <!-- 成色和分类 -->
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label for="conditionLevel" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                        商品成色
                        <span class="text-red-500">*</span>
                    </label>
                    <select id="conditionLevel" name="conditionLevel" required class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
                        <option value="">--请选择--</option>
                        <option value="NEW" <c:if test="${param.conditionLevel eq 'NEW'}">selected</c:if>>全新</option>
                        <option value="NINETY_NEW" <c:if test="${param.conditionLevel eq 'NINETY_NEW'}">selected</c:if>>九成新</option>
                        <option value="EIGHTY_NEW" <c:if test="${param.conditionLevel eq 'EIGHTY_NEW'}">selected</c:if>>八成新</option>
                        <option value="SEVENTY_NEW" <c:if test="${param.conditionLevel eq 'SEVENTY_NEW'}">selected</c:if>>七成新及以下</option>
                    </select>
                </div>
                <div>
                    <label for="categoryId" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                        商品分类
                        <span class="text-red-500">*</span>
                    </label>
                    <select id="categoryId" name="categoryId" required class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
                        <option value="">请选择分类</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}" <c:if test="${param.categoryId eq cat.categoryId.toString()}">selected</c:if>>${cat.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- 自提点选择 -->
            <div>
                <label for="pickupPointId" class="text-sm font-medium text-ink-primary mb-2 block">自提点（选填）</label>
                <select id="pickupPointId" name="pickupPointId" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
                    <option value="">不指定自提点</option>
                    <c:forEach var="pp" items="${pickupPoints}">
                        <option value="${pp.pickupPointId}" <c:if test="${param.pickupPointId eq pp.pickupPointId.toString()}">selected</c:if>>
                            ${pp.pointName}${not empty pp.campusArea ? '（'.concat(pp.campusArea).concat('）') : ''}
                        </option>
                    </c:forEach>
                </select>
                <p class="mt-2 text-xs text-ink-faint">选择自提点方便买家线下交易，也可不选。</p>
            </div>

            <!-- 商品标签 -->
            <div>
                <label class="text-sm font-medium text-ink-primary mb-2 block">商品标签</label>
                <div id="tagInputWrap" class="flex flex-wrap gap-2 px-3 py-2.5 bg-surface-raised border border-stone-200 rounded-lg min-h-[46px] items-center cursor-text transition-colors focus-within:border-brand-500 focus-within:shadow-[0_0_0_3px_rgba(34,197,94,0.15)]">
                    <span id="tagChips"></span>
                    <input type="text" id="tagText" maxlength="20" placeholder="输入标签..." class="flex-1 min-w-[80px] outline-none text-sm text-ink-primary bg-transparent placeholder:text-ink-faint">
                </div>
                <input type="hidden" name="tags" id="tagsHidden">
                <p class="mt-2 text-xs text-ink-faint">最多添加 8 个标签，按 Enter 或逗号添加</p>
            </div>

            <!-- 商品描述 -->
            <div>
                <label for="description" class="text-sm font-medium text-ink-primary mb-2">商品描述</label>
                <textarea id="description" name="description" rows="4" placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors resize-vertical">${param.description}</textarea>
                <p class="mt-2 text-xs text-ink-faint">建议写清楚：新旧程度、是否可小刀、交易地点、是否支持当面验货。</p>
            </div>

            <!-- 封面图片上传 -->
            <div>
                <label for="coverImage" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">
                    封面图片
                    <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                    <input type="file" id="coverImage" name="coverImage" accept="image/*" required class="block w-full text-sm text-ink-muted file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-brand-50 file:text-brand-600 hover:file:bg-brand-100 file:cursor-pointer file:transition-colors">
                </div>
                <p class="mt-2 text-xs text-ink-faint">用于商品列表展示，支持 jpg/png/jpeg，单张不超过 10MB。</p>
            </div>

            <!-- 详情图片上传 -->
            <div>
                <label for="detailImages" class="text-sm font-medium text-ink-primary mb-2">详情图片</label>
                <input type="file" id="detailImages" name="detailImages" accept="image/*" multiple class="block w-full text-sm text-ink-muted file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-stone-50 file:text-ink-secondary hover:file:bg-stone-100 file:cursor-pointer file:transition-colors">
                <p class="mt-2 text-xs text-ink-faint">可一次选择多张，用于详情页展示；单张不超过 10MB，总不超过 50MB。</p>
            </div>

            <!-- 额外展示图片（图片URL） -->
            <div>
                <label class="text-sm font-medium text-ink-primary mb-2">额外展示图片（图片URL）</label>
                <div class="grid grid-cols-2 gap-3">
                    <input type="text" name="imageUrl1" placeholder="图片URL 1（选填）" value="${param.imageUrl1}" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                    <input type="text" name="imageUrl2" placeholder="图片URL 2（选填）" value="${param.imageUrl2}" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                    <input type="text" name="imageUrl3" placeholder="图片URL 3（选填）" value="${param.imageUrl3}" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                    <input type="text" name="imageUrl4" placeholder="图片URL 4（选填）" value="${param.imageUrl4}" class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <p class="mt-2 text-xs text-ink-faint">可填入外部图片链接，最多 4 张，将在详情页以轮播图展示。</p>
            </div>

            <!-- 毕业季标记 -->
            <div class="flex items-center gap-3 py-3">
                <input type="checkbox" id="isGraduation" name="isGraduation" value="1" <c:if test="${param.isGraduation eq '1'}">checked</c:if> class="w-5 h-5 rounded border-stone-300 text-brand-500 focus:ring-brand-500 cursor-pointer">
                <label for="isGraduation" class="text-sm text-ink-primary cursor-pointer">
                    这是毕业季商品（将在「毕业季专区」展示）
                </label>
            </div>

            <!-- 提示框 -->
            <div class="bg-brand-50 border border-brand-200 rounded-lg px-4 py-3 text-brand-700 text-sm leading-relaxed">
                <strong>温馨提示：</strong>发布前请确认商品描述真实、价格合理，避免填写联系方式等敏感信息。
            </div>

            <!-- 按钮组 -->
            <div class="flex gap-3 pt-2">
                <button type="submit" class="flex-1 py-3 bg-brand-500 hover:bg-brand-600 text-white font-display font-semibold rounded-lg btn-press transition-colors flex items-center justify-center gap-2">
                    <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 5v14M5 12h14"/>
                    </svg>
                    立即发布
                </button>
                <a href="${pageContext.request.contextPath}/product-list" class="px-6 py-3 bg-surface-raised border border-stone-200 hover:border-stone-300 text-ink-muted hover:text-ink-primary font-medium rounded-lg flex items-center gap-2 transition-colors">
                    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="15 18 9 12 15 6"/>
                    </svg>
                    返回列表
                </a>
            </div>
        </form>
    </div>
</main>

<script>
(function() {
    var TAG_COLORS = [
        { bg: '#dbeafe', text: '#1d4ed8', border: '#93c5fd' },
        { bg: '#fce7f3', text: '#be185d', border: '#f9a8d4' },
        { bg: '#d1fae5', text: '#065f46', border: '#6ee7b7' },
        { bg: '#fef3c7', text: '#92400e', border: '#fcd34d' },
        { bg: '#ede9fe', text: '#5b21b6', border: '#c4b5fd' },
        { bg: '#ffedd5', text: '#9a3412', border: '#fdba74' }
    ];
    var MAX_TAGS = 8;
    var tags = [];
    var chipsEl = document.getElementById('tagChips');
    var hiddenEl = document.getElementById('tagsHidden');
    var textEl = document.getElementById('tagText');
    var wrapEl = document.getElementById('tagInputWrap');

    function render() {
        chipsEl.innerHTML = '';
        tags.forEach(function(t, i) {
            var c = TAG_COLORS[i % TAG_COLORS.length];
            var chip = document.createElement('span');
            chip.className = 'inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium';
            chip.style.background = c.bg;
            chip.style.color = c.text;
            chip.style.border = '1px solid ' + c.border;
            chip.textContent = t;
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.innerHTML = '&times;';
            btn.className = 'ml-0.5 hover:opacity-70';
            btn.style.color = c.text;
            btn.onclick = function() { removeTag(i); };
            chip.appendChild(btn);
            chipsEl.appendChild(chip);
        });
        hiddenEl.value = tags.join(',');
        textEl.disabled = tags.length >= MAX_TAGS;
        if (tags.length >= MAX_TAGS) {
            textEl.placeholder = '已达上限';
        } else {
            textEl.placeholder = '输入标签...';
        }
    }

    function addTag(val) {
        var t = val.trim();
        if (!t || tags.indexOf(t) >= 0 || tags.length >= MAX_TAGS) return;
        tags.push(t);
        render();
    }

    function removeTag(idx) {
        tags.splice(idx, 1);
        render();
    }

    textEl.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' || e.key === ',') {
            e.preventDefault();
            addTag(textEl.value.replace(/,/g, ''));
            textEl.value = '';
        }
        if (e.key === 'Backspace' && textEl.value === '' && tags.length > 0) {
            removeTag(tags.length - 1);
        }
    });

    textEl.addEventListener('input', function() {
        var v = textEl.value;
        if (v.indexOf(',') >= 0) {
            addTag(v.replace(/,/g, ''));
            textEl.value = '';
        }
    });

    wrapEl.addEventListener('click', function() { textEl.focus(); });

    render();
})();
</script>

</body>
</html>
