select
  o.order_id,
  o.user_id,
  o.order_ts,
  o.status,
  sum(oi.qty * oi.unit_price) as order_amount
from {{ ref('stg_orders') }} o
left join {{ ref('stg_order_items') }} oi
  on oi.order_id = o.order_id
group by 1,2,3,4
