<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd" />

<!-- CGIスクリプトから渡されるパラメータ -->
<xsl:param name="keyword"/>
<xsl:param name="mode"/>

<!-- メインテンプレート: HTMLの骨格を生成 -->
<xsl:template match="/">
    <html>
    <head>
        <meta charset="UTF-8"/>
        <title>読書おみくじ - 書籍詳細</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
        <link href="https://fonts.googleapis.com/css2?family=Shippori+Mincho:wght@400;700&amp;display=swap" rel="stylesheet"/>
        <style>
            /* --- お寺・おみくじ風テーマ --- */
            body {
                font-family: 'Shippori Mincho', serif;
                background-color: #6d5a48;
                background-image: linear-gradient(45deg, rgba(0,0,0,0.05) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.05) 50%, rgba(0,0,0,0.05) 75%, transparent 75%, transparent);
                background-size: 50px 50px;
                color: #3a2e25;
                margin: 0;
                padding: 20px;
                min-height: 100vh;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            .site-header {
                width: 100%;
                max-width: 900px;
                padding: 10px 0 20px 0;
                text-align: center;
            }
            .site-header h1 {
                font-size: 2.5rem;
                font-weight: 700;
                color: #fdfaf4;
                text-shadow: 0 2px 4px rgba(0,0,0,0.5);
                margin: 0 0 15px 0;
            }
            .site-nav a {
                font-family: 'Shippori Mincho', serif;
                font-weight: 700;
                color: #fdfaf4;
                text-decoration: none;
                margin: 0 15px;
                padding: 5px 10px;
                border-bottom: 2px solid transparent;
                transition: border-color 0.2s ease;
            }
            .site-nav a:hover {
                border-bottom-color: #fdfaf4;
            }
            .container {
                max-width: 900px;
                width: 100%;
                padding: 40px;
                background-color: #fdfaf4;
                border: 2px solid #5a4a3a;
                border-radius: 8px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
                box-sizing: border-box;
            }
            .detail-wrapper {
                text-align: left;
            }
            .detail-title {
                font-size: 2.2rem;
                font-weight: 700;
                margin: 0 0 8px 0;
            }
            .detail-creator {
                font-size: 1.2rem;
                color: #6a5a4a;
                margin: 0 0 24px 0;
            }
            .detail-meta {
                display: grid;
                grid-template-columns: auto 1fr;
                gap: 8px 16px;
                margin-bottom: 24px;
                color: #6a5a4a;
            }
            .detail-meta .label {
                font-weight: 700;
                color: #3a2e25;
            }
            .detail-description {
                font-size: 1rem;
                line-height: 1.8;
                margin: 0 0 24px 0;
                flex-grow: 1;
                white-space: pre-wrap; /* 改行を反映 */
            }
            .favorite-btn {
                font-family: 'Shippori Mincho', serif;
                font-weight: 700;
                font-size: 1rem;
                color: #a13333;
                background-color: transparent;
                border: 2px solid #a13333;
                border-radius: 6px;
                padding: 10px 20px;
                cursor: pointer;
                transition: background-color 0.2s ease, color 0.2s ease;
                align-self: flex-start;
            }
            .favorite-btn:hover {
                background-color: #a13333;
                color: #fdfaf4;
            }
            .favorite-btn.favorited {
                background-color: #8a6e58;
                border-color: #8a6e58;
                color: #fdfaf4;
            }
            .page-footer {
                text-align: center;
                margin-top: 40px;
                padding-top: 30px;
                border-top: 2px solid #c8bcae;
            }
            .page-footer a {
                font-family: 'Shippori Mincho', serif;
                font-weight: 700;
                text-decoration: none;
                padding: 10px 24px;
                border-radius: 6px;
                margin: 0 10px;
                transition: background-color 0.2s ease;
            }
            .page-footer a.primary {
                color: #fdfaf4;
                background-color: #a13333;
            }
            .page-footer a.primary:hover {
                background-color: #8b2b2b;
            }
            .page-footer a.secondary {
                color: #3a2e25;
                background-color: #fff;
                border: 2px solid #c8bcae;
            }
            .page-footer a.secondary:hover {
                background-color: #f4f1ea;
            }
        </style>
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                document.querySelectorAll('.favorite-btn').forEach(button => {
                    button.addEventListener('click', async () => {
                        const isbn = button.dataset.isbn;
                        const isFavorited = button.classList.contains('favorited');
                        const mode = isFavorited ? 'remove_favorite' : 'add_favorite';
                        const url = `gacha_cgi.rb?mode=${mode}&amp;isbn=${isbn}`;

                        try {
                            const response = await fetch(url);
                            if (response.ok) {
                                button.classList.toggle('favorited');
                                const icon = button.querySelector('.icon');
                                const text = button.querySelector('.text');
                                if (button.classList.contains('favorited')) {
                                    icon.textContent = '★';
                                    text.textContent = 'お気に入り解除';
                                } else {
                                    icon.textContent = '☆';
                                    text.textContent = 'お気に入り登録';
                                }
                            } else {
                                alert('お気に入りの更新に失敗しました。');
                            }
                        } catch (error) {
                            alert('通信エラーが発生しました。');
                        }
                    });
                });
            });
        </script>
    </head>
    <body>
        <header class="site-header">
            <h1>📜 今日の読書おみくじ</h1>
            <nav class="site-nav">
                <a href="index.html">トップ</a>
                <a href="gacha_cgi.rb?mode=list_all">書籍一覧</a>
                <a href="gacha_cgi.rb?mode=favorites">お気に入り帳</a>
            </nav>
        </header>
        <main class="container">
            <xsl:apply-templates select="selected-books/item"/>
        </main>
    </body>
    </html>
</xsl:template>

<!-- 書籍詳細のメインコンテンツを生成 -->
<xsl:template match="item">
    <xsl:if test="not(node())">
        <p>指定された書籍が見つかりませんでした。</p>
    </xsl:if>
    <div class="detail-wrapper">
        <h1 class="detail-title"><xsl:value-of select="title"/></h1>
        <p class="detail-creator"><xsl:value-of select="creator"/></p>
        <div class="detail-meta">
            <span class="label">出版社</span>
            <span><xsl:value-of select="publisher"/></span>
            <span class="label">価格</span>
            <span><xsl:value-of select="price"/> 円</span>
            <span class="label">ISBN</span>
            <span><xsl:value-of select="isbn"/></span>
        </div>
        <p class="detail-description"><xsl:value-of select="description"/></p>
        <button class="favorite-btn" data-isbn="{isbn}">
            <xsl:if test="@favorited = 'true'">
                <xsl:attribute name="class">favorite-btn favorited</xsl:attribute>
            </xsl:if>
            <span class="icon"><xsl:choose><xsl:when test="@favorited = 'true'">★</xsl:when><xsl:otherwise>☆</xsl:otherwise></choose></span>
            <span class="text"><xsl:choose><xsl:when test="@favorited = 'true'">お気に入り解除</xsl:when><xsl:otherwise>お気に入り登録</xsl:otherwise></choose></span>
        </button>
    </div>
</xsl:template>

</xsl:stylesheet>