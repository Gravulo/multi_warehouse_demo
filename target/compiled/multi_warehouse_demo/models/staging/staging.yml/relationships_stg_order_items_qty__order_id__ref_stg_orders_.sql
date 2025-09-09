
    
    

with child as (
    select qty as from_field
    from DEMO.ANALYTICS.stg_order_items
    where qty is not null
),

parent as (
    select order_id as to_field
    from DEMO.ANALYTICS.stg_orders
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


