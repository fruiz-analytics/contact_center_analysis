[README_callcenter.md](https://github.com/user-attachments/files/30216508/README_callcenter.md)
# Call Center Performance Analysis | Python · SQL · Power BI

<img width="2767" height="1600" alt="CallCenter_Dashboard" src="https://github.com/user-attachments/assets/8538144f-6da1-4497-8673-9a8ae9b16756" />


**End-to-end analysis of contact-center performance**
Author: Franklin Manuel Ruiz Guadamuz · Tools: Python (pandas), SQLite, Power BI · Source: Kaggle — Call Center Data (1,251 records)

---

## 1. Overview
End-to-end project on 1,251 contact-center records: **Python** cleans the data and loads it into **SQLite**, **SQL** runs the analysis, and **Power BI** builds the dashboard. It measures how often the operation meets its service-level (SL) target and what drives SL breaches and abandonment — interpreted through 8+ years of WFM experience.

## 2. Pipeline
`CSV → Python (pandas cleaning) → SQLite (via sqlite3) → SQL analysis → Power BI (ODBC) dashboard`
**Consistency check:** SL compliance = **36.6%** in Python, SQL, and Power BI alike.

## 3. Data Cleaning (Python)
```python
# percentages → float
df['answer_rate'] = df['Answer Rate'].str.replace('%','').astype(float)
# durations → seconds
df['talk_duration_avg'] = pd.to_timedelta(df['Talk Duration (AVG)']).dt.total_seconds()
# derived metrics
df['abandon_rate'] = df['Abandoned Calls'] / df['Incoming Calls'] * 100
df['sla_met']      = df['Service Level (20 Seconds)'] >= 80   # 80% target
# load to SQLite from Python
import sqlite3
conn = sqlite3.connect('callcenter.db')
df.to_sql('calls', conn, if_exists='replace', index=False)
```

## 4. Findings

**Overall:** SL compliance 36.6% · Avg SL 70.9% · Avg abandon 7.3% · Avg AHT 158s.

**Volume → Service Level**

| Volume | Records | Avg SL | Abandon | Compliance |
|---|---|---|---|---|
| Low (<100) | 253 | 77.9% | 5.0% | 54.2% |
| Medium (100–250) | 734 | 72.6% | 6.1% | 34.6% |
| High (250–500) | 214 | 65.8% | 9.2% | 29.9% |
| Very High (>500) | 50 | 31.8% | 28.8% | 6.0% |

SL falls as volume rises; even Medium is below the 80% target → base staffing gap, not just peaks.

**Wait time → Abandonment**

| Wait | Records | Abandon | Avg SL |
|---|---|---|---|
| Under 1 min | 77 | 1.7% | 93.3% |
| 1–3 min | 544 | 3.9% | 79.0% |
| 3–5 min | 359 | 7.0% | 68.1% |
| Over 5 min | 271 | 16.2% | 51.9% |

Abandonment multiplies ~10x with wait; SL drops below target once wait exceeds ~1 min.

**Efficiency:** AHT avg 158s (57–288s), ASA avg 25s (max 308s) — stable and healthy.

## 5. Key Insight
Causal chain: **higher volume → longer waits → more abandonment → lower SL.** Since AHT stays healthy, the root cause is **staffing/dimensioning, not agent productivity.** The fix is capacity planning, not squeezing agents. (WFM-informed diagnosis.)

## 6. Dashboard (Power BI)
Dark custom theme (teal), connected to SQLite via ODBC, with KPI cards, the two causal stories as contrasting bar charts, a compliance donut, a volume-vs-abandonment scatter, and **custom report-page tooltips**.

![Call Center Performance Dashboard](CallCenter_Dashboard.png)

## 7. Limitations
No timestamps, agent IDs, or queues → no time-of-day / forecast / per-agent analysis. 80% SL target is an assumption. 'Very High' bucket rests on 50 records (directional).

---
**Files:** `callcenter_analysis.sql` · `analysis.ipynb` · this README · Power BI dashboard
**Skills:** pandas cleaning, feature engineering, Python→SQLite loading, SQL aggregation/bucketing, Power BI (ODBC, custom tooltips, DAX)
