﻿-- =============================================
-- CREATE NEW TABLE FILTERED_PARCEL
-- not interested values are dropped
-- =============================================


IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'FILTERED_PARCEL'))
BEGIN
	DROP TABLE FILTERED_PARCEL
END
     
SELECT  *
	INTO FILTERED_PARCEL FROM PARCEL
	WHERE LS1_Sale_Date > 20150000
      and LS1_Sale_Amount != 9
      and LS1_Sale_Amount != 0
      and LS1_Sale_Amount != 999999999;


DELETE FROM FILTERED_PARCEL
WHERE Zoning_Code IS NULL
GO

-- =============================================
-- Get data from Zoning_Code column
-- Adding and filling new column Simple_Zoning_Code
-- Adding and filling new column City
-- Adding new column Price_Per_Single_Area_Unit 
-- Adding new column Parcel_Area
-- =============================================

IF (NOT EXISTS (select * from information_schema.COLUMNS where TABLE_NAME = 'FILTERED_PARCEL' and COLUMN_NAME = 'Simple_Zoning_Code'))
	BEGIN
		ALTER TABLE FILTERED_PARCEL
			ADD 
				Simple_Zoning_Code NVARCHAR(15),
				City NVARCHAR(5),
				Price_Per_Single_Area_Unit INT,
				Parcel_Area INT
	END
GO

UPDATE FILTERED_PARCEL
  SET City=substring(Zoning_Code,1,2)
GO

-- =============================================
-- Get data from connected to parcel area
-- data from Shape geometry column
-- =============================================


UPDATE FILTERED_PARCEL
  SET Parcel_Area=Shape.STArea()
GO

UPDATE FILTERED_PARCEL
  SET Price_Per_Single_Area_Unit=(LS1_Sale_Amount/(Parcel_Area+1))
GO


-- =============================================
-- ADD NEW COLUMNS FOR BASIC AREAS TYPES
-- ============================================= to jest dodatkowe

--IF (NOT EXISTS (select * from information_schema.COLUMNS where TABLE_NAME = 'FILTERED_PARCEL' and COLUMN_NAME =))
BEGIN
	ALTER TABLE FILTERED_PARCEL
  ADD 
	Residential SMALLINT, 
	Special_Purposes_Plan SMALLINT, 
	Agricultural SMALLINT, 
	Commercial SMALLINT,
	Manufacturing SMALLINT
END
GO

-- =============================================
-- Parse Zoning codes
-- RESIDENTIAL
-- R1 - single family residence
-- R2 - two family residence
-- R3 - limited multiple residence
-- =============================================

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code =
    CASE substring(Zoning_Code, 3, 1)
        WHEN 'R' THEN
             CASE substring(Zoning_Code, 4, 1)
                WHEN '1' THEN 'R1'
                WHEN '2' THEN 'R2'
                WHEN '3' THEN 'R3'
				WHEN '4' THEN 'R4'
              END
	END
	WHERE Simple_Zoning_Code is null
GO


-- for SCUR1, SCUR2, SCUR3, SCUR4, SCUR5 
UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = substring(Zoning_Code, 4, 2)
    WHERE Zoning_Code like 'SCUR%'
GO


UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'R2'
	WHERE Zoning_Code like 'LAMR2'
GO

UPDATE FILTERED_PARCEL
    SET Residential = (CASE
                       WHEN Simple_Zoning_code IN ('R1', 'R2', 'R3', 'R4', 'R5') THEN 1 ELSE 0 END)
GO


-- =============================================
-- AGRICULTURAL
-- A1: Light Agriculture
-- A2: Heavy Agriculture, Including Hog Ranches

-- COMMERCIAL
-- C1: Restricted Business
-- C2: Neighborhood Business
-- C3: Unlimited Commercial
-- CM: Commercial Manufacturing
-- CR: Commercial Recreation
-- CPD: Commercial Planned Development

