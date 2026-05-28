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
,
z_score_base AS (
	SELECT
	    s.technology_node,
	    round(s.yield::NUMERIC,3) AS yield,
	
	    ROUND(((s.etch_rate::numeric - p.avg_er) / NULLIF(p.std_er, 0)), 3) AS er_z_score,
	    ROUND(((s.deposition_rate::numeric - p.avg_dr) / NULLIF(p.std_dr, 0)), 3) AS dr_z_score,
	    ROUND(((s.critical_dimension::numeric - p.avg_cd) / NULLIF(p.std_cd, 0)), 3) AS cd_z_score,
	    ROUND(((s.oxide_thickness::numeric - p.avg_ot) / NULLIF(p.std_ot, 0)), 3) AS ot_z_score
	
	FROM semiconductor_yield_forecasting_data s
	JOIN parameter_info p
	    ON s.technology_node = p.technology_node
)
,
z_score_long AS (
	SELECT
		technology_node,
		yield,
		'etch_rate' AS parameter_name,
		er_z_score AS z_score
	FROM z_score_base
	
	UNION ALL 
	
	SELECT
		technology_node,
		yield,
		'deposition_rate' AS parameter_name,
		dr_z_score AS z_score
	FROM z_score_base
	
	UNION ALL 
	
	SELECT
		technology_node,
		yield,
		'critical_dimension' AS parameter_name,
		cd_z_score AS z_score
	FROM z_score_base
	
	UNION ALL 
	
	SELECT
		technology_node,
		yield,
		'oxide_thickness' AS parameter_name,
		ot_z_score AS z_score
	FROM z_score_base
)
,
risk_categories AS (
	SELECT 
		technology_node,
		yield,
		parameter_name,
		z_score,
		CASE 
			WHEN abs(z_score) > 3
			THEN 'OOC'
			WHEN abs(z_score) > 2
			THEN 'WARNING'
			ELSE 'NORMAL'
		END AS parameter_status
	FROM z_score_long
)

SELECT 
	technology_node,
	parameter_name,
	parameter_status,	
	count(*) AS wafer_count,
	round(100 * count(*) / sum(count(*)) OVER (PARTITION BY technology_node, parameter_name), 2 ) AS status_rate_pct,
	round(min(yield),2) AS min_yield,
	round(avg(yield),2) AS avg_yield,
	round(max(yield),2) AS max_yield,
	round(avg(abs(z_score)),2) AS avg_abs_z_score,
	round(max(abs(z_score)),2) AS max_abs_z_score
FROM risk_categories
GROUP BY
	technology_node,
	parameter_name,
	parameter_status
ORDER BY
	replace(technology_node,'nm',''):: int ASC,
	parameter_name,
	CASE parameter_status
		WHEN 'NORMAL' THEN 1
		WHEN 'WARNING' THEN 2
		WHEN 'OOC' THEN 3
	END; 
	

		









	
