---
layout: default
title: Home
---
## playing with data

{{ site.data.categories | inspect }}

{{ site.data.categories2 | inspect }}

---

{% for cat in site.data.categories %}

{{ cat | inspect }}

{% endfor %}

---

## Structure

{% for area in site.data.areas %}
    
Area is: {{ area.label }} with id: {{ area.id }}  

    {% for category in area.categories %}
    
`|`---> category is: {{ category.label }} with id: {{ category.id }} {{ item.url }}
    
        {% assign items = site[area.id] | where: "category", category.id %}

        {% for item in items %}

`|`------> title: {{ item.title | inspect }} with category: {{ item.category | inspect }} {{ item.url }}
        
        {% endfor %}

    {% endfor %}

    {% assign pages = site[area.id] | where: "category", nil %}

    {% for page in pages %}

`|`---> pages: {{ page.title | inspect }} {{ page.url }}
        
    {% endfor %}
{% endfor %}

## The rest

<h1>{{ "Hello World!" | downcase }}</h1>

{% for page in site.pages %}
    {{ page.title }} at {{ page.path | split: '/'}} with {{ page.collection }}
    
{% endfor %}

Here are the charts !
cat : {{ site.data.categories.charts }}

{% assign all_categories = site.charts | map: "category" | uniq %}

all : {{ all_categories }}

---

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

Do not use data, do not use frontmatter 

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