-- MANUFACTURING
-- M1: Light Manufacturing
-- M2 Aircraft Heavy Manufacturing
-- M3: Unclassified
-- =============================================

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code =
    CASE substring(Zoning_Code, 3, 1)
        WHEN 'A' THEN
             CASE substring(Zoning_Code, 4, 1)
                WHEN '1' THEN 'A1'
                WHEN '2' THEN 'A2'
                WHEN '3' THEN 'A3'
              END

        WHEN 'C' THEN
             CASE substring(Zoning_Code, 4, 1)
                WHEN '1' THEN 'C1'
                WHEN '2' THEN 'C2'
                WHEN '3' THEN 'C3'
                WHEN '4' THEN 'C4'
              END

        WHEN 'M' THEN
             CASE substring(Zoning_Code, 4, 1)
                WHEN '1' THEN 'M1'
                WHEN '2' THEN 'M2'
                WHEN '3' THEN 'M3'
              END
    END
WHERE Simple_Zoning_Code is null;


-- TODO co to jest C5
UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'C5'
    WHERE Zoning_Code like 'LAC5';


UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'CM'
    WHERE Zoning_Code like 'LACM';


UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'CR'
    WHERE Zoning_Code like 'LBCR*'
          or Zoning_Code like 'LBCR'
          or Zoning_Code like 'AHCR'
          or Zoning_Code like 'LRCR*';

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'CPD'
    WHERE Zoning_Code like 'CPD';

UPDATE FILTERED_PARCEL
    SET Agricultural = (CASE
                       WHEN Simple_Zoning_code IN ('A1', 'A2', 'A3') THEN 1 ELSE 0 END);

UPDATE FILTERED_PARCEL
    SET Commercial = (CASE
                       WHEN Simple_Zoning_code IN ('C1', 'C2', 'C3', 'C4', 'C5', 'CM', 'CPD', 'CR') THEN 1 ELSE 0 END);

UPDATE FILTERED_PARCEL
    SET Manufacturing = (CASE
                       WHEN Simple_Zoning_code IN ('M1', 'M2', 'M3') THEN 1 ELSE 0 END);

-- =============================================
-- SPECIAL PURPOSE ZONES
-- SP: Specific Plan
-- PR - restricted parking
-- RR - resort and recreation
-- =============================================

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'SP'
    WHERE Zoning_Code like 'PDSP'
          or Zoning_Code like 'PDSP*'
          or Zoning_Code like 'LRSP'
          or Zoning_Code like 'NOSP2*'
		  or Zoning_Code like 'SCSP';

		  
UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'RR'
    WHERE substring(Zoning_Code, 3, 3) like 'RR-';    

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'PR'
    WHERE substring(Zoning_Code, 3, 3) like 'PR-';


UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'PR'
    WHERE Zoning_Code like 'LCPR*'
          or Zoning_Code like 'POPRD*';


UPDATE FILTERED_PARCEL
    SET Special_Purposes_Plan = (CASE
                       WHEN Simple_Zoning_code IN ('SP', 'RR', 'PR') THEN 1 ELSE 0 END);


-- =============================================
-- OTHER TYPES
-- =============================================

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code =
    CASE Zoning_Code
        WHEN 'GAMUO' THEN 'GAMUO' 
		WHEN 'RBPDR*' THEN 'RBPDR*' 
		WHEN 'PRSF*' THEN 'SF?' 
		WHEN 'LAWC' THEN 'W1' 
		WHEN 'LACW' THEN 'W2' 
		WHEN 'PSC-' THEN 'PSC?'  
		WHEN 'LBPD1' THEN 'PD1?' 
		WHEN 'LAMR1' THEN 'R1'     
	END
WHERE Simple_Zoning_Code is null
GO

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code = 'R'
    WHERE Zoning_Code like '__R%'
           and Simple_Zoning_Code is null;





---------------polecenie które zwraca ilosc roznych kodów - Zoning_Code, których nie udalo sie odszyfrowaæ------------------
--SELECT Zoning_Code, Simple_Zoning_Code, count(*) as quantity FROM FILTERED_PARCEL
--where Simple_Zoning_Code is null
--group by Zoning_Code, Simple_Zoning_Code
--order by quantity desc




select * from Lands_Vectors


---------New table - Lands_Vectors - Lands with mapped values into integer--
select * into Lands_Vectors from Filtered_Parcel

