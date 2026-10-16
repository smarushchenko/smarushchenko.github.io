---
layout: default
title: "Привет, мир!"
---

# Привет, мир!

[← На главную](/)

Это статья на чистом Markdown. Браузер сам отрендерит схему Mermaid:

<pre class="mermaid">
    graph TD
        A[Чистый Markdown] --> B(Сервер GitHub)
        B --> C[Браузер читателя]
</pre>

<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ startOnLoad: true });
</script>