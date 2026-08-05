{% macro generate_schema_name(custom_schema_name, node) -%}

    {#-
        Behavior:
        - In the "ci" target, when DBT_PR_SCHEMA is set (PR builds), every
          model lands in that single ephemeral schema, e.g. PR_123_JDOE,
          regardless of any custom schema config in the model.
        - Otherwise, fall back to standard dbt behavior: target schema,
          optionally suffixed with the model's custom schema.
    -#}

    {%- set default_schema = target.schema -%}
    {%- set pr_schema = env_var('DBT_PR_SCHEMA', '') -%}

    {%- if target.name == 'ci' and pr_schema != '' -%}
        {{ pr_schema | trim }}

    {%- elif custom_schema_name is none -%}
        {{ default_schema }}

    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
