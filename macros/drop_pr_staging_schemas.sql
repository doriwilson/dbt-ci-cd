{%- macro drop_pr_schemas() -%}
  {# Use the active target #}
  {% set db = target.database %}
  {% set sch = target.schema %}

  {% do log("drop_pr_schemas: requested drop of target schema", info=true) %}
  {% do log("  target.name     = " ~ target.name, info=true) %}
  {% do log("  target.database = " ~ db, info=true) %}
  {% do log("  target.schema   = " ~ sch, info=true) %}

  {# Fallback if database isnt set in the target #}
  {% if not db %}
    {% do log("No target.database set; fetching current_database() …", info=true) %}
    {% if execute %}
      {% set r = run_query("select current_database()") %}
      {% set db = r.columns[0].values()[0] if r else None %}
      {% do log("Resolved database = " ~ db, info=true) %}
    {% endif %}
  {% endif %}

  {% if not db or not sch %}
    {% do log("Missing database or schema; nothing to drop.", info=true) %}
    {% do return(none) %}
  {% endif %}

  {# Check existence in INFORMATION_SCHEMA #}
  {% set exists_sql %}
    select count(*) as cnt
    from {{ adapter.quote(db) }}.information_schema.schemata
    where schema_name = upper('{{ sch }}')
  {% endset %}

  {% do log("Existence check SQL:\n" ~ exists_sql, info=true) %}

  {% if execute %}
    {% set res = run_query(exists_sql) %}
    {% set cnt = (res.columns[0].values()[0]) | int %}
  {% else %}
    {% set cnt = 1 %}
  {% endif %}

  {% if cnt > 0 %}
    {% set fq_schema = adapter.quote(db) ~ '.' ~ adapter.quote(sch) %}
    {% set drop_sql = 'drop schema if exists ' ~ fq_schema ~ ' cascade' %}
    {% do log("Dropping schema: " ~ fq_schema, info=true) %}
    {% do log("DROP SQL:\n" ~ drop_sql, info=true) %}
    {% do run_query(drop_sql) %}
  {% else %}
    {% do log("Schema " ~ db ~ "." ~ sch ~ " not found; nothing to drop.", info=true) %}
  {% endif %}
{%- endmacro -%}
