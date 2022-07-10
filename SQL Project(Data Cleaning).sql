/*

Cleaning Data in SQL Queries

Importing of Excel Data into MSSQL
*/ 

SELECT * FROM dbo.NashvilleHousing


----------------------------------
-- Standardize SaleDate
SELECT saledate, CONVERT(DATE,saledate)
FROM dbo.NashvilleHousing 

--UPDATE NashvilleHousing
--SET saledate = CONVERT(DATE,saledate)

ALTER TABLE NashvilleHousing
ADD saledateconverted DATE;

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(DATE,saledate)




----------------------------------------------
--Populate missing Property Address Data
SELECT *
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- SELF JOIN 
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM NashvilleHousing


-- SUBSTRING() FUNCTION
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(Propertyaddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(Propertyaddress))


-- PARSENAME() FUNCTION
SELECT owneraddress 
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)

SELECT * 
FROM NashvilleHousing


------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC


SELECT soldasvacant,
CASE 
	WHEN soldasvacant = 'Y' THEN 'YES'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
END 
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE 
	WHEN soldasvacant = 'Y' THEN 'YES'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
END


----------------------------------------------------
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
		) row_num

FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1



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
		) row_num

FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------------------------------------------------
-- DELETE unused Columns

SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

