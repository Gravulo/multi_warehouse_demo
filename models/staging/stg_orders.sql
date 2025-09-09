{{ config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='ignore'
) }}

with src as (
  select * from {{ source('analytics','raw_orders') }}
)

select
  cast(order_id as integer)          as order_id,
  cast(user_id as integer)           as user_id,
  cast(order_ts as timestamp)        as order_ts,
  status
from src
{% if is_incremental() %}
  where order_ts > (select coalesce(max(order_ts), '1900-01-01') from {{ this }})
{% endif %}

-- Optional bounded window using vars
{% if var('run_start') and var('run_end') %}
  and order_ts between '{{ var("run_start") }}' and '{{ var("run_end") }}'
{% endif %}
