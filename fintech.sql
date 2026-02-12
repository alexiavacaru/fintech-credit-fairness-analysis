-- Define the relational database schema to house the raw financial histories.
CREATE TABLE Fintech_Credit_Data (
    Client_ID INTEGER,
    age INTEGER,
    gender TEXT,
    Annual_Income INTEGER,
    Credit_Score INTEGER,
    application_status TEXT
);

-- Use a Common Table Expression to extract and structure data for audit analysis.
WITH StructuredAudit AS (
    SELECT 
        Client_ID,
        gender,
        Credit_Score,
        application_status,
  -- Apply a window function to rank candidates by credit merit within their gender group.
        RANK() OVER (PARTITION BY gender ORDER BY Credit_Score DESC) AS merit_rank
    FROM Fintech_Credit_Data
)

-- Extract final metrics using complex aggregations to detect systemic financial bias.
SELECT 
    gender, 
    COUNT(*) AS total_applicants,
    -- Calculate the approval rate by transforming categorical status into a numerical percentage.
    ROUND(AVG(CASE WHEN application_status = 'Approved' THEN 1.0 ELSE 0.0 END) * 100, 2) AS approval_rate_pct,
    -- Identify anomalies where high-merit applicants were rejected despite their top-tier ranks.
    SUM(CASE WHEN merit_rank <= 20 AND application_status = 'Rejected' THEN 1 ELSE 0 END) AS top_merit_rejected
FROM StructuredAudit
GROUP BY gender;
