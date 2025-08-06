---
layout: home
title: Home
---

<h1 class="cover-title" > DhammaCharts </h1>
 
<img class= "cover" src="{{ site.baseurl }}/assets/icons/logo.png" alt="Cover">

{% for area in site.data.areas %}
<div style="text-align: center;">
  <a href='{{ site.baseurl | append: "/" | append: area.name | append: ".html"}}'>{{ area.title }}</a>
</div>
{% endfor %}

