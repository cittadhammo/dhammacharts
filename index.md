---
layout: home
title: Home
---

## Areas

{% for area in site.data.areas %}
<div style="text-align: center;">
  <a href='{{ site.baseurl | append: "/" | append: area.name | append: ".html"}}'>{{ area.title }}</a>
</div>
{% endfor %}