alter table Lands_Vectors
drop column AIN, Shape, PHASE, PCLTYPE, MOVED, TRA, USECODE, BLOCK, UDATE, EDITORNAME, UNIT_NO, PM_REF, TOT_UNITS, Agency_Class_Number,
SA_Fraction, SA_Unit, MA_Fraction, MA_Unit, F1st_Owner_Assee_Name, F1st_Owner_Name_Overflow, Special_Name_Legend,
Special_Name_Assee_Name, F2nd_Owner_Assee_Name, HA_City_Ky, HA_Information, Partial_Interest, Document_Reason_Cde, Ownership_Cde, 
Exemption_Claim_Type, PersProp_Ky, PersProp_Value, Pers_Prop_Exempt_Value, Fixture_Value, Fixture_Exempt_Value,

ASSRDATA_M, Real_Est_Exempt_Value, LS1_Verification_Ky, LS2_Verification_Ky, LS3_Verification_Ky, LS3_Sale_Amount,
Impairment_Key, Legal_Description_Line2, Legal_Description_Line3, Legal_Description_Line4,

BD_LINE_4_No_of_Bedrooms, BD_LINE_4_No_of_Baths, BD_LINE_4_No_of_Units, BD_LINE_4_Sq_Ft_of_Main_Improve, BD_LINE_5_Subpart, BD_LINE_5_Design_Type,
BD_LINE_5_Quality__Class___Shap, BD_LINE_5_No_of_Units, BD_LINE_5_No_of_Bedrooms, BD_LINE_5_No_of_Baths, BD_LINE_5_Sq_Ft_of_Main_Improve,
TAXS_Ky, TAXS_Yr_Sold_to_St, BD_LINE_4_Subpart, BD_LINE_4_Design_Type, BD_LINE_4_Quality__Class___Shap, BD_LINE_4_Yr_Built, BD_LINE_5_Yr_Built,
BD_LINE_4_Unit_Cost_Main, BD_LINE_4_RCN_Main, BD_LINE_5_Year_Changed, BD_LINE_5_Unit_Cost_Main, BD_LINE_5_RCN_Main, First_Transferee_Name, First_Transferee_Name_Overflow, Second_Transferee_Name,
Recorders_Document_Key, Legal_Description_Line5, Legal_Description_Last

GO

alter table Lands_Vectors
drop column



select * from Lands_Vectors






-----------					Street and State concatenations			------------------------------------------------------------------------------------------

-----New column to Lands_Vectors to concatenate MA_Street_Name and MA_City_and_State
-----New column to Lands_Vectors to concatenate SA_Street_Name and SA_City_and_State
ALTER table Lands_Vectors
add MA_Street_and_City_and_State nvarchar(100), SA_Street_and_City_and_State nvarchar(100)
GO

UPDATE Lands_Vectors
set MA_Street_and_City_and_State = MA_Street_Name + ' '+ MA_City_and_State,
	SA_Street_and_City_and_State = SA_Street_Name + ' '+ SA_City_and_State;




-----------					TEMP TABLES	TO MAPPING			------------------------------------------------------------------------------------------

--------------------------------
--Mapping tables:
--Simple_Zones_Mapping +
--Directions_Mapping +
--Localization_SA_Mapping +
--Localization_MA_Mapping +
--Zoning_Codes_Mapping
--BD_LINE_1_Quality__Class___Shap_Mapping
--City_Mapping

-----------------------------

--1
---Table to map simple_zone


IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'Simple_Zones_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END

ELSE
BEGIN
	insert into Simple_Zones_Mapping (Simple_Zoning_Code)
	select DISTINCT P.Simple_Zoning_Code 
	from PARCEL_VECTORS P
	where P.Simple_Zoning_Code not in (
		select DISTINCT P.Simple_Zoning_Code from PARCEL_VECTORS P
		inner join Simple_Zones_Mapping L
		on L.Simple_Zoning_Code = P.Simple_Zoning_Code
	)

END


--2
----Table to map SA_Direction and MA_Direction---
--only possible values are NULL, W, E, N, S - so this table do not need updates when the data set is growing

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'Directions_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN
	insert into Directions_Mapping (Direction)
	select DISTINCT P.SA_Direction 
	from PARCEL_VECTORS P
	where P.SA_Direction not in (
	select DISTINCT P.SA_Direction from PARCEL_VECTORS P
	inner join Directions_Mapping D
	on D.Direction = P.SA_Direction)

	insert into Directions_Mapping (Direction)
	select DISTINCT P.MA_Direction 
	from PARCEL_VECTORS P
	where P.MA_Direction not in (
	select DISTINCT P.MA_Direction from PARCEL_VECTORS P
	inner join Directions_Mapping D
	on D.Direction = P.MA_Direction
	)

