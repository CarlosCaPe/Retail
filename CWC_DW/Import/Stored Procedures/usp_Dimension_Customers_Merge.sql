﻿
CREATE PROC [Import].[usp_Dimension_Customers_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;;

	WITH src_seq
	AS (
		SELECT DISTINCT [Customer_Account] = [CUSTOMERACCOUNT]
			,[Employee_Key] = e.Employee_Key
			,[Employee_Responsible_Number] = NULLIF([EMPLOYEERESPONSIBLENUMBER], '')
			,[Customer_Group] = CASE 
				WHEN [CUSTOMERGROUPID] = 'CCCUST'
					THEN 'Contact Center'
				WHEN [CUSTOMERGROUPID] = 'CUST'
					THEN 'Ecommerce'
				WHEN [CUSTOMERGROUPID] = 'Retail'
					THEN 'Retail'
				WHEN [CUSTOMERGROUPID] = 'Emp'
					THEN 'Employee'
				WHEN [CUSTOMERGROUPID] = 'Jobber'
					THEN 'Jobber'
				ELSE [CUSTOMERGROUPID]
				END
			,[Organization_Name] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([ORGANIZATIONNAME], ''), N'℅'), N'℅', '')))
			,[Name_Alias] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([NAMEALIAS], ''), N'℅'), N'℅', '')))
			,[Known_As] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([KNOWNAS], ''), N'℅'), N'℅', '')))
			,[Person_First_Name] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([PERSONFIRSTNAME], ''), N'℅'), N'℅', '')))
			,[Person_Last_Name] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([PERSONLASTNAME], ''), N'℅'), N'℅', '')))
			,[Full_Primary_Address] = NULLIF([FULLPRIMARYADDRESS], '')
			,[Address_Description] = RTRIM(LTRIM(REPLACE(NULLIF(NULLIF([ADDRESSDESCRIPTION], ''), N'℅'), N'℅', '')))
			,[Address_Zip_Code] = NULLIF([ADDRESSZIPCODE], '')
			,[Address_City] = NULLIF([ADDRESSCITY], '')
			,[Address_County] = NULLIF([ADDRESSCOUNTY], '')
			,[Address_State] = NULLIF([ADDRESSSTATE], '')
			,[Address_Country_Region_ID] = NULLIF([ADDRESSCOUNTRYREGIONID], '')
			,[Address_Valid_From] = NULLIF(NULLIF(CAST([ADDRESSVALIDFROM] AS DATETIME2(5)), '1900-01-01 00:00:00.00000'), '2154-12-31 23:59:59.000')
			,[Address_Valid_To] = NULLIF(NULLIF(CAST([ADDRESSVALIDTO] AS DATETIME2(5)), '1900-01-01 00:00:00.00000'), '2154-12-31 23:59:59.000')
			,[Primary_Contact_Email] = NULLIF(NULLIF([PRIMARYCONTACTEMAIL], ''), 'noemail@noemail.com')
			,[Primary_Contact_Phone] = REPLACE(REPLACE(REPLACE(REPLACE(NULLIF(NULLIF(NULLIF([PRIMARYCONTACTPHONE], ''), '5555555555'), '9999999999'), '-', ''), '.', ''), ' ', ''), '*', '')
			,[Sales_Currency_Code] = NULLIF([SALESCURRENCYCODE], '')
			,[Payment_Terms] = NULLIF(CASE [PAYMENTTERMS]
					WHEN 'N00'
						THEN 'Due Upon Receipt'
					WHEN 'N30'
						THEN 'Net 30 Days'
					WHEN 'Cash'
						THEN 'Cash'
					WHEN 'CreditCard'
						THEN 'Credit Card'
					ELSE [PAYMENTTERMS]
					END, '')
			,[Payment_Method] = NULLIF(CASE [PAYMENTMETHOD]
					WHEN 'CreditCard'
						THEN 'Credit Card'
					ELSE [PAYMENTMETHOD]
					END, '')
			,[Delivery_Mode] = NULLIF(CASE [DELIVERYMODE]
					WHEN 'STANDARD'
						THEN 'Standard Ground'
					WHEN '2Day'
						THEN '2nd Day Air'
					WHEN 'Pickup'
						THEN 'Pickup'
					WHEN 'OVERNT'
						THEN 'FedEx Overnight'
					ELSE [DELIVERYMODE]
					END, '')
			,[Receipt_Email] = NULLIF(NULLIF([RECEIPTEMAIL], ''), 'noemail@noemail.com')
			,[Delivery_Address_Description] = NULLIF([DELIVERYADDRESSDESCRIPTION], '')
			,[Delivery_Address_Zip_Code] = NULLIF([DELIVERYADDRESSZIPCODE], '')
			,[Delivery_Address_City] = NULLIF([DELIVERYADDRESSCITY], '')
			,[Delivery_Address_Country_Region_ID] = NULLIF([DELIVERYADDRESSCOUNTRYREGIONID], '')
			,[Delivery_Address_County] = NULLIF([DELIVERYADDRESSCOUNTY], '')
			,[Delivery_Address_State] = NULLIF([DELIVERYADDRESSSTATE], '')
			,[Delivery_Address_Street] = NULLIF([DELIVERYADDRESSSTREET], '')
			,[Delivery_Address_Street_Number] = NULLIF([DELIVERYADDRESSSTREETNUMBER], '')
			,[Delivery_Address_Valid_From] = NULLIF(NULLIF(CAST([DELIVERYADDRESSVALIDFROM] AS DATETIME2(5)), '1900-01-01 00:00:00.00000'), '2154-12-31 23:59:59.000')
			,[Delivery_Address_Valid_To] = NULLIF(NULLIF(CAST([DELIVERYADDRESSVALIDTO] AS DATETIME2(5)), '1900-01-01 00:00:00.00000'), '2154-12-31 23:59:59.000')
			,[Email_Contact_Pref_ID] = NULLIF(CASE [ITSCUSTEMAILCONTACTPREFID]
					WHEN 'DoNotEmail'
						THEN 'Do Not Email'
					ELSE [ITSCUSTEMAILCONTACTPREFID]
					END, '')
			,[Phone_Contact_Pref_ID] = NULLIF(CASE [ITSCUSTTELEPHONECONTACTPREFID]
					WHEN 'DoNotPhone'
						THEN 'Do Not Phone'
					ELSE [ITSCUSTTELEPHONECONTACTPREFID]
					END, '')
			,[Direct_Mail_Contact_Pref_ID] = NULLIF(CASE [ITSCUSTDIRECTMAILCONTACTPREFID]
					WHEN 'DoNotMail'
						THEN 'Do Not Mail'
					ELSE [ITSCUSTDIRECTMAILCONTACTPREFID]
					END, '')
			,[Rental_Contact_Pref_ID] = NULLIF(CASE [ITSCUSTRENTALCONTACTPREFID]
					WHEN 'DoNotRent'
						THEN 'Do Not Rent'
					ELSE [ITSCUSTRENTALCONTACTPREFID]
					END, '')
			,[Created_Date_Time] = CAST([ITSCUSTCREATEDDATETIME] AS DATETIME2(5))
			,[Modified_Date_Time] = CAST([ITSCUSTMODIFIEDDATETIME] AS DATETIME2(5))
			,[On_Hold_Status] = [ONHOLDSTATUS]
			,[is_Business_Address] = CAST((
					CASE 
						WHEN [ADDRESSLOCATIONROLES] LIKE '%Business%'
							THEN 1
						ELSE 0
						END
					) AS BIT)
			,[is_Delivery_Address] = CAST((
					CASE 
						WHEN [ADDRESSLOCATIONROLES] LIKE '%Delivery%'
							THEN 1
						ELSE 0
						END
					) AS BIT)
			,[Seq] = ROW_NUMBER() OVER (
				PARTITION BY [CUSTOMERACCOUNT] ORDER BY [ITSCUSTMODIFIEDDATETIME] DESC
					,[ITSCUSTMODIFIEDDATETIME] DESC
				)
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [AX_PRODUCTION].[dbo].[CustCustomerV3Staging] c
		LEFT JOIN [CWC_DW].[Dimension].[Employees] e ON c.[EMPLOYEERESPONSIBLENUMBER] = e.[Personnel_Number]
			AND CAST([ITSCUSTMODIFIEDDATETIME] AS DATE) BETWEEN e.Start_Date
				AND ISNULL(e.End_Date, CAST(SYSUTCDATETIME() AS DATE))
		)
		,src
	AS (
		SELECT *
		FROM src_seq
		WHERE seq = 1
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Customers]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Customer_Account] = src.[Customer_Account]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Customer_Account]
				,[Employee_Key]
				,[Employee_Responsible_Number]
				,[Customer_Group]
				,[Organization_Name]
				,[Name_Alias]
				,[Known_As]
				,[Person_First_Name]
				,[Person_Last_Name]
				,[Full_Primary_Address]
				,[Address_Description]
				,[Address_Zip_Code]
				,[Address_City]
				,[Address_County]
				,[Address_State]
				,[Address_Country_Region_ID]
				,[Address_Valid_From]
				,[Address_Valid_To]
				,[Primary_Contact_Email]
				,[Primary_Contact_Phone]
				,[Sales_Currency_Code]
				,[Payment_Terms]
				,[Payment_Method]
				,[Delivery_Mode]
				,[Receipt_Email]
				,[Delivery_Address_Description]
				,[Delivery_Address_Zip_Code]
				,[Delivery_Address_City]
				,[Delivery_Address_Country_Region_ID]
				,[Delivery_Address_County]
				,[Delivery_Address_State]
				,[Delivery_Address_Street]
				,[Delivery_Address_Street_Number]
				,[Delivery_Address_Valid_From]
				,[Delivery_Address_Valid_To]
				,[Email_Contact_Pref_ID]
				,[Phone_Contact_Pref_ID]
				,[Direct_Mail_Contact_Pref_ID]
				,[Rental_Contact_Pref_ID]
				,[Created_Date_Time]
				,[Modified_Date_Time]
				,[On_Hold_Status]
				,[is_Business_Address]
				,[is_Delivery_Address]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Customer_Account]
				,src.[Employee_Key]
				,src.[Employee_Responsible_Number]
				,src.[Customer_Group]
				,src.[Organization_Name]
				,src.[Name_Alias]
				,src.[Known_As]
				,src.[Person_First_Name]
				,src.[Person_Last_Name]
				,src.[Full_Primary_Address]
				,src.[Address_Description]
				,src.[Address_Zip_Code]
				,src.[Address_City]
				,src.[Address_County]
				,src.[Address_State]
				,src.[Address_Country_Region_ID]
				,src.[Address_Valid_From]
				,src.[Address_Valid_To]
				,src.[Primary_Contact_Email]
				,src.[Primary_Contact_Phone]
				,src.[Sales_Currency_Code]
				,src.[Payment_Terms]
				,src.[Payment_Method]
				,src.[Delivery_Mode]
				,src.[Receipt_Email]
				,src.[Delivery_Address_Description]
				,src.[Delivery_Address_Zip_Code]
				,src.[Delivery_Address_City]
				,src.[Delivery_Address_Country_Region_ID]
				,src.[Delivery_Address_County]
				,src.[Delivery_Address_State]
				,src.[Delivery_Address_Street]
				,src.[Delivery_Address_Street_Number]
				,src.[Delivery_Address_Valid_From]
				,src.[Delivery_Address_Valid_To]
				,src.[Email_Contact_Pref_ID]
				,src.[Phone_Contact_Pref_ID]
				,src.[Direct_Mail_Contact_Pref_ID]
				,src.[Rental_Contact_Pref_ID]
				,src.[Created_Date_Time]
				,src.[Modified_Date_Time]
				,src.[On_Hold_Status]
				,src.[is_Business_Address]
				,src.[is_Delivery_Address]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Employee_Key], '') <> ISNULL(src.[Employee_Key], '')
		OR ISNULL(tgt.[Employee_Responsible_Number], '') <> ISNULL(src.[Employee_Responsible_Number], '')
		OR ISNULL(tgt.[Customer_Group], '') <> ISNULL(src.[Customer_Group], '')
		OR ISNULL(tgt.[Organization_Name], '') <> ISNULL(src.[Organization_Name], '')
		OR ISNULL(tgt.[Name_Alias], '') <> ISNULL(src.[Name_Alias], '')
		OR ISNULL(tgt.[Known_As], '') <> ISNULL(src.[Known_As], '')
		OR ISNULL(tgt.[Person_First_Name], '') <> ISNULL(src.[Person_First_Name], '')
		OR ISNULL(tgt.[Person_Last_Name], '') <> ISNULL(src.[Person_Last_Name], '')
		OR ISNULL(tgt.[Full_Primary_Address], '') <> ISNULL(src.[Full_Primary_Address], '')
		OR ISNULL(tgt.[Address_Description], '') <> ISNULL(src.[Address_Description], '')
		OR ISNULL(tgt.[Address_Zip_Code], '') <> ISNULL(src.[Address_Zip_Code], '')
		OR ISNULL(tgt.[Address_City], '') <> ISNULL(src.[Address_City], '')
		OR ISNULL(tgt.[Address_County], '') <> ISNULL(src.[Address_County], '')
		OR ISNULL(tgt.[Address_State], '') <> ISNULL(src.[Address_State], '')
		OR ISNULL(tgt.[Address_Country_Region_ID], '') <> ISNULL(src.[Address_Country_Region_ID], '')
		OR ISNULL(tgt.[Address_Valid_From], '') <> ISNULL(src.[Address_Valid_From], '')
		OR ISNULL(tgt.[Address_Valid_To], '') <> ISNULL(src.[Address_Valid_To], '')
		OR ISNULL(tgt.[Primary_Contact_Email], '') <> ISNULL(src.[Primary_Contact_Email], '')
		OR ISNULL(tgt.[Primary_Contact_Phone], '') <> ISNULL(src.[Primary_Contact_Phone], '')
		OR ISNULL(tgt.[Sales_Currency_Code], '') <> ISNULL(src.[Sales_Currency_Code], '')
		OR ISNULL(tgt.[Payment_Terms], '') <> ISNULL(src.[Payment_Terms], '')
		OR ISNULL(tgt.[Payment_Method], '') <> ISNULL(src.[Payment_Method], '')
		OR ISNULL(tgt.[Delivery_Mode], '') <> ISNULL(src.[Delivery_Mode], '')
		OR ISNULL(tgt.[Receipt_Email], '') <> ISNULL(src.[Receipt_Email], '')
		OR ISNULL(tgt.[Delivery_Address_Description], '') <> ISNULL(src.[Delivery_Address_Description], '')
		OR ISNULL(tgt.[Delivery_Address_Zip_Code], '') <> ISNULL(src.[Delivery_Address_Zip_Code], '')
		OR ISNULL(tgt.[Delivery_Address_City], '') <> ISNULL(src.[Delivery_Address_City], '')
		OR ISNULL(tgt.[Delivery_Address_Country_Region_ID], '') <> ISNULL(src.[Delivery_Address_Country_Region_ID], '')
		OR ISNULL(tgt.[Delivery_Address_County], '') <> ISNULL(src.[Delivery_Address_County], '')
		OR ISNULL(tgt.[Delivery_Address_State], '') <> ISNULL(src.[Delivery_Address_State], '')
		OR ISNULL(tgt.[Delivery_Address_Street], '') <> ISNULL(src.[Delivery_Address_Street], '')
		OR ISNULL(tgt.[Delivery_Address_Street_Number], '') <> ISNULL(src.[Delivery_Address_Street_Number], '')
		OR ISNULL(tgt.[Delivery_Address_Valid_From], '') <> ISNULL(src.[Delivery_Address_Valid_From], '')
		OR ISNULL(tgt.[Delivery_Address_Valid_To], '') <> ISNULL(src.[Delivery_Address_Valid_To], '')
		OR ISNULL(tgt.[Email_Contact_Pref_ID], '') <> ISNULL(src.[Email_Contact_Pref_ID], '')
		OR ISNULL(tgt.[Phone_Contact_Pref_ID], '') <> ISNULL(src.[Phone_Contact_Pref_ID], '')
		OR ISNULL(tgt.[Direct_Mail_Contact_Pref_ID], '') <> ISNULL(src.[Direct_Mail_Contact_Pref_ID], '')
		OR ISNULL(tgt.[Rental_Contact_Pref_ID], '') <> ISNULL(src.[Rental_Contact_Pref_ID], '')
		OR ISNULL(tgt.[Created_Date_Time], '') <> ISNULL(src.[Created_Date_Time], '')
		OR ISNULL(tgt.[Modified_Date_Time], '') <> ISNULL(src.[Modified_Date_Time], '')
		OR ISNULL(tgt.[On_Hold_Status], '') <> ISNULL(src.[On_Hold_Status], '')
		OR ISNULL(tgt.[is_Business_Address], '') <> ISNULL(src.[is_Business_Address], '')
		OR ISNULL(tgt.[is_Delivery_Address], '') <> ISNULL(src.[is_Delivery_Address], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Employee_Key] = src.[Employee_Key]
				,[Employee_Responsible_Number] = src.[Employee_Responsible_Number]
				,[Customer_Group] = src.[Customer_Group]
				,[Organization_Name] = src.[Organization_Name]
				,[Name_Alias] = src.[Name_Alias]
				,[Known_As] = src.[Known_As]
				,[Person_First_Name] = src.[Person_First_Name]
				,[Person_Last_Name] = src.[Person_Last_Name]
				,[Full_Primary_Address] = src.[Full_Primary_Address]
				,[Address_Description] = src.[Address_Description]
				,[Address_Zip_Code] = src.[Address_Zip_Code]
				,[Address_City] = src.[Address_City]
				,[Address_County] = src.[Address_County]
				,[Address_State] = src.[Address_State]
				,[Address_Country_Region_ID] = src.[Address_Country_Region_ID]
				,[Address_Valid_From] = src.[Address_Valid_From]
				,[Address_Valid_To] = src.[Address_Valid_To]
				,[Primary_Contact_Email] = src.[Primary_Contact_Email]
				,[Primary_Contact_Phone] = src.[Primary_Contact_Phone]
				,[Sales_Currency_Code] = src.[Sales_Currency_Code]
				,[Payment_Terms] = src.[Payment_Terms]
				,[Payment_Method] = src.[Payment_Method]
				,[Delivery_Mode] = src.[Delivery_Mode]
				,[Receipt_Email] = src.[Receipt_Email]
				,[Delivery_Address_Description] = src.[Delivery_Address_Description]
				,[Delivery_Address_Zip_Code] = src.[Delivery_Address_Zip_Code]
				,[Delivery_Address_City] = src.[Delivery_Address_City]
				,[Delivery_Address_Country_Region_ID] = src.[Delivery_Address_Country_Region_ID]
				,[Delivery_Address_County] = src.[Delivery_Address_County]
				,[Delivery_Address_State] = src.[Delivery_Address_State]
				,[Delivery_Address_Street] = src.[Delivery_Address_Street]
				,[Delivery_Address_Street_Number] = src.[Delivery_Address_Street_Number]
				,[Delivery_Address_Valid_From] = src.[Delivery_Address_Valid_From]
				,[Delivery_Address_Valid_To] = src.[Delivery_Address_Valid_To]
				,[Email_Contact_Pref_ID] = src.[Email_Contact_Pref_ID]
				,[Phone_Contact_Pref_ID] = src.[Phone_Contact_Pref_ID]
				,[Direct_Mail_Contact_Pref_ID] = src.[Direct_Mail_Contact_Pref_ID]
				,[Rental_Contact_Pref_ID] = src.[Rental_Contact_Pref_ID]
				,[Created_Date_Time] = src.[Created_Date_Time]
				,[Modified_Date_Time] = src.[Modified_Date_Time]
				,[On_Hold_Status] = src.[On_Hold_Status]
				,[is_Business_Address] = src.[is_Business_Address]
				,[is_Delivery_Address] = src.[is_Delivery_Address]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1)
	WHEN NOT MATCHED BY SOURCE
		AND tgt.[is_Removed_From_Source] <> 1
		THEN
			UPDATE
			SET tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1);

	UPDATE Administration.Procedure_Updates
	SET [Status] = 'SUCCESS'
		,Affected_Rows = @@ROWCOUNT
		,End_Date = getdate()
	WHERE Procedure_Update_Key = @procedureUpdateKey_
END TRY

BEGIN CATCH
	IF @procedureUpdateKey_ <> 0
		UPDATE [Administration].Procedure_Updates
		SET [Status] = 'FAILED'
			,Error = ERROR_MESSAGE()
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH
