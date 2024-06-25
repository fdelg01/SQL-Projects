  /*

  Cleaning Data in SQL Queries

  */


 Select * 
 From PortfolioProjects.dbo.NashvilleHousing

 ------------------------------------------------------------------------------------------- 
  -- Standardize Date Format

 Select SaleDate
 From PortfolioProjects.dbo.NashvilleHousing
 ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE


 ------------------------------------------------------------------------------------------
 -- Populate Property Address Data

 Select *
 From PortfolioProjects.dbo.NashvilleHousing
 --Where PropertyAddress is null
 Order by ParcelID

 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProjects.dbo.NashvilleHousing a
 JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProjects.dbo.NashvilleHousing a
 JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

 ------------------------------------------------------------------------------------------

 -- Breaking out Address into Individual Columns

 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

 From PortfolioProjects.dbo.NashvilleHousing

 ALTER TABLE NashvilleHousing
 ADD PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

 ALTER TABLE NashvilleHousing
 ADD PropertySplitCity Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProjects.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitState Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

 ------------------------------------------------------------------------------------------

 -- Change Y and N to Yes and No in "Sold as Vacant" field

 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
 FROM PortfolioProjects.dbo.NashvilleHousing
 Group by SoldAsVacant
 Order by 2

 Select SoldAsVacant
 , CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
 FROM PortfolioProjects.dbo.NashvilleHousing

 Update NashvilleHousing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End

------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProjects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress