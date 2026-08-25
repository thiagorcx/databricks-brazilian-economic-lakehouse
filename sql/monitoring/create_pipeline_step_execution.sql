CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_monitoring.pipeline_step_execution
(
    execution_id STRING
        COMMENT 'Pipeline execution identifier',

    step_name STRING
        COMMENT 'Name of the pipeline step',

    step_order INT
        COMMENT 'Expected execution order of the step',

    step_type STRING
        COMMENT 'Functional category of the step: INGESTION, TRANSFORMATION, DATA_QUALITY, ANALYTICAL or MONITORING',

    layer STRING
        COMMENT 'Lakehouse layer or processing category associated with the step',

    start_timestamp TIMESTAMP
        COMMENT 'Timestamp when the step started',

    end_timestamp TIMESTAMP
        COMMENT 'Timestamp when the step finished',

    duration_seconds BIGINT
        COMMENT 'Step execution duration in seconds',

    status STRING
        COMMENT 'Step status: PENDING, RUNNING, SUCCESS, FAILED or SKIPPED',

    records_read BIGINT
        COMMENT 'Number of records read or received by the step',

    records_inserted BIGINT
        COMMENT 'Number of records inserted by the step',

    records_updated BIGINT
        COMMENT 'Number of existing records updated by the step',

    records_output BIGINT
        COMMENT 'Total number of records available after the step',

    failed_checks BIGINT
        COMMENT 'Number of failed data quality checks associated with the step',

    error_message STRING
        COMMENT 'Error message or skip reason'
)
USING DELTA
COMMENT 'Detailed historical monitoring of individual pipeline steps';