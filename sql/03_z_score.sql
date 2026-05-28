WITH parameter_info AS (
    SELECT 
        technology_node,

        AVG(etch_rate::numeric) AS avg_er,
        STDDEV(etch_rate::numeric) AS std_er,

        AVG(deposition_rate::numeric) AS avg_dr,
        STDDEV(deposition_rate::numeric) AS std_dr,

        AVG(critical_dimension::numeric) AS avg_cd,
        STDDEV(critical_dimension::numeric) AS std_cd,

        AVG(oxide_thickness::numeric) AS avg_ot,
        STDDEV(oxide_thickness::numeric) AS std_ot

    FROM semiconductor_yield_forecasting_data
    GROUP BY technology_node
)

SELECT
    s.technology_node,
    round(s.yield::NUMERIC,3) AS yield,

    ROUND(((s.etch_rate::numeric - p.avg_er) / NULLIF(p.std_er, 0)), 3) AS er_z_score,
    ROUND(((s.deposition_rate::numeric - p.avg_dr) / NULLIF(p.std_dr, 0)), 3) AS dr_z_score,
    ROUND(((s.critical_dimension::numeric - p.avg_cd) / NULLIF(p.std_cd, 0)), 3) AS cd_z_score,
    ROUND(((s.oxide_thickness::numeric - p.avg_ot) / NULLIF(p.std_ot, 0)), 3) AS ot_z_score,

    CASE
        WHEN ABS((s.etch_rate::numeric - p.avg_er) / NULLIF(p.std_er, 0)) > 3
          OR ABS((s.deposition_rate::numeric - p.avg_dr) / NULLIF(p.std_dr, 0)) > 3
          OR ABS((s.critical_dimension::numeric - p.avg_cd) / NULLIF(p.std_cd, 0)) > 3
          OR ABS((s.oxide_thickness::numeric - p.avg_ot) / NULLIF(p.std_ot, 0)) > 3
        THEN 'OOC'

        WHEN ABS((s.etch_rate::numeric - p.avg_er) / NULLIF(p.std_er, 0)) > 2
          OR ABS((s.deposition_rate::numeric - p.avg_dr) / NULLIF(p.std_dr, 0)) > 2
          OR ABS((s.critical_dimension::numeric - p.avg_cd) / NULLIF(p.std_cd, 0)) > 2
          OR ABS((s.oxide_thickness::numeric - p.avg_ot) / NULLIF(p.std_ot, 0)) > 2
        THEN 'Warning'

        ELSE 'Normal'
    END AS spc_status

FROM semiconductor_yield_forecasting_data s
JOIN parameter_info p
    ON s.technology_node = p.technology_node
ORDER BY 
	REPLACE(s.technology_node,'nm','')::int