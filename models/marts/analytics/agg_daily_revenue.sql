{{ config(materialized='table') }}

with daily as (
    select * from {{ ref('int_daily_revenue') }}
),

date_dim as (
    select * from {{ ref('dim_dates') }}
)

select
    d.date_day,
    d.day_of_week,
    d.month_name,
    d.quarter,
    d.year,
    d.is_weekend,
    coalesce(r.ticket_revenue, 0)    as ticket_revenue,
    coalesce(r.in_park_revenue, 0)   as in_park_revenue,
    coalesce(r.food_revenue, 0)      as food_revenue,
    coalesce(r.merch_revenue, 0)     as merch_revenue,
    coalesce(r.total_revenue, 0)     as total_revenue,
    coalesce(r.unique_visitors, 0)   as unique_visitors,
    coalesce(r.tickets_sold, 0)      as tickets_sold,
    case
        when coalesce(r.unique_visitors, 0) > 0
            then round(r.total_revenue / r.unique_visitors, 2)
        else 0
    end                              as revenue_per_visitor,
    case
        when coalesce(r.tickets_sold, 0) > 0
            then round(r.total_revenue / r.tickets_sold, 2)
        else 0
    end                              as avg_ticket_price,
    lag(r.total_revenue, 1) over (order by d.date_day) as previous_day_revenue,
    case
        when lag(r.total_revenue, 1) over (order by d.date_day) > 0
            then round(
                (r.total_revenue - lag(r.total_revenue, 1) over (order by d.date_day))
                / lag(r.total_revenue, 1) over (order by d.date_day) * 100
                , 2)
        else 0
    end                              as revenue_change_pct
from date_dim d
left join daily r on d.date_day = r.visit_date
where d.date_day between '2024-01-01' and current_date()