END

--3
----Table to map SA_Street-and_City-and_State---
IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'Localization_SA_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN
	insert into Localization_SA_Mapping (SA_Street_and_City_and_State)
	select DISTINCT P.SA_Street_and_City_and_State 
	from Lands_Vectors P
	where P.SA_Street_and_City_and_State not in (
	select DISTINCT P.SA_Street_and_City_and_State from Lands_Vectors P
	inner join Localization_SA_Mapping L
	on L.SA_Street_and_City_and_State = P.SA_Street_and_City_and_State
	)

END


--4
----Table to map MA_Street-and_City-and_State---
IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'Localization_MA_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN
	insert into Localization_MA_Mapping (MA_Street_and_City_and_State)
	select DISTINCT P.MA_Street_and_City_and_State 
	from PARCEL_VECTORS P
	where P.MA_Street_and_City_and_State not in (
	select DISTINCT P.MA_Street_and_City_and_State from PARCEL_VECTORS P
	inner join Localization_MA_Mapping L
	on L.MA_Street_and_City_and_State = P.MA_Street_and_City_and_State
	)
END


--5
----Table to map Zoning_Code---
IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'Zoning_Codes_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN
	
	insert into Zoning_Codes_Mapping (Zoning_Code)
	select DISTINCT P.Zoning_Code 
	from PARCEL_VECTORS P
	where P.Zoning_Code not in (
	select DISTINCT P.Zoning_Code from PARCEL_VECTORS P
	inner join Zoning_Codes_Mapping L
	on L.Zoning_Code = P.Zoning_Code
	)

END


--6
----Table to map BD_LINE_1_Quality---
IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'BD_LINE_1_Quality__Class___Shap_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN

	insert into BD_LINE_1_Quality__Class___Shap_Mapping (BD_LINE_1_Quality__Class___Shap)
	select DISTINCT P.BD_LINE_1_Quality__Class___Shap 
	from PARCEL_VECTORS P
	where P.BD_LINE_1_Quality__Class___Shap not in (
	select DISTINCT P.BD_LINE_1_Quality__Class___Shap from PARCEL_VECTORS P
	inner join BD_LINE_1_Quality__Class___Shap_Mapping M
	on M.BD_LINE_1_Quality__Class___Shap = P.BD_LINE_1_Quality__Class___Shap
	)

END


--7
----Table to map City---

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'City_Mapping'))
BEGIN
	PRINT 'FIRSTLY RUN create_mapping_tables SCRIPT'
END
ELSE
BEGIN
	insert into City_Mapping (City)
	select DISTINCT P.City 
	from PARCEL_VECTORS P
	where P.City not in (
	select DISTINCT P.City from PARCEL_VECTORS P
	inner join City_Mapping M
	on M.City = P.City
	)

END

-------------------------------------------------------------


IF (NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Lands_Vectors'
                 AND (COLUMN_NAME = 'SA_Localization_int'
				 OR COLUMN_NAME = 'MA_Localization_int'
				 OR COLUMN_NAME = 'MA_Direction_int'
				 OR COLUMN_NAME = 'SA_Direction_int'
				 OR COLUMN_NAME = 'Simple_Zone_int'
				 OR COLUMN_NAME = 'Zoning_Code_int'
				 OR COLUMN_NAME = 'BD_LINE_1_Quality__Class___Shap_int'
				 OR COLUMN_NAME = 'City_int'
				 )
			) )
BEGIN
	ALTER TABLE Lands_Vectors
	ADD SA_Localization_int int, 
		MA_Localization_int int, 
		MA_Direction_int int, 
		SA_Direction_int int,
		Simple_Zone_int int,
		Zoning_Code_int int,
		BD_LINE_1_Quality__Class___Shap_int int,
		City_int int

END


---Rewriting mapping from mapping tables into Lands_Vector table----------

