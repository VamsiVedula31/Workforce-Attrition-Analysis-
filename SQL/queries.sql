#								Workforce Attrition Analysis

USE DD_Project;

START TRANSACTION;

SHOW TABLES;
SELECT * FROM hr_data_updated;
DESCRIBE hr_data_updated;

SAVEPOINT sp_draft;

# Renaming Table Name to hr_data
RENAME TABLE hr_data_updated TO hr_data;

SELECT * FROM hr_data;

SAVEPOINT sp1_rename_table;					# SAVEPOINT --> (1)

# Removing duplicate entries 
					
SELECT Employee_ID,		
	ROW_NUMBER() OVER (PARTITION BY Employee_ID, Employee_Name 		# Identifying duplicate entires.
    ORDER BY Employee_ID) AS rn
    FROM hr_data;
    
SET SQL_SAFE_UPDATES=0;						# Disabling Safe Updates
SELECT @@SQL_SAFE_UPDATES;					# Confirming its Off

WITH Remove_Duplicates AS(											# Removing duplicate records, if any.
	SELECT Employee_ID,
	ROW_NUMBER() OVER (PARTITION BY Employee_ID, Employee_Name 
    ORDER BY Employee_ID) AS rn
    FROM hr_data
)  
DELETE FROM hr_data
WHERE Employee_ID IN (
	SELECT Employee_ID 
	FROM Remove_Duplicates
    WHERE rn>1);

SAVEPOINT sp2_remove_duplicates			# SAVEPOINT --> (2)

-- Checking for NULLS in Employee_ID 	(none found, so no need to remove any records)

SELECT * FROM hr_data
WHERE Employee_ID IS NULL;

-- Replacing NULL values, if any in Gender and Age

UPDATE hr_data
SET 
	Age = IFNULL(Age,0),
    Gender = IFNULL(Gender,'Unknown');
    
SAVEPOINT sp_3_null_replacements; 		# Null Identification in Emp_ID & Replacements if any in Age & Gender 

-- Identifying a Median Hire_Date to replace & impute the Null values within.   --> 22-02-19
WITH Ordered_Hire_Date AS (
	SELECT HireDate_dt,
			ROW_NUMBER() OVER (ORDER BY HireDate_dt) AS rn,
            COUNT(*) OVER () AS Total_Rows
	FROM hr_data
),

Median_Date AS (
	SELECT HireDate_dt
    FROM Ordered_Hire_Date
    WHERE rn = FLOOR((Total_Rows + 1) / 2)
		OR rn =CEIL((Total_Rows + 1) / 2)
)

SELECT DATE(AVG(HireDate_dt)) AS Median_Hire_Date				# Median Hire_Date --> 22-02-19
FROM Median_Date;										

-- Replacing the nulll values in Hire_date with the median date

UPDATE hr_data
SET HireDate_dt = '2022-02-19'
WHERE HireDate_dt IS NULL;

SAVEPOINT sp_4_median_imputation_hire_date;			# Median imputation of hire date replacing nulls if any.

SELECT MIN(Age) FROM hr_data;  -- > Minimum Age - 25 Years
SELECT MAX(Age) FROM hr_data;  -- > Maximum Age - 40 years

-- Identifying mismatches in the Position Column

SELECT DISTINCT Position,
CASE 
	WHEN LOWER(Position) LIKE "%account%" AND LOWER(Position) LIKE '%exec%' THEN 'Account Executive'
    WHEN LOWER(Position) LIKE "%Data%" AND LOWER(Position) LIKE '%Analyst%' THEN 'Data Analyst'
    ELSE 'Others'
END AS Standardized_Position
FROM hr_data
WHERE 
	(LOWER(Position) LIKE "%account%" AND LOWER(Position) LIKE '%exec%')
    OR 
    (LOWER(Position) LIKE "%Data%" AND LOWER(Position) LIKE '%Analyst%')
;

SELECT DISTINCT Position FROM hr_data;

-- Standardization of Records in the Position Column

UPDATE hr_data
SET Position =
	CASE 
		WHEN LOWER(Position) LIKE "%account%" AND LOWER(Position) LIKE '%exec%' THEN 'Account Executive'
		WHEN LOWER(Position) LIKE "%Data%" AND LOWER(Position) LIKE '%Analyst%' THEN 'Data Analyst'
		ELSE 'Others'
	END
WHERE 
	(LOWER(Position) LIKE "%account%" AND LOWER(Position) LIKE '%exec%')
    OR 
    (LOWER(Position) LIKE "%Data%" AND LOWER(Position) LIKE '%Analyst%')
    ;

SELECT DISTINCT Position FROM hr_data;

SAVEPOINT sp_standardization_position;			# Standardization of records in Position Column.

COMMIT;

# Identifying Mismatches in Gender Column

SELECT Gender,
	CASE 
		WHEN LOWER(Gender) = 'm' THEN "Male"
        WHEN LOWER(Gender) = 'f' THEN "Female"
	END
FROM hr_data	
    WHERE Gender IN ('m', 'f');
    
# Standardization of Records in Gender Column

UPDATE hr_data
SET Gender = 
	CASE 
		WHEN LOWER(Gender) = 'm' THEN "Male"
        WHEN LOWER(Gender) = 'f' THEN "Female"
	END	
WHERE Gender IN ('m', 'f');

SELECT DISTINCT Gender FROM hr_data;

START TRANSACTION;

SAVEPOINT sp6_standardization_gender;			# Standardization of Gender Column

# Imputing Median values for Age groups --> for better analysis.

