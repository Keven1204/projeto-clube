{% macro deduplicate(relation, partition_by, order_by) %}
    select *
    from (
        select
            source_rows.*,
            row_number() over (
                partition by {{ partition_by }}
                order by {{ order_by }}
            ) as _row_number
        from {{ relation }} as source_rows
    ) as ranked
    where ranked._row_number = 1
{% endmacro %}
