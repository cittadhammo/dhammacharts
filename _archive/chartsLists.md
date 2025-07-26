---
layout: default
title: Chart
---
<h1>Charts</h1>

top right menu

{% assign pages = site.charts | where_exp: "item", "item.layout != 'chart'" %}
{% for page in pages %}
    {{ page.title }} and {{ page.url }}
{% endfor %}

---

Use folder to order categories and parent folder to assign
{% assign cats = "" | split: ""  %}
{% assign chartPaths = site.charts | where: "layout", "chart" | map: "url" %}
    {% for item in chartPaths %}
        {% assign splitUrl = item | split: "/" %}
        {% assign cats = cats | push: splitUrl[2] %}
    {% endfor %}
{% assign cats = cats | uniq %}
categories extracted from folder structure: {{ cats | inspect }} 

{% for category in cats %}
In the {{ category }}, there is :
    {% assign items = site.charts | where: "layout", "chart" %}
    {% for item in items %}
        {%- assign parents = item.url | split: "/" -%} 
        {%- if parents[2] == category -%}
            {{ item.title }} : {{ item.url }}
        {% endif %}
    {% endfor %}
{% endfor %}

---

Do not use data, do not use frontmatter 

{% assign all_categories = site.charts | map: "category" | uniq %}
{% for category in all_categories %}
In the {{ category }}, there is :
    {% assign items = site.charts | where: "layout", "chart" %}
    {% for item in items %}
        {% assign parents = item.url | split: "/" %} 
        {% assign oneBeforeLast = parents.size | minus: 2 %}
        {% if parents[2] == category %}
            {{ item.title }}
        {% endif %}
    {% endfor %}
{% endfor %}

---

Use data and frontmatter category

{% for category in site.data.categories.charts %}
In the {{ category }}, there is :
    {% assign items = site.charts | where: "category", category | where: "layout", "chart" %}
    {% for item in items %}
        {{ item.title }}
    {% endfor %}
{% endfor %}

---

Use data to order categories and parent folder to assign

{% for category in site.data.categories.charts %}
In the {{ category }}, there is :
    {% assign items = site.charts | where: "layout", "chart" %}
    {% for item in items %}
        {%- assign parents = item.url | split: "/" -%} 
        {%- assign oneBeforeLast = parents.size | minus: 2 -%}
        {% comment %}
        direct parent is : {{ parents[oneBeforeLast] }}
        type is : {{ parents[1] }}
        first cat  is : {{ parents[2] }}
        {% endcomment %}
        {%- if parents[2] == category -%}
            {{ item.title }}
        {% endif %}
    {% endfor %}
{% endfor %}

---

