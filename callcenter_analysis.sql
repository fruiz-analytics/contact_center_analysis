/* ============================================================================
   CALL CENTER PERFORMANCE ANALYSIS
   Author : Franklin Manuel Ruiz Guadamuz
   Engine : SQLite (data cleaned in Python, loaded via sqlite3)
   Source : Kaggle — Call Center Data (1,251 interaction records)

   Goal   : Analyze contact-center performance — service level (SL) compliance,
            the impact of volume and wait time on SL and abandonment, and overall
            efficiency. Assumes an 80% service-level target (industry standard;
            not specified in the source data).
   ============================================================================ */


/* ----------------------------------------------------------------------------
   1. OVERALL PERFORMANCE SNAPSHOT
   One-row summary of the operation. AVG(sla_met)*100 gives the % of records
   that met the 80% SL target (sla_met is a 0/1 flag).
   ---------------------------------------------------------------------------- */
SELECT
    COUNT(*)                              AS total_interactions,
    ROUND(AVG(sla_met) * 100, 2)          AS pct_sla_met,
    ROUND(AVG(abandon_rate), 2)           AS avg_abandon_rate,
    ROUND(AVG(talk_duration_avg), 2)      AS avg_talk_duration_sec
FROM calls;


/* ----------------------------------------------------------------------------
   2. VOLUME vs SERVICE LEVEL
   Incoming call volume is bucketed to test whether higher volume degrades SL.
   Finding: SL falls steadily as volume rises, and abandonment climbs — the
   operation is not staffed for peaks. Even the 'Medium' bucket sits below the
   80% target, pointing to a base staffing gap, not just a peak problem.
   ---------------------------------------------------------------------------- */
SELECT
    CASE
        WHEN incoming_calls < 100 THEN 'Low'
        WHEN incoming_calls BETWEEN 100 AND 250 THEN 'Medium'
        WHEN incoming_calls BETWEEN 250 AND 500 THEN 'High'
        WHEN incoming_calls > 500 THEN 'Very High'
    END AS volume_bucket,
    COUNT(*)                              AS total_interactions,
    ROUND(AVG(service_level_20_seconds), 1) AS avg_sl,
    ROUND(AVG(abandon_rate), 1)           AS avg_abandon_rate,
    ROUND(AVG(sla_met) * 100, 1)          AS pct_sla_met
FROM calls
GROUP BY volume_bucket
ORDER BY MIN(incoming_calls);


/* ----------------------------------------------------------------------------
   3. WAIT TIME vs ABANDONMENT
   Tests whether longer waits drive abandonment (and lower SL). Wait time is
   bucketed in seconds. Finding: abandonment rises ~10x from the shortest to the
   longest wait bucket, and SL drops in parallel.
   ---------------------------------------------------------------------------- */
SELECT
    CASE
        WHEN waiting_time_avg < 60 THEN 'Under 1 min'
        WHEN waiting_time_avg BETWEEN 60 AND 180 THEN '1-3 min'
        WHEN waiting_time_avg BETWEEN 180 AND 300 THEN '3-5 min'
        WHEN waiting_time_avg > 300 THEN 'Over 5 min'
    END AS wait_bucket,
    COUNT(*)                              AS total_interactions,
    ROUND(AVG(abandon_rate), 1)           AS avg_abandon_rate,
    ROUND(AVG(service_level_20_seconds), 1) AS avg_sl
FROM calls
GROUP BY wait_bucket
ORDER BY MIN(waiting_time_avg);


/* ----------------------------------------------------------------------------
   4. EFFICIENCY SNAPSHOT (AHT / ASA)
   Range and average of handle time and answer speed. Finding: AHT is stable and
   healthy (no runaway handle times), which supports the conclusion that the SL
   problem is a staffing/dimensioning issue, not agent productivity.
   ---------------------------------------------------------------------------- */
SELECT
    ROUND(AVG(talk_duration_avg), 0) AS avg_aht_sec,
    MIN(talk_duration_avg)           AS min_aht_sec,
    MAX(talk_duration_avg)           AS max_aht_sec,
    ROUND(AVG(answer_speed_avg), 0)  AS avg_asa_sec,
    MAX(answer_speed_avg)            AS max_asa_sec
FROM calls;