--1
update l set l.SA_Direction_int = d.Direction_int
from Lands_Vectors l
inner join Directions_Mapping d on l.SA_Direction = d.Direction
GO

update Lands_Vectors
set SA_Direction_int = 1 
where SA_Direction is null
GO

--2
update l set l.MA_Direction_int = d.Direction_int
from Lands_Vectors l
inner join Directions_Mapping d on l.MA_Direction = d.Direction
GO

update Lands_Vectors
set MA_Direction_int = 1 
where MA_Direction is null
GO


--3
update l set l.Zoning_Code_int = z.Zoning_Code_int
from Lands_Vectors l
inner join Zoning_Codes_Mapping z on l.Zoning_Code = z.Zoning_Code
GO

--4
update l set l.SA_Localization_int = lm.SA_Street_and_City_and_State_int
from Lands_Vectors l
inner join Localization_SA_Mapping lm on l.SA_Street_and_City_and_State = lm.SA_Street_and_City_and_State
GO

update Lands_Vectors
set SA_Localization_int = 0 
where SA_Localization_int is null
GO


--5
update l set l.MA_Localization_int = lm.MA_Street_and_City_and_State_int
from Lands_Vectors l
inner join Localization_MA_Mapping lm on l.MA_Street_and_City_and_State = lm.MA_Street_and_City_and_State
GO

update Lands_Vectors
set MA_Localization_int = 0 
where MA_Localization_int is null
GO


--6
update l set l.Simple_Zone_int = s.Simple_Zone_int
from Lands_Vectors l
inner join Simple_Zones_Mapping s on l.Simple_Zoning_Code = s.Simple_Zoning_Code
GO

update Lands_Vectors
set Simple_Zone_int = 1 
where Simple_Zone_int is null
GO

--7
update l set l.BD_LINE_1_Quality__Class___Shap_int = m.BD_LINE_1_Quality__Class___Shap_int
from Lands_Vectors l
inner join BD_LINE_1_Quality__Class___Shap_Mapping m on l.BD_LINE_1_Quality__Class___Shap = m.BD_LINE_1_Quality__Class___Shap
GO

update Lands_Vectors
set BD_LINE_1_Quality__Class___Shap_int = 0 
where BD_LINE_1_Quality__Class___Shap_int is null
GO

--8
update l set l.City_int = c.City_int
from Lands_Vectors l
inner join City_Mapping c on l.City = c.City
GO


------Droping columns with string values from Lands_Vectors -----
ALTER TABLE Lands_Vectors
DROP COLUMN 
SA_Direction, SA_Street_Name, SA_City_and_State, 
MA_Direction, MA_Street_Name, MA_City_and_State,
Zoning_Code, BD_LINE_1_Quality__Class___Shap,
SA_Street_and_City_and_State, MA_Street_and_City_and_State, City, Simple_Zoning_Code



------Mapping NULL values into numbers----------
--columns with null values: Use_Cde and BD_LINE_1_Design_Type

--only 4 records 21.07.2018
DELETE FROM Lands_Vectors
WHERE Use_Cde is null;

--around 11 thousand records -> update:
 UPDATE Lands_Vectors
 set BD_LINE_1_Design_Type = 0000 where BD_LINE_1_Design_Type is null
 GO
-------

update Lands_Vectors
set BD_LINE_2_Design_Type = 1 
where BD_LINE_2_Design_Type is null
GO

update Lands_Vectors
set BD_LINE_2_Quality__Class___Shap = 1 
where BD_LINE_2_Quality__Class___Shap is null
GO

update Lands_Vectors
set BD_LINE_3_Design_Type = 1 
where BD_LINE_3_Design_Type is null
GO

update Lands_Vectors
set BD_LINE_3_Quality__Class___Shap = 1 
where BD_LINE_3_Quality__Class___Shap is null
GO

update Lands_Vectors
set Land_Reason_Key = 1 
where Land_Reason_Key is null
GO

select * from Lands_Vectors


