<nav>
    {% for page in site.pages %}
        <a href={{page.url}}> {{page.title}} </a> </br>
    {% endfor %} 
</nav>
