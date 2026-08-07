{{ config(materialized='table') }}

with rides as (
    select * from {{ ref('dim_rides') }}
)

select
    ride_key,
    ride_id,
    ride_name,
    ride_type,
    thrill_level,
    zone,
    is_haunted as is_Haunted,
    status,
    capacity_per_hour as capacity_per_hour,
    avg_wait_minutes,
    total_reviews,
    avg_rating,
    positive_review_pct,
    has_reviews,
    review_count_band,
    case
        when avg_rating >= 4.5 then 'Top Rated'
        when avg_rating >= 3.5 then 'Well Rated'
        when avg_rating >= 2.5 then 'Average'
        when avg_rating > 0 then 'Below Average'
        else 'Not Yet Rated'
    end as rating_tier,
    case
        when total_reviews >= 3 then 'Proven Favorite'
        when total_reviews >= 1 then 'Emerging Interest'
        else 'Needs Awareness'
    end as popularity_segment,
    case
        when avg_wait_minutes >= 25 and avg_rating < 3 and total_reviews > 0 then 'High Wait / Low Satisfaction'
        when avg_wait_minutes >= 25 and avg_rating >= 4 and total_reviews > 0 then 'High Wait / Strong Satisfaction'
        when avg_wait_minutes < 25 and avg_rating >= 4 and total_reviews > 0 then 'Low Wait / Strong Satisfaction'
        when total_reviews = 0 then 'No Feedback Yet'
        else 'Monitor'
    end as wait_experience_segment,
    rank() over (order by total_reviews desc, avg_rating desc nulls last) as review_volume_rank,
    rank() over (order by avg_rating desc nulls last, total_reviews desc) as rating_rank,
    case
        when total_reviews > 0 then round((avg_rating / 5.0) * 100, 1)
        else 0
    end as satisfaction_score_pct,
    case
        when capacity_per_hour > 0 and avg_wait_minutes > 0 
        then round((capacity_per_hour * 60.0) / (capacity_per_hour * avg_wait_minutes / 60.0 + 1), 2)
        else 0
    end as throughput_ratio,
    case
        when total_reviews >= 10 and positive_review_pct >= 80 then 'Must Experience'
        when total_reviews >= 5 and positive_review_pct >= 60 then 'Highly Recommended'
        when total_reviews >= 1 then 'Popular Choice'
        else 'Hidden Gem'
    end as recommendation_badge
from rides
