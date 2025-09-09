{{ config(
    materialized='incremental',
    unique_key='order_date',
    on_schema_change='ignore'
) }}

with base as (
  select
    {{ day('o.order_ts') }}                   as order_date,
    sum(oi.qty * oi.unit_price)               as daily_revenue,
    count(distinct o.order_id)                as orders
  from {{ ref('stg_orders') }} o
  left join {{ ref('stg_order_items') }} oi
    on oi.order_id = o.order_id
  {% if var('run_start') and var('run_end') %}
    where o.order_ts between '{{ var("run_start") }}' and '{{ var("run_end") }}'
  {% endif %}
  group by 1
)
select * from base

{% if is_incremental() %}
  where order_date >
    (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}
