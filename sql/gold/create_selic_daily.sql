CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_gold.selic_daily
(
    reference_date DATE
        COMMENT 'Reference date',

    selic_target_rate DECIMAL(8,4)
        COMMENT 'Selic target rate',

    previous_rate DECIMAL(8,4)
        COMMENT 'Selic target rate from the previous available date',

    rate_change_pp DECIMAL(8,4)
        COMMENT 'Change in percentage points compared with the previous available date',

    rate_change_flag STRING
        COMMENT 'Rate movement classification: INCREASE, DECREASE or UNCHANGED',

    year INT
        COMMENT 'Reference year',

    month INT
        COMMENT 'Reference month',

    year_month STRING
        COMMENT 'Reference year and month in YYYY-MM format',

    record_hash STRING
    COMMENT 'SHA-256 hash of Gold business attributes used for change detection',

    processed_timestamp TIMESTAMP
        COMMENT 'Timestamp when the Gold record was processed'
)
USING DELTA
COMMENT 'Analytical daily Selic target rate dataset';