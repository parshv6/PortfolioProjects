
/*
Cleaning data in SQL Queries
*/

select *
From PortfolioProject.dbo.Nash 

----------------------------------------------------------------------------------

--Standardize Date Format

select SaleDate, Convert(date,saledate)
From PortfolioProject.dbo.Nash

Update PortfolioProject..Nash
SET saledate = Convert(date,saledate)

Alter Table PortfolioProject..Nash
ADD SaleDateConverted date

Update PortfolioProject..Nash
SET SaleDateConverted = Convert(date,saledate)

Select SaleDateConverted,saledate
From PortfolioProject.dbo.Nash

---------------------------------------------------------------------------------------------------

--POPULATE property Address data( where propertyadress are null)


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nash a
JOIN  PortfolioProject.dbo.Nash b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nash a
JOIN  PortfolioProject.dbo.Nash b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, Ciy, State)

Select SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
from PortfolioProject.dbo.Nash


Alter Table PortfolioProject..Nash
ADD PropertySplitAddress  Nvarchar(255)

Update PortfolioProject..Nash
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)


Alter Table PortfolioProject..Nash
ADD PropertySplitCity Nvarchar(255)

Update PortfolioProject..Nash
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


Select PropertySplitCity,PropertySplitAddress
from PortfolioProject.dbo.Nash


--Split OwnerAddress from CITY, state, Address (Using Parsename)
--parsename used only by (.) not by any other special char

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.Nash



Alter Table PortfolioProject..Nash
ADD OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..Nash
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


Alter Table PortfolioProject..Nash
ADD OwnerSplitCity Nvarchar(255)

Update PortfolioProject..Nash
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


Alter Table PortfolioProject..Nash
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProject..Nash
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject.dbo.Nash

-------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as vacant' field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.Nash
Group by SoldAsVacant
order by 2

select  SoldAsVacant,
 Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End
from PortfolioProject.dbo.Nash

Update PortfolioProject.dbo.Nash
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End

---------------------------------------------------------------------------------------------

--Remove Dplicates (Using CTE functions)

With RowNumCTE AS (
Select * ,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelId,
			  PropertyAddress,
			  SalePrice,
			  LegalReference
			  Order by 
				UniqueID
				) row_num
 from PortfolioProject.dbo.Nash
)
select * 
From RowNumCTE
where row_num > 1
--Order By PropertyAddress

------------------------------------------------------------------------------------------------------

--delete unused columns using alter table method 

Select *
from PortfolioProject.dbo.Nash


Alter Table PortfolioProject.dbo.Nash
Drop column OwnerAddress,TaxDistrict, PropertyAddress


Alter Table PortfolioProject.dbo.Nash
Drop column SaleDate