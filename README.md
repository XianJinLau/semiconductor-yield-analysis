# semiconductor-yield-analysis

## Business Context

In semiconductor manufacturing, wafer yield (the percentage of functional die produced per wafer) determines the commercial viability of every product line. Yield loss stems from a complex interplay of equipment health, process parameter drift, and product-node compatibility. Identifying root causes requires systematic analysis across thousands of wafer records, multiple process steps, and dozens of process parameters simultaneously.

This analysis replicates the analytical workflow of a real fab yield investigation: equipment performance benchmarking, SPC-style process control monitoring, defect-yield correlation analysis, and lot-level failure triage — all implemented in SQL and Python, and presented through an interactive Power BI dashboard designed for multiple engineering stakeholders.

---
## Dataset

> **Dataset note:** This is a simulated dataset generated for analytical practice. Yield values have been scaled to create analytical variance; real production targets typically range 80–95%. All process parameter names, tool IDs, column structures, and process flow conventions reflect real semiconductor manufacturing practice.
> **Source:** https://www.kaggle.com/datasets/ayyappanmarimuthu/semiconductor-yield

| Attribute | Detail |
|---|---|
| Total wafers | 1,250 |
| Total lots | 50 (25 wafers per lot) |
| Technology nodes | 7nm, 10nm, 14nm, 22nm, 28nm |
| Product types | ASIC, CPU, FPGA, GPU, Memory |
| Process steps | Etch, Lithography, Deposition, Implant |
| Date range | Jan–Feb 2023 (50 days) |
| Null values | Zero across all 28 columns |
| Key columns | `yield`, `defect_density`, `critical_dimension`, `oxide_thickness`, `vth`, `etch_rate`, `deposition_rate`, `thickness_uniformity`, tool IDs per process step |

Not all product types are manufactured on every technology node — blank cells in the yield heatmap reflect realistic fab tool qualification constraints, not data gaps.

---

## Tools & Stack

| Layer | Tool | Purpose |
|---|---|---|
| Data storage | PostgreSQL | Raw data storage and querying |
| Query editor | DBeaver | SQL development and result export |
| Analysis | Python (JupyterLab) | Statistical analysis, correlation, ML modelling |
| Visualisation | Power BI Desktop | Interactive 4-page engineering dashboard |
| Version control | GitHub | Portfolio hosting and project documentation |

**Python libraries:** pandas, matplotlib, seaborn, scikit-learn, statsmodels

---

## Stakeholder Questions

This project is structured around four business questions, each addressed to a named engineering stakeholder:

| # | Question | Stakeholder |
|---|---|---|
| 1 | Which etch, litho, deposition, and implant tools are underperforming their fleet average, and which show unstable yield variance? | Yield engineer / Equipment engineer |
| 2 | Which process parameters are out of statistical control, and does parameter excursion predict yield outcome? | Process engineer / SPC coordinator |
| 3 | Which process parameters correlate most strongly with yield, and can yield be predicted from in-line measurements? | Process engineer / Data analyst |
| 4 | Which lots are at critical yield risk, and what process and equipment factors are associated with low-yield lots? | Yield engineer / Engineering manager |

---
