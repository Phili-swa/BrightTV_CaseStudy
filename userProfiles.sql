-- Databricks notebook source
select * from `brighttv_case_study`.`brighttv`.`bright_tv_dataset` limit 100;


----------------------------------------------
--Duplicates
----------------------------------------------
SELECT UserID,
    COUNT(*) AS duplicate_count
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`
GROUP BY UserID
HAVING duplicate_count >1;

-------------------------------------------------------
--SIZE OF DATA
-------------------------------------------------------

SELECT COUNT(*) AS number_of_rows,
 COUNT(DISTINCT UserID) AS number_subs
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;

--------------------------------------------------
--NULL Values
---------------------------------------------
SELECT COUNT(*) AS cnt
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`
WHERE UserID IS NULL;

SELECT DISTINCT UserID
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;
-------------------------------------------------
--GENDER CHECKS
-------------------------------------------------
SELECT DISTINCT Gender
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;

SELECT DISTINCT
 CASE
  WHEN Gender= 'None' THEN 'Unknown'
  WHEN Gender= ' ' THEN 'Unknown'
  WHEN Gender IS NULL THEN 'Unkown'
  ELSE Gender
  END AS sex
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;
---------------------------------------------------------
--Race Checks
---------------------------------------------------------

SELECT DISTINCT Race 
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;

SELECT COUNT(DISTINCT userid) AS SUBS,
    CASE 
        WHEN Race = ' ' THEN 'Unknown'
        WHEN Race IS NULL THEN 'Unknown'
        WHEN Race = 'None' THEN 'Unknown'
        WHEN Race = 'other' THEN 'Unknown'
    ELSE Race
    END AS Ethnicity
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`
GROUP BY Ethnicity;
-------------------------------------------------------------
--PROVINCE CHECK
------------------------------------------------------------
SELECT DISTINCT Province
FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;

SELECT DISTINCT
CASE
 WHEN Province = ' ' THEN 'Unknown'
 WHEN Province IS NULL THEN 'Unknown'
 WHEN Province = 'None' THEN 'Unknown'
 WHEN Province = 'other' THEN 'Unknown'
 ELSE Province
 END AS Region
 FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`;
 
 ------------------------------------------------------------
 --Age Checks
 -----------------------------------------------------------
 SELECT MIN(Age) AS min_age,
        MAX(Age) AS max_age,
        AVG(Age) AS mean_age

FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`


WITH `bright_tv_dataset` AS (
SELECT UserID,
 CASE
 WHEN Province=' ' THEN 'Uncategorized'
 WHEN Province='None' THEN 'Uncategorized'
 ELSE Province
 END AS Region,

Age,
 CASE 
  WHEN Age = 0 THEN 'Infant'
  WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
  WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
  WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
  WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
  WHEN Age > 50  AND Age <= 60 THEN ' ELDERLY'
  WHEN Age > 60 THEN 'PENSIONER'
 END AS age_group,
 
CASE
 WHEN (email IS NOT NULL )OR (email=' ') OR (email NOT IN ('None'))THEN 1
 ELSE 0
 END AS email_flag,

 CASE 
    WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`='' OR `Social Media Handle` NOT IN ('None') THEN 1
    ELSE 0
 END AS sm_flag,

CASE
 WHEN Race='other' THEN 'None'
 WHEN Race=' ' THEN 'None'
 ELSE Race
 END AS Race,
 CASE
 WHEN gender =' ' THEN 'None'
 ELSE gender
 END AS Gender

 FROM `brighttv_case_study`.`brighttv`.`bright_tv_dataset`),
 viewership AS (
 SELECT
 COALESCE(UserID0,userid4) AS userid,
 TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
 TO_DATE(RecordDate2) AS watch_date,
 --TIME(RecordDate2) AS watch_time,
 TO_CHAR(RecordDate2, 'DD') AS day_of_week,
 DAYNAME(RecordDate2) AS day_name,
 CASE
 WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
 ELSE 'weekday'
 END AS day_classification,
 MONTHNAME(RecordDate2) AS month_name,
 CASE
 WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
 WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events',
'DStv Events 1') THEN 'Live Events'
 ELSE Channel2
 END AS Tv_channel,
 date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
 CASE
 WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
 WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
 WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
 WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
 END AS time_of_day,
 DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
 CASE
 WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min'
 WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min'
 WHEN duration > '00:59:59' THEN '03. High Usage: >60 min'
 ELSE '04. No Usage'
 END AS screen_time_bucket,
 HOUR(RecordDate2) AS hour_of_day
FROM `brighttv_case_study`.`brighttv`.`viewership`
)

SELECT Coalesce(A.userid,B.userid) AS sub_id,
 month_id,
 watch_date,
 day_of_week,
 day_name,
 day_classification,
 month_name,
 Tv_channel,
 time_of_day,
 hour_of_day,
 screen_time_bucket,
 --user_flag,
 duration,
 Region,
 age_group,
 email_flag,
 sm_flag,
 Race,
 Gender
FROM viewership AS A
LEFT JOIN `bright_tv_dataset` AS B
ON A.userid=B.userid;















