---
layout: default
title: Home
---

## Areas

{% for area in site.data.areas %}

- <a href='{{ site.base_url | append: area.name | append: ".html"}}'> {{ area.title }} </a>

{% endfor %}

