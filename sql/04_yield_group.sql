WITH yield_grouped AS (
    SELECT
        *,
        CASE
            WHEN yield::numeric < 0.35 THEN 'Low Yield'
            WHEN yield::numeric < 0.50 THEN 'Medium Yield'
            ELSE 'High Yield'
        END AS yield_group
    FROM semiconductor_yield_forecasting_data
)
SELECT
    technology_node,
    yield_group,
    COUNT(*) AS wafer_count,
    ROUND(AVG(yield::numeric), 3) AS avg_yield,
    ROUND(AVG(etch_rate::numeric), 3) AS avg_etch_rate,
    ROUND(AVG(deposition_rate::numeric), 3) AS avg_deposition_rate,
    ROUND(AVG(critical_dimension::numeric), 3) AS avg_cd,
    ROUND(AVG(oxide_thickness::numeric), 3) AS avg_oxide_thickness
FROM yield_grouped
GROUP BY
    technology_node,
    yield_group
ORDER BY
    REPLACE(technology_node, 'nm', '')::int,
    yield_group;