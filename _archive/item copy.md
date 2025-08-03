---
layout: page
---

{% assign area = site.data.areas | where: "name", page.collection | first %}

<a href='{{ site.base_url | append: area.name | append: ".html"}}'> {{ area.title }} </a>

<hr>

This is a item layout page.

<hr>

<h1> {{ page.title }} </h1>

{{ content }} 

<hr>

{% assign category = page.path | split: "/" | pop | last %}

- area: {{ page.collection }} <br>
- area title: {{ area.title }} <br>
- category: {{ category }} <br>

{% assign caty = area.categories | where: "name", category | first %}
- category title: {{ caty.title }}

<hr>

{% assign allItems = site[page.collection] %} 

<!-- all items with the given category based on path
(there is no way to filter the array in liquid) -->

{% assign items = "" | split: "" %}
{% for item in  allItems %}
    {% assign c = item.url | split: "/" | pop | last %}
    {% if c == category %}
        {% assign items = items | push: item  %}
    {% endif %}
{% endfor %}

<!-- looking for previous and next items according to area.categories -->

{% assign i = 0 %}
{% for item in items %}
    {% if item == page %}
        {% assign itemIndex = i %}
    {% endif %}
    {% assign i = i | plus: 1 %}
{% endfor %}

{% assign previousIndex = itemIndex | minus: 1 %}
{% assign nextIndex     = itemIndex | plus:  1 %}

{% assign cats = area.categories %}
{% assign k = 0 %}
{% for cat in cats %}
    {% if cat.name == category %}
        {% assign catIndex = k %}
    {% endif %}
    {% assign k = k | plus: 1 %}
{% endfor %}

{% assign previousCatIndex = catIndex | minus: 1 %}
{% assign nextCatIndex     = catIndex | plus:  1 %}

{% if previousIndex < 0 %}

    {% assign lastCat = cats[previousCatIndex].name  %}

    {% assign itemsLastCat = "" | split: "" %}
    {% for item in allItems %}
        {% assign c = item.url | split: "/" | pop | last %}
        {% if c == lastCat %}
            {% assign itemsLastCat = itemsLastCat | push: item  %}
        {% endif %}
    {% endfor %}
    
    {% assign lastItem = itemsLastCat | last %}
<!-- previous in previous cat with round
    <a href="{{ lastItem.url }}">{{ lastItem.title }}</a>  
    <br>
-->

    {% if previousCatIndex < 0 %}
        
<!-- previous in previous cat: You are on the first item of the first cat <br> -->
    
    {% else %}
        
        {% assign lastCat = cats[previousCatIndex].name  %}

        {% assign itemsLastCat = "" | split: "" %}
        {% for item in allItems %}
            {% assign c = item.url | split: "/" | pop | last %}
            {% if c == lastCat %}
                {% assign itemsLastCat = itemsLastCat | push: item  %}
            {% endif %}
        {% endfor %}

        {% assign lastItem = itemsLastCat | last %}
        <a href="{{ lastItem.url }}"> Previous: {{ lastItem.title }}</a> 
<!-- previous in previous cat --><br>

    {% endif %}

{% else %}

    <a href="{{ items[previousIndex].url }}"> Previous: {{ items[previousIndex].title }}</a>
<!-- previous --><br>

{% endif %}

{% if nextIndex == items.size  %}

    {% if nextCatIndex == cats.size  %}

<!-- next in next cat: You are on the last item of the last cat <br> -->

    {% else %}

        {% assign nextCat = cats[nextCatIndex].name  %}

        {% assign itemsNextCat = "" | split: "" %}
        {% for item in allItems %}
            {% assign c = item.url | split: "/" | pop | last %}
            {% if c == nextCat %}
                {% assign itemsNextCat = itemsNextCat | push: item  %}
            {% endif %}
        {% endfor %}

        {% assign firstItem = itemsNextCat | first %}
        <a href="{{ firstItem.url }}"> Next: {{ firstItem.title }}</a> 
<!-- next in next cat --> <br>

    {% endif %}

    {% if nextCatIndex == cats.size %}
        {% assign nextCatIndex = 0 %}
    {% endif %}

    {% assign nextCat = cats[nextCatIndex].name  %}

    {% assign itemsNextCat = "" | split: "" %}
    {% for item in allItems %}
        {% assign c = item.url | split: "/" | pop | last %}
        {% if c == nextCat %}
            {% assign itemsNextCat = itemsNextCat | push: item  %}
        {% endif %}
    {% endfor %}

    {% assign firstItem = itemsNextCat | first %}
    
<!-- next in next cat with round
    <a href="{{ firstItem.url }}">{{ firstItem.title }}</a> 
    <br>
-->

{% else %}

    <a href="{{ items[nextIndex].url }}"> Next: {{ items[nextIndex].title }}</a> 
<!-- next --> <br>

{% endif %}

