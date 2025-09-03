{{
  config(
    materialized='table'
  )
}}

with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_metrics as (
    select
        customer_id,
        count(*) as total_orders,
        sum(order_total) as sum_revenue,
        sum(total_amount - discount_amount) as sum_net_revenue,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from {{ ref('fct_orders') }}
    group by customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.address,
    c.city,
    c.state,
    c.zip_code,
    c.country,
    c.created_at,
    c.updated_at,
    coalesce(cm.total_orders, 0) as total_orders,
    coalesce(cm.sum_revenue, 0) as total_lifetime_revenue,
    coalesce(cm.sum_net_revenue, 0) as total_lifetime_net_revenue,
    cm.first_order_date,
    cm.last_order_date,
    case
        when cm.total_spent >= 1000 then 'VIP'
        when cm.total_spent >= 500 then 'Premium'
        when cm.total_spent >= 100 then 'Regular'
        else 'New'
    end as customer_tier
from customers c
left join customer_metrics cm on c.customer_id = cm.customer_id