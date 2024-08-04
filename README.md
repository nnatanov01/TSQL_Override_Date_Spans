This implementation solves the problem of returning data for two tables with one table's spans overriding the other. 

Say the main span table specifies a span from '2024-01-01' - '2025-01-01' and the sub span table specifies any span within those date ranges and we want the output to look like

## Schedule

| StartDate   | EndDate     | Type |
|-------------|-------------|------|
| 2024-01-01  | 2024-02-29  | main |
| 2024-03-01  | 2024-03-31  | sub  |
| 2024-04-01  | 2025-01-01  | main |
