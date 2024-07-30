--View table
SELECT * FROM healthcare_dataset;


--Removing title prefixes and suffixes in the Names column
UPDATE healthcare_dataset
SET Name = 
    CASE 
        WHEN UPPER(LEFT(Name, 4)) = 'MRS.' THEN LTRIM(RTRIM(SUBSTRING(Name, 5, LEN(Name) - 4)))
        WHEN UPPER(LEFT(Name, 3)) IN ('DR.', 'MR.') THEN LTRIM(RTRIM(SUBSTRING(Name, CHARINDEX(' ', Name) + 1, LEN(Name))))
        WHEN UPPER(RIGHT(Name, 2)) = 'MD' THEN LTRIM(RTRIM(SUBSTRING(Name, 1, LEN(Name) - 2)))
        WHEN UPPER(RIGHT(Name, 3)) = 'DDS' THEN LTRIM(RTRIM(SUBSTRING(Name, 1, LEN(Name) - 3)))
        WHEN UPPER(RIGHT(Name, 3)) = 'JR.' THEN LTRIM(RTRIM(SUBSTRING(Name, 1, LEN(Name) - 3)))
        ELSE Name
    END
WHERE UPPER(LEFT(Name, 4)) = 'MRS.' 
   OR UPPER(LEFT(Name, 3)) IN ('DR.', 'MR.')
   OR UPPER(RIGHT(Name, 2)) = 'MD' 
   OR UPPER(RIGHT(Name, 3)) IN ('DDS', 'JR.');

--Splitting names into first name column and last name columns
ALTER TABLE healthcare_dataset
ADD FirstName VARCHAR(255), 
    LastName VARCHAR(255);
	
UPDATE healthcare_dataset
SET 
    FirstName = LEFT(Name, CHARINDEX(' ', Name) - 1),
    LastName = SUBSTRING(Name, CHARINDEX(' ', Name) + 1, LEN(Name) - CHARINDEX(' ', Name))
WHERE CHARINDEX(' ', Name) > 0;


-- Update FirstName column
UPDATE healthcare_dataset
SET FirstName = UPPER(LEFT(FirstName, 1)) + LOWER(SUBSTRING(FirstName, 2, LEN(FirstName) - 1));


-- Update LastName column
UPDATE healthcare_dataset
SET LastName = UPPER(LEFT(LastName, 1)) + LOWER(SUBSTRING(LastName, 2, LEN(LastName) - 1));


--Deleting Name column
ALTER TABLE healthcare_dataset
DROP COLUMN Name;


--Remove timestamp from Date of Admission 
ALTER TABLE healthcare_dataset
ALTER COLUMN [Date of Admission] DATE;

UPDATE healthcare_dataset
SET [Date of Admission] = CAST([Date of Admission] AS DATE);

SELECT [Date of Admission]
FROM healthcare_dataset;


--Remove timestamp from Discharge Date
ALTER TABLE healthcare_dataset
ALTER COLUMN [Discharge Date] DATE;

UPDATE healthcare_dataset
SET [Discharge Date] = CAST([Discharge Date] AS DATE);

SELECT [Discharge Date]
FROM healthcare_dataset;


--Round up billing amount to 2 decimal places
UPDATE healthcare_dataset
SET [Billing Amount] = ROUND([Billing Amount], 2);


--Cleaning Hospital names Part 1 - Removing leading 'and ', trailing ',' 
UPDATE healthcare_dataset
SET Hospital = LTRIM(
    CASE
        WHEN Hospital LIKE 'and %' THEN 
            LTRIM(
                CASE
                    WHEN RIGHT(SUBSTRING(Hospital, 4, LEN(Hospital) - 3), 1) = ',' THEN 
                        LEFT(SUBSTRING(Hospital, 4, LEN(Hospital) - 3), LEN(SUBSTRING(Hospital, 4, LEN(Hospital) - 3)) - 1)
                    ELSE 
                        SUBSTRING(Hospital, 4, LEN(Hospital) - 3)
                END
            )
        WHEN RIGHT(Hospital, 1) = ',' THEN 
            LEFT(Hospital, LEN(Hospital) - 1)
        ELSE Hospital
    END
)
WHERE Hospital LIKE 'and %' OR Hospital LIKE '%,';


--Cleaning Hospital Names Part 2 - Removing trailing ', and'
UPDATE healthcare_dataset
SET Hospital = CASE
    WHEN Hospital LIKE '% and' THEN LEFT(Hospital, LEN(Hospital) - 5)
    ELSE Hospital
END
WHERE Hospital LIKE '%, and';


--Cleaning Hospital Names Part 3 -
UPDATE healthcare_dataset
SET Hospital = REPLACE(
    CASE
        -- Remove trailing ' and'
        WHEN RIGHT(Hospital, 4) = ' and' THEN LEFT(Hospital, LEN(Hospital) - 4)
        ELSE Hospital
    END,
    ', and',
    ' and'
)
WHERE Hospital LIKE '% and' OR Hospital LIKE '%, and%';


--Rename FirstName column to First Name and LastName column to Last Name for data naming standardisation
EXEC sp_rename 'healthcare_dataset.firstName', 'First Name', 'COLUMN';
EXEC sp_rename 'healthcare_dataset.lastName', 'Last Name', 'COLUMN';


--Rename Date of Admission colum to Admission Date
EXEC sp_rename 'healthcare_dataset.[Date of Admission]', 'Admission Date', 'COLUMN';
