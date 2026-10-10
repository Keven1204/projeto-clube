{% macro signed_by_operation(operation_column, value_expression) %}
    case
        when {{ operation_column }} = 'BUY' then ({{ value_expression }})
        when {{ operation_column }} = 'SELL' then -1 * ({{ value_expression }})
    end
{% endmacro %}
