{%- macro drop_pr_schemas(database, schema_prefix, pr_number) -%}

  {# List schemas in the given DATABASE that follow your PR pattern #}
  {% set list_sql %}
    select schema_name
    from {{ database }}.information_schema.schemata
    where schema_name ilike '{{ schema_prefix }}_%{{ pr_number }}__%'
  {% endset %}

  {% do log(list_sql, info=true) %}

  {% if execute %}
    {% set res = run_query(list_sql) %}
    {% set schemas = res.columns[0].values() if res else [] %}
  {% else %}
    {% set schemas = [] %}
  {% endif %}

  {% if schemas and schemas | length > 0 %}
    {% for s in schemas %}
      {# Build a fully-qualified, quoted identifier: DATABASE."SCHEMA" #}
      {% set fq_schema = adapter.quote(database) ~ '.' ~ adapter.quote(s) %}
      {% set drop_sql = 'drop schema if exists ' ~ fq_schema ~ ' cascade' %}
      {% do log(drop_sql, info=true) %}
      {% do run_query(drop_sql) %}
    {% endfor %}
  {% else %}
    {% do log('No schemas to drop.', info=true) %}
  {% endif %}

{%- endmacro -%}
