{% macro normalize_text(column_name) %}
    nullif(upper(trim({{ column_name }}::text)), '')
{% endmacro %}
