

with base as (
  select
    date_trunc('day', o.order_ts)                   as order_date,
    sum(oi.qty * oi.unit_price)               as daily_revenue,
    count(distinct o.order_id)                as orders
  from DEMO.ANALYTICS.stg_orders o
  left join DEMO.ANALYTICS.stg_order_items oi
    on oi.order_id = o.order_id
  
    where o.order_ts between '2024-03-01' and '2024-03-31'
  
  group by 1
)
select * from base


  where order_date >
    (select coalesce(max(order_date), '1900-01-01') from DEMO.ANALYTICS.fct_orders_daily)
