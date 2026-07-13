{#- update with relevant schema to generate source details -#}
{%- set source_schema = 'jaffle_shop' -%}

{{ codegen.generate_source(
    database_name=var('source_db'),
    schema_name=source_schema,
    generate_columns=True) 
}}