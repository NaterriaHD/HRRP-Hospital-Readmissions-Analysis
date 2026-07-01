-- ================================================
-- HRRP Hospital Readmissions Analysis
-- Author: Naterria Horton-Davis
-- Data Source: CMS Hospital Readmissions Reduction Program
-- ================================================

-- STEP 1: Create and select database
CREATE DATABASE hrrp_analysis;
USE hrrp_analysis;

-- STEP 2: Create raw import table
CREATE TABLE hrrp (
    facility_name VARCHAR(255),
    facility_id INT,
    state VARCHAR(10),
    measure_name VARCHAR(255),
    number_of_discharges FLOAT,
    excess_readmission_ratio FLOAT,
    predicted_readmission_rate FLOAT,
    expected_readmission_rate FLOAT,
    number_of_readmissions FLOAT,
    start_date VARCHAR(20),
    end_date VARCHAR(20)
);

-- STEP 3: Create normalized tables
CREATE TABLE facilities AS
SELECT DISTINCT facility_id, facility_name, state
FROM hrrp;

CREATE TABLE measures AS
SELECT DISTINCT measure_name
FROM hrrp;

CREATE TABLE readmission_results AS
SELECT facility_id, measure_name, number_of_discharges,
       excess_readmission_ratio, predicted_readmission_rate,
       expected_readmission_rate, number_of_readmissions,
       start_date, end_date
FROM hrrp;

-- QUERY 1: Facilities by state alphabetically
SELECT facility_name, state
FROM facilities
ORDER BY state;

-- QUERY 2: Hospital count per state
SELECT state, COUNT(*) AS state_total
FROM facilities
GROUP BY state
ORDER BY state_total DESC;

-- QUERY 3: States with more than 100 hospitals
SELECT state, COUNT(*) AS state_total
FROM facilities
GROUP BY state
HAVING state_total > 100
ORDER BY state_total;

-- QUERY 4: Average excess readmission ratio by condition
SELECT measure_name, AVG(excess_readmission_ratio) AS avg_excess_ratio
FROM readmission_results
GROUP BY measure_name
ORDER BY avg_excess_ratio DESC;

-- QUERY 5: Hospitals penalized by CMS (ratio above 1.0)
SELECT f.facility_name, f.state, rr.measure_name, rr.excess_readmission_ratio
FROM facilities f
JOIN readmission_results rr ON f.facility_id = rr.facility_id
WHERE rr.excess_readmission_ratio > 1.0
ORDER BY excess_readmission_ratio;
