---
layout: default
---

{% assign area = site.data.areas | where: "name", page.collection | first %}

<a href="{{ site.base_url | append: area.name | append: ".html"}}"> {{ area.title }} </a>

<hr>

This is a item layout page - collection: {{ page.collection }} - area name: {{ area.title }}

<hr>

<h1> {{ page.title }} </h1>

{{ content }} 

<hr>
<hr>
<hr>

{% assign path = page.path | split: "/" %}
{% assign category = path[-2] %}
page category from path: {{ category | inspect }} <br>

{% assign itemNames = site[page.collection] | map: "name" %}
{% assign itemUrls = site[page.collection] | map: "url" %}
Item Names: <pre> {{ itemNames | inspect }} </pre> <br>
Item urls: <pre> {{ itemUrls | inspect }}  </pre>  <br>

{% assign itemx = "" | split: "" %}
{% for i in (1..itemNames.size) %}
    
    {% assign itemx = itemx | push: itemNames[i] %}
{% endfor %}
itemx: {{ itemx | inspect }} <br>

{% assign allItems = site[page.collection] %} 

<hr>
<hr>
<hr>


{% assign items = "" | split: "" %}
{% for item in  allItems %}
-> {{ item | first | inspect }} <br>
    {% assign c = item.url | split: "/" | pop | last %}
--> {{ c | inspect }} <br>
    {% if c == category %}
        {% assign items = items | push: item  %}
    {% endif %}
{% endfor %}
 <pre>
items: {{ items | first | shift | first | inspect }}
</pre>


<hr>
<hr>
<hr>

items size in this category: {{ items.size | inspect }} <br>

{% assign i = 0 %}
{% for item in items %}
    {% if item == page %}
        {% assign itemIndex = i %}
    {% endif %}
    {% assign i = i | plus: 1 %}
{% endfor %}

{% assign previousIndex = itemIndex | minus: 1 %}
{% assign nextIndex     = itemIndex | plus:  1 %}

itemIndex: {{ itemIndex }} <br>
Size: {{ items.size }} <br>

previous index: {{ previousIndex }} <br>
previous item:  {{ items[previousIndex].name | inspect }} <br>
next item:      {{ items[nextIndex].name | inspect }} <br>

<hr>
<hr>
<hr>

{% assign cats = area.categories %}
other cats in this area: {{ cats | inspect }} <br>
{% assign k = 0 %}
{% for cat in cats %}
    {% if cat.name == category %}
        {% assign catIndex = k %}
    {% endif %}
    {% assign k = k | plus: 1 %}
{% endfor %}

{% assign previousCatIndex = catIndex | minus: 1 %}
{% assign nextCatIndex     = catIndex | plus:  1 %}
catIndex:     {{ catIndex }} <br>
catSize:      {{ cats.size }} <br>
previous cat: {{ cats[previousCatIndex].name }} <br>
next cat:     {{ cats[nextCatIndex].name }} <br>

<hr>
<hr>
<hr>

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
    previous in previous cat with round: {{ lastItem.name | inspect }} <br>

    {% if previousCatIndex < 0 %}
        
        previous in previous cat: You are on the first item of the first cat <br>
    
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
        previous in previous cat: {{ lastItem.name | inspect }} <br>

    {% endif %}

{% else %}

    previous: {{ items[previousIndex].name }} <br>

{% endif %}

{% if nextIndex == items.size  %}

    {% if nextCatIndex == cats.size  %}

        next in next cat: You are on the last item of the last cat <br>

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
        next in next cat: {{ firstItem.name | inspect }} <br>

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
    next in next cat with round: {{ firstItem.name | inspect }} <br>

{% else %}

    next: {{ items[nextIndex].name }} <br>

{% endif %}


<hr>
<hr>
<hr>

This is next: {{ page.next.title }} <br>
This is previous: {{ page.previous.title }} <br> <br>

{{ site.charts | inspect }} <br> <br>
{{ area | inspect }} <br> <br>

<pre>
{{ site[page.collection] | first | inspect }}
</pre>