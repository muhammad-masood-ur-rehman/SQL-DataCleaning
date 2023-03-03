												/* Cleaning Data using SQL Queries */

select * from DataCleaningProjectSql.dbo.UncleanedData

----------------------------------------------------- Standardize Date Format-------------------------------------


select SalesDateConverted, convert(Date, SaleDate) from DataCleaningProjectSql.dbo.UncleanedData

update UncleanedData set SaleDate =  convert(Date, SaleDate)

alter table UncleanedData add SalesDateConverted Date; 

update UncleanedData set SalesDateConverted = convert(Date, SaleDate)

-------------------------------------------------- Populate Property Address Data--------------------------------------

select * from DataCleaningProjectSql.dbo.UncleanedData where PropertyAddress IS NULL order by ParcelID

select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress) 
	from [DataCleaningProjectSql].dbo.UncleanedData a
	JOIN [DataCleaningProjectSql].dbo.UncleanedData b on a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress IS NULL;

update a set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
	from [DataCleaningProjectSql].dbo.UncleanedData a
	JOIN [DataCleaningProjectSql].dbo.UncleanedData b on a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress IS NULL;

--------------------------------Breaking out Address into Individual Columns (Address, City, State)--------------------

Select PropertyAddress
From DataCleaningProjectSql.dbo.UncleanedData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From DataCleaningProjectSql.dbo.UncleanedData


ALTER TABLE UncleanedData
Add PropertySplitAddress Nvarchar(255);

Update UncleanedData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE UncleanedData
Add PropertySplitCity Nvarchar(255);

Update UncleanedData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From DataCleaningProjectSql.dbo.UncleanedData

Select OwnerAddress
From DataCleaningProjectSql.dbo.UncleanedData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DataCleaningProjectSql.dbo.UncleanedData

ALTER TABLE UncleanedData
Add OwnerSplitAddress Nvarchar(255);

Update UncleanedData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE UncleanedData
Add OwnerSplitCity Nvarchar(255);

Update UncleanedData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE UncleanedData
Add OwnerSplitState Nvarchar(255);

Update UncleanedData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From DataCleaningProjectSql.dbo.UncleanedData

--------------------------------------Change Y and N to Yes and No in "Sold as Vacant" field---------------------------

select distinct(SoldAsVacant) from DataCleaningProjectSql.dbo.UncleanedData

update DataCleaningProjectSql.dbo.UncleanedData set SoldAsVacant = CASE 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end

select distinct(SoldAsVacant) from DataCleaningProjectSql.dbo.UncleanedData

-------------------------------------------------------- Remove Duplicates---------------------------------------------

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaningProjectSql.dbo.UncleanedData
--order by ParcelID
)

Select * From RowNumCTE Where row_num > 1 Order by PropertyAddress

Select * From DataCleaningProjectSql.dbo.UncleanedData


------------------------------------------------------- Drop Unused Columns -------------------------------------------

Select * From DataCleaningProjectSql.dbo.UncleanedData


ALTER TABLE DataCleaningProjectSql.dbo.UncleanedData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
