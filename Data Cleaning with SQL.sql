/*Data Cleaning in SQL

*/

	SELECT *
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]
  

--------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]

--create new column-SalesDateConverted which converts the SaleDate from timestamp to date type
ALTER TABLE Nashville_Housing
ADD newSaleDate Date;

UPDATE Nashville_Housing
SET newSaleDate= CONVERT(Date, SaleDate);

--check for changes
SELECT newSaleDate, SaleDate
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]




--------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
SELECT PropertyAddress
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]

--check for null values
SELECT *
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]
  WHERE PropertyAddress is null

SELECT *
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]
--  WHERE PropertyAddress is null
ORDER BY ParcelID

--Same parcelIDs seem to have identical property addresses. This means that the same parcel id= the smae property address. We will do a self join to populate the column.  
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM [NashvileHousing ].[dbo].[Nashville_Housing] as a 
  Join [NashvileHousing ].[dbo].[Nashville_Housing] as b
  On a.ParcelID = b.ParcelID
  And a.[UniqueID ]<>b.[UniqueID ]
  where a.PropertyAddress is null

--UPDATE THE TABLE
UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [NashvileHousing ].[dbo].[Nashville_Housing] as a 
  Join [NashvileHousing ].[dbo].[Nashville_Housing] as b
  On a.ParcelID = b.ParcelID
  And a.[UniqueID ]<>b.[UniqueID ]
   where a.PropertyAddress is null



-------------------------------------------------------------------------------------------------------------------------------
--Break out Address Columns into individual Columns(Address, City, State)
--Start with Property Address using SUBSTRING method
SELECT PropertyAddress
  FROM [NashvileHousing ].[dbo].[Nashville_Housing]

--Create City and Address using Substring
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City


FROM [NashvileHousing ].[dbo].[Nashville_Housing]
--update the table with the Split Address and  City columns
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress varchar(255);

UPDATE Nashville_Housing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) ;

ALTER TABLE Nashville_Housing
ADD PropertySplitCity varchar(255);

UPDATE Nashville_Housing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

--lets do the same to the OwnerAddress column in a different way 

Select OwnerAddress
fROM Nashville_Housing

--uSE PARSENAME to split the solumn into 3
Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
fROM Nashville_Housing

--Update the columns into the table
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress varchar(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity varchar(255);

UPDATE Nashville_Housing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
 

ALTER TABLE Nashville_Housing
ADD OwnerSplitState varchar(255);

UPDATE Nashville_Housing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)




----------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes in SoldVacant Column

Select Distinct SoldAsVacant, Count(SoldAsVacant)
fROM Nashville_Housing
Group By SoldAsVacant
order By 2;

--use a Case statement to change Y to Yes and N to No
Select SoldAsVacant,
 Case When SoldAsVacant = 'Y' then 'Yes'
	  When SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End
fROM Nashville_Housing;

--update the table
Update Nashville_Housing
Set SoldAsVacant= Case When SoldAsVacant = 'Y' then 'Yes'
	  When SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End;




--------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
Select Count(*)

fROM Nashville_Housing;

--remove duplicates with cte and window functions

With RowNumCTE AS(
Select *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 LegalReference
					 Order By 
						UniqueID
						) row_num
fROM Nashville_Housing)
--Order By ParcelID;

Delete
from RowNumCTE
where row_num>1
--order by PropertyAddress






-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Unused Columns 

Select *

fROM Nashville_Housing;

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate

ALTER TABLE Nashville_Housing
DROP COLUMN SalesDateConverted