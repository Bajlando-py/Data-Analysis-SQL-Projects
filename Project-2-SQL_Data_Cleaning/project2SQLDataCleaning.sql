-- 1. First look at data at hand

SELECT *
FROM ProjectDataCleaning..NashvilleHousing


--2. Standartize Date Format
-- First I tried UPDATE which had no effect in converting datetime type of SaleDate column into date type. So I used ALTER TABLE and ALTER COLUMN which succeeded. 

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

SELECT *
FROM ProjectDataCleaning..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

SELECT *
FROM ProjectDataCleaning..NashvilleHousing


--3. Populatin Property Address
-- Some values in PropertyAddress column were NULL values. In this query we found that all NULLs have ParcelID. This means we can use it to find the address.

SELECT *
FROM ProjectDataCleaning..NashvilleHousing
WHERE PropertyAddress IS NULL

-- 3.1 First step is to do SELF JOIN and find out if we can find PropertyAddress connected to ParcelID

SELECT t1.ParcelID, t2.ParcelID, t1.PropertyAddress, t2.PropertyAddress
FROM NashvilleHousing t1
JOIN NashvilleHousing t2 ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL 

-- 3.2 Then I upgraded the SQL code to fill NULL values with proper address

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleHousing t1
JOIN NashvilleHousing t2 ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL 


-- 4. Breaking out PropertyAddress into individual columns (Address, City) using substring.

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Street,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM ProjectDataCleaning..NashvilleHousing


-- 4.1 Adding splitted column into new columns to the table.

ALTER TABLE NashvilleHousing
ADD Street Varchar(255)

ALTER TABLE NashvilleHousing
ADD City Varchar(255);

UPDATE NashvilleHousing
SET Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--5. Breaking out OwnerAddress into individual columns (Address, City,State) using PARSENAME

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectDataCleaning..NashvilleHousing

--5.1 Adding splitted columns to the table

ALTER TABLE NashvilleHousing
ADD OwnerStreet Varchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerCity Varchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerState Varchar(255)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--6. Replacing Y and N in column SoldAsVacant to unified Yes and No, so we do not have four values (Y,N,Yes,No)
--First I found all distinct values present in SoldAsVacant column and their count.

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM ProjectDataCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--6.1 Replacing and unifying the values

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProjectDataCleaning..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--7. Removing duplicates
-- First I created CTE that will produce number for each row based on criteria that should be unique. So if there is number 2 and higher in RowNum That means the row is a duplicate.

With RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) RowNum
FROM ProjectDataCleaning..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE RowNum > 1


--8. Deleteing unused columns
-- Normally we do not do that. But here we previously splitted PropertyAddress and OwnerAddres so we do not need those two columns.

ALTER TABLE ProjectDataCleaning..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

