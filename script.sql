-- =====================================================
-- Project: Data Cleaning - MySQL
-- Table: layoffs
-- Description: Cleaning raw layoff data for analysis
-- =====================================================

-- Step 0: Preview the raw data
SELECT *
FROM layoffs;

-- Step 1: Create a staging table for cleaning
CREATE TABLE layoffs_staging LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Step 2: Populate the staging table with raw data
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- =====================================================
-- 1) Remove Duplicates
-- =====================================================

-- Identify duplicates using ROW_NUMBER() over groups
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`,
               stage, country, funds_raised_millions
           ) AS Row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE Row_num > 1;

-- Preview specific company to check duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Optional: Backup original staging table before deletion
-- CREATE TABLE layoffs_staging2 AS SELECT * FROM layoffs_staging;

-- Create a new table including a row number column
CREATE TABLE layoffs_staging2 (
  company TEXT DEFAULT NULL,
  location TEXT DEFAULT NULL,
  industry TEXT DEFAULT NULL,
  total_laid_off INT(11) DEFAULT NULL,
  percentage_laid_off TEXT DEFAULT NULL,
  `date` TEXT DEFAULT NULL,
  stage TEXT DEFAULT NULL,
  country TEXT DEFAULT NULL,
  funds_raised_millions INT(11) DEFAULT NULL,
  Row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Preview the new table
SELECT * 
FROM layoffs_staging2;

-- Populate the new table and generate row numbers
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`,
           stage, country, funds_raised_millions
       ) AS Row_num
FROM layoffs_staging;

-- Delete duplicate rows (keep the first occurrence)
DELETE
FROM layoffs_staging2
WHERE Row_num > 1;

-- Verify duplicates are removed
SELECT *
FROM layoffs_staging2
WHERE Row_num > 1;

-- Preview final table after deletion
SELECT *
FROM layoffs_staging2;


-- =====================================================
-- 2) Standardize Data
-- =====================================================

-- Remove leading/trailing spaces in company names
SELECT DISTINCT(TRIM(company)) FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry values
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize location and country
SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%' 
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Remove trailing dots from country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Standardize date column
SELECT `date` FROM layoffs_staging2;

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change date column type from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- =====================================================
-- 3) Fix NULLs and blanks
-- =====================================================

-- Check rows with missing numeric values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Replace empty strings in industry with NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Verify updated industry values
SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Fill missing industry values based on other rows with same company/location
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Delete rows where critical numeric data is missing
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
  -- Remove the temporary 'Row_num' column
-- This column was only needed to identify and delete duplicates
-- After cleaning, it is no longer required, so we drop it for a clean table

ALTER TABLE layoffs_staging2
DROP COLUMN Row_num;
  

-- =====================================================
-- 4) Final Clean Table
-- =====================================================

SELECT *
FROM layoffs_staging2;
