---
layout: page
title: Home
---

## Areas

{% for area in site.data.areas %}
<div style="text-align: center;">
  <a href='{{ site.base_url | append: area.name | append: ".html"}}'>{{ area.title }}</a>
</div>
{% endfor %}

