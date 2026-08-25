MERGE INTO workspace.brazilian_economic_gold.selic_daily AS target

USING (
    WITH selic_with_previous AS (
        SELECT
            reference_date,
            selic_target_rate,
            LAG(selic_target_rate) OVER (
                ORDER BY reference_date
            ) AS previous_rate
        FROM workspace.brazilian_economic_silver.bcb_sgs_selic
    ),
    gold_attributes AS (
        SELECT
            reference_date,
            selic_target_rate,
            previous_rate,
            CAST(
                selic_target_rate - previous_rate
                AS DECIMAL(8,4)
            ) AS rate_change_pp,
            CASE
                WHEN previous_rate IS NULL THEN 'INITIAL'
                WHEN selic_target_rate > previous_rate THEN 'INCREASE'
                WHEN selic_target_rate < previous_rate THEN 'DECREASE'
                ELSE 'UNCHANGED'
            END AS rate_change_flag,
            YEAR(reference_date) AS year,
            MONTH(reference_date) AS month,
            DATE_FORMAT(reference_date, 'yyyy-MM') AS year_month
        FROM selic_with_previous
    ),
    gold_with_hash AS (
        SELECT
            reference_date,
            selic_target_rate,
            previous_rate,
            rate_change_pp,
            rate_change_flag,
            year,
            month,
            year_month,
            SHA2(
                CONCAT_WS(
                    '||',
                    CAST(reference_date AS STRING),
                    CAST(selic_target_rate AS STRING),
                    COALESCE(CAST(previous_rate AS STRING), ''),
                    COALESCE(CAST(rate_change_pp AS STRING), ''),
                    rate_change_flag,
                    CAST(year AS STRING),
                    CAST(month AS STRING),
                    year_month
                ),
                256
            ) AS record_hash,
            CURRENT_TIMESTAMP() AS processed_timestamp
        FROM gold_attributes
    )
    SELECT *
    FROM gold_with_hash
) AS source
ON target.reference_date = source.reference_date

WHEN MATCHED
AND NOT (target.record_hash <=> source.record_hash)
THEN UPDATE SET
    target.selic_target_rate = source.selic_target_rate,
    target.previous_rate = source.previous_rate,
    target.rate_change_pp = source.rate_change_pp,
    target.rate_change_flag = source.rate_change_flag,
    target.year = source.year,
    target.month = source.month,
    target.year_month = source.year_month,
    target.record_hash = source.record_hash,
    target.processed_timestamp = source.processed_timestamp

WHEN NOT MATCHED THEN INSERT (
    reference_date,
    selic_target_rate,
    previous_rate,
    rate_change_pp,
    rate_change_flag,
    year,
    month,
    year_month,
    record_hash,
    processed_timestamp
)
VALUES (
    source.reference_date,
    source.selic_target_rate,
    source.previous_rate,
    source.rate_change_pp,
    source.rate_change_flag,
    source.year,
    source.month,
    source.year_month,
    source.record_hash,
    source.processed_timestamp
);