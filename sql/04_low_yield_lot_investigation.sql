-- Compute SPC control limits per technology node
WITH spc_limits AS (
    SELECT
        technology_node,
        AVG(etch_rate::numeric)               AS avg_er,
        STDDEV(etch_rate::numeric)            AS std_er,
        AVG(deposition_rate::numeric)         AS avg_dr,
        STDDEV(deposition_rate::numeric)      AS std_dr,
        AVG(critical_dimension::numeric)      AS avg_cd,
        STDDEV(critical_dimension::numeric)   AS std_cd,
        AVG(oxide_thickness::numeric)         AS avg_ot,
        STDDEV(oxide_thickness::numeric)      AS std_ot
    FROM semiconductor_yield_forecasting_data
    GROUP BY technology_node
)
,
wafer_flags AS (
    SELECT
        s.lot_id,
        s.wafer_id,
        s.technology_node,
        CASE
            WHEN s.etch_rate::numeric NOT BETWEEN
                (p.avg_er - 3*p.std_er) AND (p.avg_er + 3*p.std_er)
            THEN 'OOC'
            WHEN s.etch_rate::numeric NOT BETWEEN
                (p.avg_er - 2*p.std_er) AND (p.avg_er + 2*p.std_er)
            THEN 'WARNING'
            ELSE 'IN_CONTROL'
        END AS er_flag,
        CASE
            WHEN s.deposition_rate::numeric NOT BETWEEN
                (p.avg_dr - 3*p.std_dr) AND (p.avg_dr + 3*p.std_dr)
            THEN 'OOC'
            WHEN s.deposition_rate::numeric NOT BETWEEN
                (p.avg_dr - 2*p.std_dr) AND (p.avg_dr + 2*p.std_dr)
            THEN 'WARNING'
            ELSE 'IN_CONTROL'
        END AS dr_flag,
        CASE
            WHEN s.critical_dimension::numeric NOT BETWEEN
                (p.avg_cd - 3*p.std_cd) AND (p.avg_cd + 3*p.std_cd)
            THEN 'OOC'
            WHEN s.critical_dimension::numeric NOT BETWEEN
                (p.avg_cd - 2*p.std_cd) AND (p.avg_cd + 2*p.std_cd)
            THEN 'WARNING'
            ELSE 'IN_CONTROL'
        END AS cd_flag,
        CASE
            WHEN s.oxide_thickness::numeric NOT BETWEEN
                (p.avg_ot - 3*p.std_ot) AND (p.avg_ot + 3*p.std_ot)
            THEN 'OOC'
            WHEN s.oxide_thickness::numeric NOT BETWEEN
                (p.avg_ot - 2*p.std_ot) AND (p.avg_ot + 2*p.std_ot)
            THEN 'WARNING'
            ELSE 'IN_CONTROL'
        END AS ot_flag
    FROM semiconductor_yield_forecasting_data s
    JOIN spc_limits p ON s.technology_node = p.technology_node
)
,
-- Summarise OOC and WARNING counts per lot
lot_spc_summary AS (
    SELECT
        lot_id,
        COUNT(*) FILTER (
            WHERE er_flag = 'OOC'
               OR dr_flag = 'OOC'
               OR cd_flag = 'OOC'
               OR ot_flag = 'OOC'
        ) AS ooc_wafer_count,
        COUNT(*) FILTER (
            WHERE (er_flag  = 'WARNING'
               OR  dr_flag  = 'WARNING'
               OR  cd_flag  = 'WARNING'
               OR  ot_flag  = 'WARNING')
              AND er_flag != 'OOC'
              AND dr_flag != 'OOC'
              AND cd_flag != 'OOC'
              AND ot_flag != 'OOC'
        ) AS warning_wafer_count,
        COUNT(*) FILTER (WHERE er_flag = 'OOC') AS er_ooc_count,
        COUNT(*) FILTER (WHERE dr_flag = 'OOC') AS dr_ooc_count,
        COUNT(*) FILTER (WHERE cd_flag = 'OOC') AS cd_ooc_count,
        COUNT(*) FILTER (WHERE ot_flag = 'OOC') AS ot_ooc_count
    FROM wafer_flags
    GROUP BY lot_id
)
,
-- Aggregate lot-level metrics
lot_summary AS (
    SELECT
        lot_id,
        technology_node,
        product_type,
        MIN(process_date)                                    AS process_date,
        STRING_AGG(DISTINCT etch_tool, ', '
            ORDER BY etch_tool)                              AS etch_tools,
        STRING_AGG(DISTINCT litho_tool, ', '
            ORDER BY litho_tool)                             AS litho_tools,
        STRING_AGG(DISTINCT deposition_tool, ', '
            ORDER BY deposition_tool)                        AS deposition_tools,
        STRING_AGG(DISTINCT implant_tool, ', '
            ORDER BY implant_tool)                           AS implant_tools,
        COUNT(*)                                             AS wafer_count,
        ROUND(AVG(yield::numeric), 3)                        AS avg_yield,
        ROUND(STDDEV(yield::numeric), 3)                     AS std_yield,
        ROUND(MIN(yield::numeric), 3)                        AS min_yield,
        ROUND(MAX(yield::numeric), 3)                        AS max_yield,
        ROUND(AVG(defect_count::numeric), 2)                 AS avg_defect_count,
        ROUND(AVG(defect_density::numeric), 3)               AS avg_defect_density,
        ROUND(AVG(critical_dimension::numeric), 3)           AS avg_cd,
        ROUND(AVG(oxide_thickness::numeric), 3)              AS avg_oxide_thickness,
        ROUND(AVG(vth::numeric), 3)                          AS avg_vth,
        ROUND(AVG(resistance::numeric), 3)                   AS avg_resistance,
        ROUND(AVG(etch_rate::numeric), 3)                    AS avg_etch_rate,
        ROUND(AVG(deposition_rate::numeric), 3)              AS avg_deposition_rate
    FROM semiconductor_yield_forecasting_data
    GROUP BY lot_id, technology_node, product_type
)
SELECT
    ls.lot_id,
    ls.technology_node,
    ls.product_type,
    ls.process_date,
    ls.etch_tools,
    ls.litho_tools,
    ls.deposition_tools,
    ls.implant_tools,
    ls.wafer_count,
    ls.avg_yield,
    ls.std_yield,
    ls.min_yield,
    ls.max_yield,
    lo.ooc_wafer_count,
    lo.warning_wafer_count,
    lo.er_ooc_count,
    lo.dr_ooc_count,
    lo.cd_ooc_count,
    lo.ot_ooc_count,
    ls.avg_defect_count,
    ls.avg_defect_density,
    ls.avg_cd,
    ls.avg_oxide_thickness,
    ls.avg_vth,
    ls.avg_resistance,
    ls.avg_etch_rate,
    ls.avg_deposition_rate,

    -- Yield risk classification
    CASE
        WHEN ls.avg_yield < 0.35 THEN 'Critical'
        WHEN ls.avg_yield < 0.50 THEN 'Warning'
        ELSE 'Normal'
    END AS yield_risk_status,

    -- Rank within same node + product (1 = worst yield)
    RANK() OVER (
        PARTITION BY ls.technology_node, ls.product_type
        ORDER BY ls.avg_yield ASC
    ) AS worst_yield_rank,

    -- OOC rate as % of total wafers in lot
    ROUND(
        lo.ooc_wafer_count * 100.0 / ls.wafer_count,
    1) AS ooc_rate_pct

FROM lot_summary ls
LEFT JOIN lot_spc_summary lo ON ls.lot_id = lo.lot_id
ORDER BY ls.avg_yield ASC;

-- 