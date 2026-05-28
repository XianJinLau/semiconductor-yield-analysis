WITH parameter_info AS(
	SELECT 
		technology_node,
		avg(etch_rate::numeric) AS avg_er,
		stddev(etch_rate::numeric) AS std_er,
		avg(deposition_rate::numeric) AS avg_dr,
		stddev(deposition_rate::NUMERIC) AS std_dr,
		avg(critical_dimension::numeric) AS avg_cd,
		stddev(critical_dimension::NUMERIC) AS std_cd,
		avg(oxide_thickness::numeric) AS avg_ot,
		stddev(oxide_thickness::NUMERIC) AS std_ot
	FROM semiconductor_yield_forecasting_data syfd 
	GROUP BY
		technology_node
)
,
spc_flag AS (
	SELECT
		s.technology_node,
		round(s.etch_rate::numeric,2) AS etch_rate,
		round(s.deposition_rate::numeric,2) AS deposition_rate,
		round(s.critical_dimension::numeric,2) AS critical_dimension,
		round(s.oxide_thickness::numeric,2) AS oxide_thickness,
		round(s.yield::numeric,2) AS yield,
		CASE 
			WHEN etch_rate NOT BETWEEN (p.avg_er - 3*p.std_er) AND (p.avg_er + 3*p.std_er)
			THEN 'OOC'
			WHEN etch_rate NOT BETWEEN (p.avg_er - 2*p.std_er) AND (p.avg_er + 2*p.std_er)
			THEN 'WARNING'
			ELSE 'IN_CONTROL'
		END AS er_flag,
		CASE
			WHEN deposition_rate NOT BETWEEN (p.avg_dr - 3*p.std_dr) AND (p.avg_dr + 3*p.std_dr)
			THEN 'OOC'
			WHEN deposition_rate NOT BETWEEN (p.avg_dr - 2*p.std_dr) AND (p.avg_dr + 2*p.std_dr)
			THEN 'WARNING'
			ELSE 'IN_CONTROL'
		END AS dr_flag,
		CASE
			WHEN critical_dimension NOT BETWEEN (p.avg_cd - 3*p.std_cd) AND (p.avg_cd + 3*p.std_cd)
			THEN 'OOC'
			WHEN critical_dimension NOT BETWEEN (p.avg_cd - 2*p.std_cd) AND (p.avg_cd + 2*p.std_cd)
			THEN 'WARNING'
			ELSE 'IN_CONTROL'
		END AS cd_flag,
		CASE
			WHEN oxide_thickness NOT BETWEEN (p.avg_ot - 3*p.std_ot) AND (p.avg_ot + 3*p.std_ot)
			THEN 'OOC'
			WHEN oxide_thickness NOT BETWEEN (p.avg_ot - 2*p.std_ot) AND (p.avg_ot + 2*p.std_ot)
			THEN 'WARNING'
			ELSE 'IN_CONTROL'
		END AS ot_flag		
	FROM semiconductor_yield_forecasting_data s
	JOIN parameter_info p
	ON p.technology_node = s.technology_node
	ORDER BY
		replace(s.technology_node, 'nm',''):: int asc,
		s.yield ASC
)
,
spc_union_all AS (		
	SELECT
		technology_node,
		'etch_rate' AS parameter_name,
		er_flag AS spc_status
		FROM spc_flag
		
		UNION ALL
		
	SELECT
		technology_node,
		'deposition_rate' AS parameter_name,
		dr_flag AS spc_status
		FROM spc_flag
		
		UNION ALL 
		
	SELECT
		technology_node,
		'critical_dimension' AS parameter_name,
		cd_flag AS spc_status
		FROM spc_flag
		
		UNION ALL 
		
	SELECT
		technology_node,
		'oxide_thickness' AS parameter_name,
		ot_flag AS spc_status
		FROM spc_flag
)
SELECT 
	technology_node,
	parameter_name,
	spc_status,
	count(*) AS wafer_count,
	round(100.0*count(*) / sum(count(*)) OVER (PARTITION BY technology_node,parameter_name),2) AS status_rate
FROM spc_union_all
GROUP BY 
	technology_node,
	parameter_name,
	spc_status
ORDER BY 
	REPLACE(technology_node, 'nm', '')::int,
    parameter_name,
    CASE spc_status
        WHEN 'IN_CONTROL' THEN 1
        WHEN 'WARNING' THEN 2
        WHEN 'OOC' THEN 3
    END;
		
		
	
		
		
		
		
		
		