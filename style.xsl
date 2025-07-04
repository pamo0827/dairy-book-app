<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd" />

<xsl:param name="keyword"/>
<xsl:param name="mode"/>

<xsl:template match="/">
    <html>
    <head>
        <meta charset="UTF-8"/>
        <title>読書おみくじ - 結果</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
        <link href="https://fonts.googleapis.com/css2?family=Shippori+Mincho:wght@400;700&amp;display=swap" rel="stylesheet"/>
        <style>
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
                max-width: 800px;
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
                max-width: 800px;
                width: 100%;
                padding: 40px;
                background-color: #fdfaf4;
                border: 2px solid #5a4a3a;
                border-radius: 8px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
                box-sizing: border-box;
            }
            .page-header {
                text-align: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #c8bcae;
            }
            .page-header h2 {
                font-size: 2rem;
                font-weight: 700;
                margin: 0 0 20px 0;
            }
            .search-form { display: flex; gap: 12px; margin-bottom: 24px; }
            .search-box { flex-grow: 1; font-family: 'Shippori Mincho', serif; font-size: 1rem; padding: 10px 16px; border: 2px solid #c8bcae; border-radius: 6px; background-color: #fff; outline: none; transition: border-color 0.2s ease, box-shadow 0.2s ease; }
            .search-box:focus { border-color: #8a6e58; box-shadow: 0 0 0 3px rgba(138, 110, 88, 0.2); }
            .search-button { font-family: 'Shippori Mincho', serif; font-weight: 700; font-size: 1rem; color: #fdfaf4; background-color: #a13333; border: none; border-radius: 6px; padding: 10px 24px; cursor: pointer; transition: background-color 0.2s ease; }
            .search-button:hover { background-color: #8b2b2b; }
            .results {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                gap: 24px;
            }
            .book-card-link {
                text-decoration: none;
                color: inherit;
                display: block;
            }
            .book-card {
                background-color: #fff;
                border: 1px solid #c8bcae;
                border-radius: 6px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                display: flex;
                flex-direction: column;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                height: 100%;
            }
            .book-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
            }
            .book-info {
                padding: 16px;
                flex-grow: 1;
                display: flex;
                flex-direction: column;
                text-align: left;
            }
            .book-title {
                font-size: 1.1rem;
                font-weight: 700;
                margin: 0 0 4px 0;
            }
            .book-creator {
                font-size: 0.9rem;
                color: #6a5a4a;
                margin: 0 0 8px 0;
            }
            .book-description {
                font-size: 0.85rem;
                line-height: 1.6;
                color: #6a5a4a;
                margin: 0 0 12px 0;
                flex-grow: 1;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-line-clamp: 3;
                -webkit-box-orient: vertical;
            }
            .favorite-btn {
                font-family: 'Shippori Mincho', serif;
                font-weight: 700;
                font-size: 0.9rem;
                color: #a13333;
                background-color: transparent;
                border: 2px solid #a13333;
                border-radius: 6px;
                padding: 8px 16px;
                cursor: pointer;
                transition: background-color 0.2s ease, color 0.2s ease;
                margin-top: 16px;
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
        </style>
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                document.querySelectorAll('.favorite-btn').forEach(button => {
                    button.addEventListener('click', async (event) => {
                        event.preventDefault();
                        event.stopPropagation();
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
            <xsl:apply-templates select="selected-books"/>
        </main>
    </body>
    </html>
</xsl:template>

<!-- ヘッダーと結果コンテナを生成 -->
<xsl:template match="selected-books">
    <header class="page-header">
        <h2>
            <xsl:choose>
                <xsl:when test="$mode = 'favorites'">📖 お気に入り帳</xsl:when>
                <xsl:when test="$mode = 'list_all'">📖 書籍一覧</xsl:when>
                <xsl:when test="$keyword != ''">「<xsl:value-of select="$keyword"/>」の検索結果</xsl:when>
                <xsl:otherwise>今日のあなたへのおすすめ</xsl:otherwise>
            </xsl:choose>
        </h2>
        <!-- Add search form to result page -->
        <form action="gacha_cgi.rb" method="get" class="search-form" accept-charset="UTF-8">
            <input type="text" name="keyword" class="search-box" placeholder="キーワードで再検索...">
                <xsl:attribute name="value"><xsl:value-of select="$keyword"/></xsl:attribute>
            </input>
            <button type="submit" class="search-button">再検索</button>
        </form>
    </header>
    <div class="results">
        <xsl:apply-templates select="item"/>
    </div>
</xsl:template>

<!-- 各書籍のカードを生成 -->
<xsl:template match="item">
    <a class="book-card-link" href="gacha_cgi.rb?mode=detail&amp;isbn={isbn}">
        <div class="book-card">
            <div class="book-info">
                <h2 class="book-title"><xsl:value-of select="title"/></h2>
                <p class="book-creator"><xsl:value-of select="creator"/></p>
                <p class="book-description"><xsl:value-of select="description"/></p>
                <button class="favorite-btn" data-isbn="{isbn}">
                    <xsl:if test="@favorited = 'true'">
                        <xsl:attribute name="class">favorite-btn favorited</xsl:attribute>
                    </xsl:if>
                    <span class="icon"><xsl:choose><xsl:when test="@favorited = 'true'">★</xsl:when><xsl:otherwise>☆</xsl:otherwise></xsl:choose></span>
                    <span class="text"><xsl:choose><xsl:when test="@favorited = 'true'">お気に入り解除</xsl:when><xsl:otherwise>お気に入り登録</xsl:otherwise></xsl:choose></span>
                </button>
            </div>
        </div>
    </a>
</xsl:template>

</xsl:stylesheet>