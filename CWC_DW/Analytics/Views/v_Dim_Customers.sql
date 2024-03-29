﻿/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Customers]

AS

SELECT [Customer_Key]
      ,[Customer_Account]
      --,[Employee_Key]
      --,[Employee_Responsible_Number]
      ,[Customer_Group]
      --,[Organization_Name]
      ,[Name_Alias]
      --,[Known_As]
      ,[Person_First_Name]
      ,[Person_Last_Name]
     -- ,[Full_Primary_Address]
      ,[Address_Description]
      ,[Address_Zip_Code]
      ,[Address_City]
      --,[Address_County]
      ,[Address_State]
      ,[Address_Country_Region_ID]
      --,[Address_Valid_From]
      --,[Address_Valid_To]
      ,[Primary_Contact_Email]
      ,[Primary_Contact_Phone]
      ,[Sales_Currency_Code]
      ,[Payment_Terms]
      --,[Payment_Method]
      ,[Delivery_Mode]
      ,[Receipt_Email]
      ,[Delivery_Address_Description]
	  ,[Delivery_Address_Street]
	  ,[Delivery_Address_City]
	  ,[Delivery_Address_State]
      ,[Delivery_Address_Zip_Code]
      
      ,[Delivery_Address_Country_Region_ID]
      --,[Delivery_Address_County]
      

      --,[Delivery_Address_Street_Number]
      ,[Delivery_Address_Valid_From]
      ,[Delivery_Address_Valid_To]
      ,[Email_Contact_Pref_ID]
      ,[Phone_Contact_Pref_ID]
      ,[Direct_Mail_Contact_Pref_ID]
      ,[Rental_Contact_Pref_ID]
      ,[Created_Date_Time] = DATEADD(hh,-5,[Created_Date_Time])
      ,[Modified_Date_Time] = DATEADD(hh,-5,[Modified_Date_Time])
      --,[On_Hold_Status]
      --,[is_Business_Address]
      --,[is_Delivery_Address]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Customers] (NOLOCK)