--do csv ObjectID;PERIMETERLS2_Sale_Date;LS3_Sale_Date;BD_LINE_1_Subpart;BD_LINE_1_Design_Type;BD_LINE_1_Yr_Built;BD_LINE_1_No_of_Units;BD_LINE_1_No_of_Bedrooms;BD_LINE_1_No_of_Baths;BD_LINE_1_Sq_Ft_of_Main_Improve;BD_LINE_2_Yr_Built;BD_LINE_2_No_of_Units;BD_LINE_2_No_of_Bedrooms;BD_LINE_2_No_of_Baths;BD_LINE_2_Sq_Ft_of_Main_Improve;Current_Land_Base_Year;Current_Improvement_Base_Year;Current_Land_Base_Value;Current_Improvement_Base_Value;Cluster_Location;Cluster_Type;Cluster_Appraisal_Unit;Document_Transfer_Tax_Sales_Amo;BD_LINE_1_Year_Changed;BD_LINE_1_Unit_Cost_Main;BD_LINE_1_RCN_Main;BD_LINE_2_Year_Changed;BD_LINE_2_Unit_Cost_Main;BD_LINE_2_RCN_Main;Landlord_Reappraisal_Year;Landlord_Number_of_Units;Price_Per_Area;Area;SA_Localization_int;MA_Localization_int;MA_Direction_int;SA_Direction_int;Simple_Zone_int;Zoning_Code_int;BD_LINE_1_Quality__Class___Shap_int;City_int

IMPROVE_Curr_Value;SA_Zip_Cde;Recording_Date;Use_Cde;

--to test if there is any null values in any column

DECLARE @tb NVARCHAR(255) = N'dbo.Lands_Vectors';

DECLARE @sql NVARCHAR(MAX) = N'SELECT * FROM ' + @tb
    + ' WHERE 1 = 0';

SELECT @sql += N' OR ' + QUOTENAME(name) + ' IS NULL'
    FROM sys.columns 
    WHERE [object_id] = OBJECT_ID(@tb);

EXEC sp_executesql @sql;




---Move LS1_Sale_Amount column to the end, rename it

alter table Lands_Vectors
add Sale_Amount int 
GO

update Lands_Vectors set Sale_Amount = LS1_Sale_Amount



alter table Lands_Vectors
drop column LS1_Sale_Amount

---

select * from Lands_Vectors 
order by Sale_Amount 

SELECT OBJECTID, PERIMETER, PARCEL_TYP, TRA_1, LAND_Curr_Roll_Yr,LAND_Curr_Value,	'+
                           'IMPROVE_Curr_Roll_YR, IMPROVE_Curr_Value, SA_House_Number, SA_Zip_Cde, 
						   MA_House_Number,	MA_Zip_Cde,	Recording_Date,'+
 'Hmownr_Exempt_Number, Hmownr_Exempt_Value, LS1_Sale_Date, LS2_Sale_Date,'+
'LS3_Sale_Date, BD_LINE_1_Subpart, BD_LINE_1_Design_Type, BD_LINE_1_Yr_Built, BD_LINE_1_No_of_Units,'+
'BD_LINE_1_No_of_Bedrooms, BD_LINE_1_No_of_Baths, BD_LINE_1_Sq_Ft_of_Main_Improve, BD_LINE_2_Subpart,'+
'BD_LINE_2_Design_Type, BD_LINE_2_Yr_Built, BD_LINE_2_No_of_Units,'+
'BD_LINE_2_No_of_Bedrooms, BD_LINE_2_No_of_Baths, BD_LINE_2_Sq_Ft_of_Main_Improve, BD_LINE_3_Subpart,'+
'BD_LINE_3_Design_Type, BD_LINE_3_Yr_Built, BD_LINE_3_No_of_Units,'+
'BD_LINE_3_No_of_Bedrooms, BD_LINE_3_No_of_Baths, BD_LINE_3_Sq_Ft_of_Main_Improve,'+
'Current_Land_Base_Year, Current_Improvement_Base_Year,'+
'Current_Land_Base_Value, Current_Improvement_Base_Value, Cluster_Location, Cluster_Type,'+
'Cluster_Appraisal_Unit, Document_Transfer_Tax_Sales_Amo, BD_LINE_1_Year_Changed,'+
'BD_LINE_1_Unit_Cost_Main, BD_LINE_1_RCN_Main, BD_LINE_2_Year_Changed, BD_LINE_2_Unit_Cost_Main,'+
'BD_LINE_2_RCN_Main, BD_LINE_3_Year_Changed, BD_LINE_3_Unit_Cost_Main, BD_LINE_3_RCN_Main,'+
'BD_LINE_4_Year_Changed,	Landlord_Reappraisal_Year,	Landlord_Number_of_Units,'+
'Recorders_Document_Number,	Price_Per_Single_Area_Unit,	Parcel_Area, Residential,'+
'Special_Purposes_Plan, Agricultural, Commercial, Manufacturing, SA_Localization_int,'+
'MA_Localization_int, MA_Direction_int, SA_Direction_int, Simple_Zone_int,'+
'Zoning_Code_int, BD_LINE_1_Quality__Class___Shap_int, City_int,	Sale_Amount FROM Lands_Vectors WHERE Sale_Amount < 10000000


