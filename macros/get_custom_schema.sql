{% macro generate_schema_name(custom_schema_name, node) -%}

    {#-
        Behavior:
        - When DBT_PR_SCHEMA is set (dev PR builds), every model lands in
          that single ephemeral schema, e.g. PR_123_JDOE, regardless of any
          custom schema config in the model.
        - Otherwise, a model's custom schema config (e.g. `schema: marts`)
          is used AS-IS — no target-schema prefix concatenation. The
          environment is already distinguished by database (PROD_DB /
          STAGING_DB / DEV_DB), so re-encoding it into the schema name too
          just produces drift like PROD_MARTS vs MARTS vs PUBLIC_MARTS
          depending on who/what ran the build.
        - A model with NO custom schema config still falls back to
          target.schema, unchanged.
    -#}

    {%- set pr_schema = env_var('DBT_PR_SCHEMA', '') -%}

    {%- if pr_schema != '' -%}
        {{ pr_schema | trim }}

    {%- elif custom_schema_name is none -%}
        {{ target.schema }}

    {%- else -%}
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}