WITH ordered AS (
    SELECT 
        Age, 
        ROW_NUMBER() OVER (ORDER BY Age) AS rn,
        COUNT(*) OVER () AS total_count
    FROM hr_data
    WHERE Age IS NOT NULL
),
median_cte AS (
    SELECT 
        CASE 
            WHEN total_count % 2 = 1 
                THEN CAST(MAX(CASE WHEN rn = (total_count + 1)/2 THEN Age END) AS DECIMAL(10,2))
            ELSE CAST(AVG(CASE WHEN rn IN (total_count/2, total_count/2 + 1) THEN Age END) AS DECIMAL(10,2))
        END AS median_age
    FROM ordered
    GROUP BY total_count
)

UPDATE hr_data
JOIN median_cte ON 1=1
SET Age = median_cte.median_age
WHERE Age IS NULL;

SAVEPOINT sp7_median_imputation_age;			# Median Imputation of AGE column

COMMIT;

# Creating Customer Tenure Groups (Ealy, Mid, Senior)

SELECT DISTINCT Years_of_Service FROM hr_data ORDER BY Years_of_Service ASC;

ALTER TABLE hr_data 
ADD COLUMN Tenure_Groups VARCHAR(20)
GENERATED ALWAYS AS (					#This column will always be automatically calcualted from other columns, never type a value into it by self.
	CASE 
		WHEN Years_of_Service BETWEEN 0 AND 3 THEN 'Early Career'
        WHEN Years_of_Service BETWEEN 4 AND 7 THEN 'Mid Career'
        ELSE 'Senior'
	END
) STORED; 

# Creating Customer Age Groups ()

SELECT DISTINCT Age FROM hr_data ORDER BY Age Asc;

ALTER TABLE hr_data
ADD COLUMN Age_Groups VARCHAR(20)
GENERATED ALWAYS AS (
	CASE 
		WHEN Age < 30 THEN 'Young'
        WHEN Age BETWEEN 30 AND 39 THEN 'Adult'
        ELSE 'Senior'
	END
) STORED;

# UNIVARIATE ANALYSIS 

# Frequency Distribution

# Department Frequency
CREATE VIEW vw_employee_count_by_department AS
SELECT Department, COUNT(*) AS Employee_Count
FROM hr_data
GROUP BY Department;

# Gender Frequency
CREATE VIEW vw_employee_Count_by_gender AS 
SELECT Gender, COUNT(*) AS Employee_Count
FROM hr_data
GROUP BY Gender;

# Education Frequency 
CREATE VIEW vw_employee_count_by_education AS
SELECT Education_Level, COUNT(*) AS Employee_Count
FROM hr_data
GROUP BY Education_Level;

# Central Tendencies 

CREATE VIEW vw_summary_statistics AS 
SELECT 
	AVG(Salary) AS avg_salary,
    MIN(Salary) AS min_salary,
    MAX(salary) AS max_salary,
    
    AVG(Age) AS avg_age,
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    
    AVG(Employee_Engagement_Score) AS avg_engagement_score,
    MIN(Employee_Engagement_Score) AS min_engagement_score,
    MAX(Employee_Engagement_Score) AS max_engagement_score,
    
    AVG(Training_Hours) AS avg_training_hours,
    MIN(Training_Hours) AS min_training_hours,
    MAX(Training_Hours) AS max_training_hours
FROM hr_data;

# Attrition % 
# Pre-Calculated Attrition rates :-
USE dd_project;
# Attrition % by Departement
CREATE VIEW attrition_by_department AS
SELECT Department, 
		ROUND(
			(COUNT(ExitDate_dt)*1.0/COUNT(*)) * 100, 2
		) AS attrition_percentage
FROM hr_data
GROUP BY Department;

# Attrition % by Position
CREATE VIEW attrition_by_position AS
SELECT Position,
		ROUND(
			(COUNT(ExitDate_dt)*1.0/COUNT(*)) * 100, 2
        ) AS attrition_percentage
FROM hr_data
GROUP BY Position;

# Attrition % by Gender
CREATE VIEW attrition_by_gender AS 
SELECT Gender,
		ROUND(
			(COUNT(ExitDate_dt)* 1.0/COUNT(*)) * 100, 2
        ) AS attrition_percentage
FROM hr_data
GROUP BY Gender;

# Stored Procedure With YEAR as Input Parameter --> Attrtition rate by Department

DELIMITER $$ 

CREATE PROCEDURE Get_Attrition_By_Department(IN pYear INT)
BEGIN
    SELECT 
        Department,
        ROUND(
            COUNT(CASE WHEN ExitDate_dt IS NOT NULL 
                       AND YEAR(ExitDate_dt) = pYear THEN 1 END) * 100.0
            / COUNT(*), 
            2
        ) AS Attrition_Rate
    FROM hr_data
    GROUP BY Department;
END $$
DELIMITER ;

CALL Get_Attrition_By_Department(2022);

# Stored Procedure Attririton Rate by Gender

DELIMITER $$
CREATE PROCEDURE Get_Attrition_By_Gender(IN pYear INT)
BEGIN 
	SELECT 
		Gender,
        ROUND(
			COUNT(CASE WHEN ExitDate_dt IS NOT NULL AND YEAR(ExitDate_dt) = pYear THEN 1 END)* 100.0
            /COUNT(*),
            2
		) AS Attrition_Rate
	FROM hr_data
    GROUP BY Gender;
END $$ 
DELIMITER ;

CALL Get_Attrition_By_Gender(2023);

SELECT * FROM hr_data;


