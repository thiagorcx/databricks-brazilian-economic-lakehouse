# BCB SGS - Selic Target Rate

## Source

Banco Central do Brasil - Sistema Gerenciador de Séries Temporais (SGS)

## Series

- Series code: 432
- Indicator: Selic Target Rate
- Frequency: Daily
- Source format: JSON
- Source type: Public API

## Endpoint

Base endpoint:

https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados

Example:

https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados?formato=json&dataInicial=01/01/2026

## Source Schema

| Field | Description |
|---|---|
| data | Reference date in DD/MM/YYYY format |
| valor | Selic target rate value returned as text |

## Source Constraints

For daily series, the BCB API limits each request to a maximum period of 10 years.

Historical ingestion must therefore split large periods into multiple time windows.

## Ingestion Strategy

### Historical Load

The initial load will retrieve historical data using multiple API requests when the requested period exceeds the API limit.

The ingestion process must consolidate all returned windows before loading the Bronze layer.

### Incremental Load

After the historical load, the pipeline will retrieve only new dates not yet available in the target dataset.

The incremental process must be idempotent and must not create duplicate records if the same date is processed more than once.

## Bronze Layer

Target schema:

workspace.brazilian_economic_bronze

The Bronze layer must preserve the original source values whenever possible and add technical ingestion metadata.

Planned technical metadata:

- ingestion_timestamp
- source_system
- source_endpoint
- execution_id
- ingestion_date

## Data Quality

Initial validation rules:

- `data` must not be null
- `valor` must not be null
- `data` must follow the expected date format
- `valor` must be convertible to a numeric value
- duplicate records for the same reference date must be monitored

## Future Silver Processing

The Silver layer will:

- convert `data` to DATE
- convert `valor` to DECIMAL
- standardize column names
- remove or handle duplicates
- apply data quality rules
- maintain validated records for analytical consumption

## Implemented Data Flow

The BCB SGS Selic series is currently implemented through the following pipeline:

1. API ingestion using Python and the public BCB SGS endpoint.
2. Raw data persistence in the Bronze Delta table.
3. Bronze data quality checks recorded in the governance layer.
4. Type conversion and deduplication into the Silver layer using SQL MERGE.
5. Silver data quality checks.
6. Analytical transformation into the Gold layer.
7. Gold calculations include previous rate, rate change in percentage points and movement classification.

### Implemented Tables

- `workspace.brazilian_economic_bronze.bcb_sgs_selic`
- `workspace.brazilian_economic_silver.bcb_sgs_selic`
- `workspace.brazilian_economic_gold.selic_daily`
- `workspace.brazilian_economic_governance.data_quality_results`

### Current Status

The Selic pipeline has been validated for:

- API connectivity
- HTTP error validation
- dynamic lookback window
- Bronze ingestion
- technical ingestion metadata
- Silver type conversion
- deduplication
- idempotent MERGE processing
- Bronze data quality checks
- Silver data quality checks
- Gold analytical transformation
- Gold idempotency