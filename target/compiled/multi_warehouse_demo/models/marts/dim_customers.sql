select
  u.user_id,
  u.email,
  u.country,
  min(o.order_ts)                                    as first_order_ts,
  max(o.order_ts)                                    as last_order_ts,
  count(case when o.status='completed' then 1 end)   as completed_orders
from DEMO.ANALYTICS.stg_users u
left join DEMO.ANALYTICS.stg_orders o
  on o.user_id = u.user_id
group by 1,2,3