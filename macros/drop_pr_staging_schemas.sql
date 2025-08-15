{%- macro drop_pr_schemas() -%}
  {% set db = target.database %}
  {% set sch = target.schema %}

  {% do log("Dropping schema: " ~ db ~ "." ~ sch, info=true) %}

  {% set drop_sql = 'drop schema if exists ' ~ adapter.quote(db) ~ '.' ~ adapter.quote(sch) ~ ' cascade' %}
  {% do log("DROP SQL: " ~ drop_sql, info=true) %}

  {% do run_query(drop_sql) %}
{%- endmacro -%}
