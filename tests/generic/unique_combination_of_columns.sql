{% test unique_combination_of_columns(model, combination_of_columns) %}
with duplicates as (
    select
        {% for column in combination_of_columns -%}
            {{ column }}{% if not loop.last %}, {% endif %}
        {%- endfor %}
    from {{ model }}
    group by
        {% for column in combination_of_columns -%}
            {{ column }}{% if not loop.last %}, {% endif %}
        {%- endfor %}
    having count(*) > 1
)
select *
from duplicates
{% endtest %}
