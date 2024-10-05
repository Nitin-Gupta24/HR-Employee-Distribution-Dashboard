CREATE DATABASE project_1;

USE project_1;

Select count(*) from hr;

SHOW TABLES;

DESCRIBE hr;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) Not NULL ;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0 ;

UPDATE hr
set birthdate = CASE
	WHEN birthdate LIKE "%-%" THEN date_format(str_to_date(birthdate , "%m-%d-%Y"), "%Y-%m-%d")
	WHEN birthdate LIKE "%/%" THEN date_format(str_to_date(birthdate , "%m/%d/%Y"), "%Y-%m-%d")
    ELSE NULL
END;     

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT birthdate FROM hr;

UPDATE hr
set hire_date = CASE
	WHEN hire_date LIKE "%-%" THEN date_format(str_to_date(hire_date , "%m-%d-%Y"), "%Y-%m-%d")
	WHEN hire_date LIKE "%/%" THEN date_format(str_to_date(hire_date , "%m/%d/%Y"), "%Y-%m-%d")
    ELSE NULL
END; 

ALTER TABLE hr
MODIFY COLUMN hire_date DATE; 

UPDATE hr
SET termdate = date(str_to_date(termdate , "%Y-%m-%d %H:%i:%sUTC"))
WHERE termdate IS NOT NULL AND termdate !="";

SELECT termdate FROM hr;

UPDATE hr
SET termdate = NULL
WHERE termdate = "" OR termdate IS NULL;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

SELECT termdate FROM hr;

desc hr;

-- adding age column

ALTER TABLE hr
ADD COLUMN age INT ;

UPDATE hr
SET age = timestampdiff(YEAR , birthdate , CURDATE());

SELECT birthdate, age from hr;

SELECT min(age) as Youngest ,
       max(age) as Oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;


--  Problem Statement 

-- 1. What is the gender breakdown of employees in the company?

SELECT gender , COUNT(*) as COUNT
FROM hr
WHERE age >=18 AND termdate IS NULL
GROUP BY 1;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race , COUNT(*) as COUNT
FROM hr
WHERE age >=18 AND termdate IS NULL
GROUP BY 1
ORDER BY COUNT(*) DESC;

-- 3. What is the age distribution of employees in the company?

SELECT min(age) as Youngest ,
       max(age) as Oldest
FROM hr 
WHERE age >= 18  and termdate IS NULL ;

SELECT CASE 
           WHEN age >= 18 AND age <=24 THEN '18-24'
           WHEN age >= 25 AND age <=34 THEN '25-34'
           WHEN age >= 35 AND age <=44 THEN '35-44'
           WHEN age >= 45 AND age <=54 THEN '45-54'
           WHEN age >= 55 AND age <=64 THEN '55-64'
           ELSE '65+'
        END AS age_group ,
        COUNT(*) AS count 
FROM hr
WHERE age >= 18  and termdate IS NULL 
GROUP BY age_group 
ORDER BY age_group;
       
       
SELECT CASE 
           WHEN age >= 18 AND age <=24 THEN '18-24'
           WHEN age >= 25 AND age <=34 THEN '25-34'
           WHEN age >= 35 AND age <=44 THEN '35-44'
           WHEN age >= 45 AND age <=54 THEN '45-54'
           WHEN age >= 55 AND age <=64 THEN '55-64'
           ELSE '65+'
        END AS age_group , gender ,
        COUNT(*) AS count 
FROM hr
WHERE age >= 18  and termdate IS NULL 
GROUP BY age_group , gender
ORDER BY age_group , gender ;  
     

-- 4. How many employees work at headquarters versus remote locations?

SELECT location , COUNT(*) as count 
FROM hr
WHERE age >= 18  and termdate IS NULL 
GROUP BY 1 ;


-- 5. What is the average length of employment for employees who have been terminated?

SELECT round(avg(datediff(termdate , hire_date)/356 ), 0 ) AS avg_length_employment
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL AND termdate <= curdate();

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department , gender , COUNT(*) AS count
FROM hr 
WHERE age >= 18 AND termdate IS NULL
GROUP BY 1,2
ORDER BY 1;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle , COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY 1
ORDER BY 1 DESC ;

-- 8. Which department has the highest turnover rate?

SELECT department , total_count , 
	   terminated_count , terminated_count/total_count AS terminated_rate
FROM (
	  SELECT department , COUNT(*) AS total_count ,
			 SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
      FROM hr
      WHERE age >= 18
      GROUP BY 1
      ) AS derived_sub_query
ORDER BY terminated_rate DESC ;    
      

-- 9. What is the distribution of employees across locations by city and state?

SELECT location_state , COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY 1
ORDER BY count DESC ;

SELECT location_city, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY 1
ORDER BY count DESC ;


-- 10. How has the company's employee count changed over time based on hire and term dates? 

SELECT 
      year , hires , terminations , 
      hires - terminations AS net_change,
      round((hires - terminations)/hires * 100 , 2 ) AS net_percent_change
FROM (
       SELECT 
             YEAR(hire_date) AS year,
             COUNT(*) AS hires ,
             SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
       FROM hr
       WHERE age >= 18
       GROUP BY 1 
       ) AS sub_query
ORDER BY year ASC ;

-- 11. What is the tenure distribution for each department?
  
  SELECT department , round(avg(datediff(termdate , hire_date)/365 ), 0) AS avg_tenure
  FROM hr
  WHERE  termdate <= curdate() AND termdate IS NOT NULL AND age >= 18
  GROUP BY 1;
  
  