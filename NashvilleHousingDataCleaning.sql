Select *
From 
	PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardise Date Format
--Part 1
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Part 2
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

-- Populate Property Address data
Select *
From 
	PortfolioProject..NashvilleHousing
-- WHERE
	--PropertyAddress IS NULL
ORDER BY
	ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From 
	PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL 

--Break down address, city and state into individual columns
SELECT
	*
FROM 
	PortfolioProject..NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)) AS City
FROM
	PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD 
	PropertySplitAddress NVARCHAR(255);
UPDATE 
	NashvilleHousing
SET 
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD 
	PropertySplitCity NVARCHAR(255);
UPDATE 
	NashvilleHousing
SET 
	PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress))

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD 
	OwnerSplitAddress NVARCHAR(255);
UPDATE 
	NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD 
	OwnerSplitCity NVARCHAR(255);
UPDATE 
	NashvilleHousing
SET 
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD 
	OwnerSplitState NVARCHAR(255);
UPDATE 
	NashvilleHousing
SET 
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y to Yes and N to No for SoldAsVacant
SELECT
	Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM
	PortfolioProject..NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2

UPDATE
	NashvilleHousing
SET
	SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END

--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) RowNumber

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM
	RowNumCTE
Where RowNumber > 1
-- ORDER BY	PropertyAddress

--Delete unused columns
SELECT *
FROM
	PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate