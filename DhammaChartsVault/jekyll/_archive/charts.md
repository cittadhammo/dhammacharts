---
layout: default
title: Chart
---
<h1>Charts</h1>

## top right menu

{% assign pages = site.Charts | where_exp: "item", "item.layout != 'chart'" %}
{% for page in pages %}
    {{ page.title }} and {{ page.url }}
{% endfor %}

---

## Charts List

{% include list.html collection = "charts" %}