select distinct Land_reason_Key from Lands_Vectors

UPDATE FILTERED_PARCEL
  SET Simple_Zoning_Code =
    CASE Zoning_Code
        WHEN 1 THEN 'GAMUO' 
		WHEN 2 THEN 'RBPDR*' 
		WHEN 3 THEN 'SF?' 
		WHEN 5 THEN 'W1' 
		WHEN 7 THEN 'W2' 
		WHEN 8 THEN 'PSC?'  
		WHEN 'LBPD1' THEN 'PD1?' 
		WHEN 'LAMR1' THEN 'R1'     
	END
WHERE Simple_Zoning_Code is null
GO





SELECT OBJECTID, PERIMETER, PARCEL_TYP, TRA_1, LAND_Curr_Roll_Yr,LAND_Curr_Value, IMPROVE_Curr_Roll_YR, IMPROVE_Curr_Value, SA_House_Number, SA_Zip_Cde, MA_House_Number,	MA_Zip_Cde,	Recording_Date,
Hmownr_Exempt_Number, Hmownr_Exempt_Value, LS1_Sale_Date, LS2_Sale_Date,
LS3_Sale_Date, BD_LINE_1_Yr_Built, BD_LINE_1_No_of_Units,
BD_LINE_1_No_of_Bedrooms, BD_LINE_1_No_of_Baths, BD_LINE_1_Sq_Ft_of_Main_Improve, BD_LINE_2_Subpart,
BD_LINE_2_Yr_Built, BD_LINE_2_No_of_Units,
BD_LINE_2_No_of_Bedrooms, BD_LINE_2_No_of_Baths, BD_LINE_2_Sq_Ft_of_Main_Improve,
BD_LINE_3_Subpart,
BD_LINE_3_Yr_Built, BD_LINE_3_No_of_Units,BD_LINE_3_No_of_Bedrooms, BD_LINE_3_No_of_Baths, BD_LINE_3_Sq_Ft_of_Main_Improve,
Current_Land_Base_Year, Current_Improvement_Base_Year,
Current_Land_Base_Value, Current_Improvement_Base_Value, Cluster_Location, Cluster_Type,
Cluster_Appraisal_Unit, Document_Transfer_Tax_Sales_Amo, BD_LINE_1_Year_Changed,
BD_LINE_1_Unit_Cost_Main, BD_LINE_1_RCN_Main, BD_LINE_2_Year_Changed, 
BD_LINE_2_Unit_Cost_Main, BD_LINE_2_RCN_Main, BD_LINE_3_Year_Changed, 
BD_LINE_3_Unit_Cost_Main, BD_LINE_3_RCN_Main, BD_LINE_4_Year_Changed,Landlord_Reappraisal_Year,
Landlord_Number_of_Units,
Recorders_Document_Number,	Price_Per_Single_Area_Unit,	Parcel_Area, Residential,
Special_Purposes_Plan, Agricultural, Commercial, Manufacturing, SA_Localization_int,
MA_Localization_int, MA_Direction_int, SA_Direction_int, Simple_Zone_int,
Zoning_Code_int,
BD_LINE_1_Quality__Class___Shap_int, City_int, Sale_Amount
INTO PARCEL_DATA_SET FROM Lands_Vectors
	WHERE Sale_Amount < 10000000


 select top 10 * from PARCEL_DATA_SET



 select * from PARCEL_DATA_SET where Sale_Amount <1000000 and Sale_Amount > 500000 