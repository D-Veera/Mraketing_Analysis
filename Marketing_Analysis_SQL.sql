CREATE DATABASE Data_Analysis ;

USE Data_Analysis;

SELECT * FROM users;
SELECT * FROM app_events;
-- Marketing Analytics

-- 1. Analyse marketing campaign performance by channel (spend, conversions, and conversion rate)

SELECT 
    channel, 
    SUM(spend) AS total_spend, 
    SUM(conversions) AS total_conversions, 
    (SUM(conversions) * 1.0 / SUM(clicks)) AS conversion_rate
FROM marketing_events
GROUP BY channel;

-- 2. Calculate the Cost Per Acquisition (CPA) for each campaign

SELECT 
    campaign_id, 
    channel, 
    spend, 
    conversions, 
    (spend / NULLIF(conversions, 0)) AS cost_per_acquisition
FROM marketing_events; 


3. Identify which channels are most cost-effective in terms of conversions

SELECT 
    channel, 
    SUM(spend) AS total_spend, 
    SUM(conversions) AS total_conversions, 
    (SUM(spend) / NULLIF(SUM(conversions), 0)) AS cost_per_acquisition
FROM marketing_events
GROUP BY channel
ORDER BY cost_per_acquisition ASC;

-- Product Analytics

-- 1. Analyse feature adoption rates (how many users engaged with specific features)
SELECT 
    feature_name, 
    COUNT(DISTINCT user_id) AS users_engaged
FROM app_events
GROUP BY feature_name;

-- 2. Calculate daily or weekly active users (DAU/WAU) DAILY ACTIVE USER

SELECT 
    event_date, 
    COUNT(DISTINCT user_id) AS daily_active_users
FROM app_events
GROUP BY event_date;

-- 3. Perform cohort analysis to track user retention over time

WITH user_cohorts AS (
	SELECT
		u.user_id,
        MIN(a.event_date) AS cohort_date
	FROM users u JOIN app_events a ON u.user_id = a.user_id
    GROUP BY u.user_id
    ),
retention AS (
	SELECT
		uc.cohort_date,
        DATE_FORMAT(a.event_date, '%Y-%m-01 00:00:00') AS active_month,
        COUNT(DISTINCT a.user_id) AS active_users
	FROM user_cohorts uc JOIN app_events a ON uc.user_id = a.user_id
    GROUP BY uc.cohort_date, active_month
	)
SELECT
	cohort_date,
    active_month,
    active_users
FROM retention
ORDER BY cohort_date, active_month;

-- 4. Analyse average session duration per feature and user location

SELECT 
    ae.feature_name, 
    u.location, 
    AVG(ae.session_duration) AS avg_session_duration
FROM app_events ae
JOIN users u ON ae.user_id = u.user_id
GROUP BY ae.feature_name, u.location
ORDER BY avg_session_duration DESC;

