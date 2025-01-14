-- Exploratory Data Analysis (EDA)

-- Exploring the dataset to identify trends, patterns, and anomalies such as outliers.
-- The goal is to gain a deeper understanding of the data.

-- Displaying all records from the staging table
SELECT * 
FROM world_layoffs.layoffs_staging2;

-- Basic Queries to Extract Key Insights

-- Finding the maximum number of employees laid off in a single record
SELECT MAX(total_laid_off) AS max_laid_off
FROM world_layoffs.layoffs_staging2;

-- Analyzing the percentage of layoffs
-- Finding the maximum and minimum layoff percentages (excluding NULL values)
SELECT MAX(percentage_laid_off) AS max_percentage, MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Identifying companies with 100% layoffs (percentage_laid_off = 1)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;

-- Observations: These are primarily startups that ceased operations during this period.

-- Sorting 100% layoffs by the amount of funds raised (in millions)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Insight: Companies like BritishVolt (an EV company) and Quibi raised significant funds but eventually failed.

-- Advanced Grouped Queries

-- Identifying companies with the largest single layoff event
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the highest total layoffs across all records
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Total layoffs by location
SELECT location, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;

-- Total layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Layoffs by year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Complex Queries

-- Analyzing yearly top companies by total layoffs
WITH Company_Year AS (
  SELECT 
    company, 
    YEAR(date) AS year, 
    SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT 
    company, 
    year, 
    total_laid_off, 
    DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS rank
  FROM Company_Year
)
SELECT 
  company, 
  year, 
  total_laid_off, 
  rank
FROM Company_Year_Rank
WHERE rank <= 3
AND year IS NOT NULL
ORDER BY year ASC, total_laid_off DESC;

-- Calculating a rolling total of layoffs per month
WITH DATE_CTE AS (
  SELECT 
    SUBSTRING(date, 1, 7) AS month, 
    SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY month
  ORDER BY month ASC
)
SELECT 
  month, 
  SUM(total_laid_off) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY month ASC;
