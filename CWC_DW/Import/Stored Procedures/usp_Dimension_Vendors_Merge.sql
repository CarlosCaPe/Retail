
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Dimension_Vendors_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT --TOP (2000) 
			[Vendor_Account_Number] = [VENDORACCOUNTNUMBER]
			,[Vendor_Group] = CASE VENDORGROUPID
				WHEN 'INV'
					THEN 'Invoice'
				WHEN 'NON-INV'
					THEN 'Non Invoice'
				ELSE VENDORGROUPID
				END
			,[Vendor_Organization_Name] = [VENDORORGANIZATIONNAME]
			,[Default_Delivery_Mode_CD] = NULLIF([DEFAULTDELIVERYMODEID], '')
			,[Default_Delivery_Mode] = CAST(CASE NULLIF([DEFAULTDELIVERYMODEID], '')
					WHEN 'STANDARD'
						THEN 'Standard Ground'
					WHEN '2Day'
						THEN '2-Day Air'
					WHEN ''
						THEN NULL
					WHEN 'OVERNT'
						THEN 'FedEx Overnight'
					WHEN 'Pickup'
						THEN 'Pickup'
					WHEN 'AIR'
						THEN 'Air'
					WHEN 'ATHB'
						THEN 'Thailand Bangkok Air'
					WHEN 'APEL'
						THEN 'Peru Lima Ocean'
					WHEN 'OINC'
						THEN 'India Chennai Ocean'
					WHEN 'OVNH'
						THEN 'Vietnam Ho Chi Minh Ocean'
					WHEN 'TUSI'
						THEN 'US Indiana Truck'
					WHEN 'ACNX'
						THEN 'India Chennai Air'
					WHEN 'OHKH'
						THEN 'Hong Kong Ocean'
					WHEN 'OCNS'
						THEN 'China Shanghai Ocean'
					WHEN 'OCNN'
						THEN 'China Ningbo Ocean'
					WHEN 'OCNX'
						THEN 'China Xiamin Ocean'
					WHEN 'OCNQ'
						THEN 'China QingDao Ocean'
					WHEN 'OINM'
						THEN 'India Mudra Ocean'
					WHEN 'OTHL'
						THEN 'Thailand Laem Chabang Oce Thaian'
					WHEN 'OCNQ'
						THEN 'China QingDao Ocean'
					WHEN 'TUSL'
						THEN 'US Lakeville Truck'
					WHEN 'OEGA'
						THEN 'Egypt Alexandria Ocean'
					WHEN 'AIDJ'
						THEN 'Indonesia Jakarta Air'
					WHEN 'AGTL'
						THEN 'Guatemala La Aurora Air'
					WHEN 'AHKH'
						THEN 'Hong Kong Hong Kong Air'
					WHEN 'OIDJ'
						THEN 'Indonesia Jakarta Ocean'
					WHEN 'AEGA'
						THEN 'Egypt Alexandria Air'
					WHEN 'OGTL'
						THEN 'Guatemala La Aurora OCN'
					WHEN 'AVNH'
						THEN 'Vietnam Ho Chi Minh Air'
					WHEN 'AINC'
						THEN 'India Chennai Air'
					WHEN 'AIND'
						THEN 'India Delhi Air'
					WHEN 'ACNN'
						THEN 'China Ningbo Air'
					WHEN 'ACNQ'
						THEN 'China QingDao Air'
					ELSE NULLIF([DEFAULTDELIVERYMODEID], '')
					END AS VARCHAR(50))
			,[Default_Delivery_Terms_CD] = NULLIF([DEFAULTDELIVERYTERMSCODE], '')
			,[Default_Delivery_Terms] = CASE NULLIF([DEFAULTDELIVERYTERMSCODE], '')
				WHEN 'CPTP'
					THEN 'FOB Vendor, Air ship mode, Vendor to pay sea / air difference'
				WHEN 'DDP'
					THEN 'Delivery Duty Paid'
				WHEN 'DDPC'
					THEN 'DDP Vendor, CWD paying freight'
				WHEN 'DDPP'
					THEN 'DDP Lakeville, Vendor paying Freight'
				WHEN 'FCAC'
					THEN 'FOB Vendor, CWD to pay air cost'
				WHEN 'FCAP'
					THEN 'FOB Vendor, Vendor to pay 100% air cost'
				WHEN 'FOB'
					THEN 'Free on Board'
				WHEN 'FOBC'
					THEN 'FOB Vendor, CWD to pay vessel cost'
				WHEN 'FOBO'
					THEN 'FOB Non Apparel Vendor, Outsource Shipping'
				WHEN 'PPD'
					THEN 'PrePaid'
				WHEN 'Standard'
					THEN 'Standard Dlv Terms'
				ELSE NULLIF([DEFAULTDELIVERYTERMSCODE], '')
				END
			,[Default_Vendor_Payment_Method_CD] = NULLIF([DEFAULTVENDORPAYMENTMETHODNAME], '')
			,[Default_Vendor_Payment_Method] = CASE NULLIF([DEFAULTVENDORPAYMENTMETHODNAME], '')
				WHEN 'CWD-CHK-WF'
					THEN 'Direct Bank of America Check'
				WHEN 'CWD-WIR-WF'
					THEN 'Bank of America Wire'
				WHEN 'RTL-CHK-WF'
					THEN 'Retail Wells Fargo Check'
				WHEN 'RTL-WIR-WF'
					THEN 'Retail Wells Fargo Wire'
				ELSE NULLIF([DEFAULTVENDORPAYMENTMETHODNAME], '')
				END
			,[Address_Description] = NULLIF([ADDRESSDESCRIPTION], '')
			,[Address_State_ID] = NULLIF([ADDRESSSTATEID], '')
			,[Address_Street] = NULLIF([ADDRESSSTREET], '')
			,[Address_City] = NULLIF([ADDRESSCITY], '')
			,[Address_Zip_Code] = NULLIF([ADDRESSZIPCODE], '')
			,[Address_Country_Region_ID] = NULLIF([ADDRESSCOUNTRYREGIONID], '')
			--,[Country_Name_Long] = c.[Country_Name_Long]
			,[Country_Name] = c.[Country_Name_Short]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
			,*
		-- TRUNCATE TABLE [CWC_DW].[Dimension].[Vendors]
		FROM [AX_PRODUCTION].[dbo].[VendVendorV2Staging] v
		LEFT JOIN [CWC_DW].[Reference].[Countries] c ON v.[ADDRESSCOUNTRYREGIONID] = c.Country_Region_ID
			--WHERE VENDORGROUPID = 'INV'
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Vendors]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Vendor_Account_Number] = src.[Vendor_Account_Number]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Vendor_Account_Number]
				,[Vendor_Group]
				,[Vendor_Organization_Name]
				,[Default_Delivery_Mode_CD]
				,[Default_Delivery_Mode]
				,[Default_Delivery_Terms_CD]
				,[Default_Delivery_Terms]
				,[Default_Vendor_Payment_Method_CD]
				,[Default_Vendor_Payment_Method]
				,[Address_Description]
				,[Address_State_ID]
				,[Address_Street]
				,[Address_City]
				,[Address_Zip_Code]
				,[Address_Country_Region_ID]
				,[Country_Name]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Vendor_Account_Number]
				,src.[Vendor_Group]
				,src.[Vendor_Organization_Name]
				,src.[Default_Delivery_Mode_CD]
				,src.[Default_Delivery_Mode]
				,src.[Default_Delivery_Terms_CD]
				,src.[Default_Delivery_Terms]
				,src.[Default_Vendor_Payment_Method_CD]
				,src.[Default_Vendor_Payment_Method]
				,src.[Address_Description]
				,src.[Address_State_ID]
				,src.[Address_Street]
				,src.[Address_City]
				,src.[Address_Zip_Code]
				,src.[Address_Country_Region_ID]
				,src.[Country_Name]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Vendor_Group], '') <> ISNULL(src.[Vendor_Group], '')
		OR ISNULL(tgt.[Vendor_Organization_Name], '') <> ISNULL(src.[Vendor_Organization_Name], '')
		OR ISNULL(tgt.[Default_Delivery_Mode_CD], '') <> ISNULL(src.[Default_Delivery_Mode_CD], '')
		OR ISNULL(tgt.[Default_Delivery_Mode], '') <> ISNULL(src.[Default_Delivery_Mode], '')
		OR ISNULL(tgt.[Default_Delivery_Terms_CD], '') <> ISNULL(src.[Default_Delivery_Terms_CD], '')
		OR ISNULL(tgt.[Default_Delivery_Terms], '') <> ISNULL(src.[Default_Delivery_Terms], '')
		OR ISNULL(tgt.[Default_Vendor_Payment_Method_CD], '') <> ISNULL(src.[Default_Vendor_Payment_Method_CD], '')
		OR ISNULL(tgt.[Default_Vendor_Payment_Method], '') <> ISNULL(src.[Default_Vendor_Payment_Method], '')
		OR ISNULL(tgt.[Address_Description], '') <> ISNULL(src.[Address_Description], '')
		OR ISNULL(tgt.[Address_State_ID], '') <> ISNULL(src.[Address_State_ID], '')
		OR ISNULL(tgt.[Address_Street], '') <> ISNULL(src.[Address_Street], '')
		OR ISNULL(tgt.[Address_City], '') <> ISNULL(src.[Address_City], '')
		OR ISNULL(tgt.[Address_Zip_Code], '') <> ISNULL(src.[Address_Zip_Code], '')
		OR ISNULL(tgt.[Address_Country_Region_ID], '') <> ISNULL(src.[Address_Country_Region_ID], '')
		OR ISNULL(tgt.[Country_Name], '') <> ISNULL(src.[Country_Name], '')
		--OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		--OR ISNULL(tgt.[is_Excluded],'') <> ISNULL(src.[is_Excluded],'')
		--OR ISNULL(tgt.[ETL_Created_Date],'') <> ISNULL(src.[ETL_Created_Date],'')
		--OR ISNULL(tgt.[ETL_Modified_Date],'') <> ISNULL(src.[ETL_Modified_Date],'')
		--OR ISNULL(tgt.[ETL_Modified_Count],'') <> ISNULL(src.[ETL_Modified_Count],'')
		THEN
			UPDATE
			SET [Vendor_Group] = src.[Vendor_Group]
				,[Vendor_Organization_Name] = src.[Vendor_Organization_Name]
				,[Default_Delivery_Mode_CD] = src.[Default_Delivery_Mode_CD]
				,[Default_Delivery_Mode] = src.[Default_Delivery_Mode]
				,[Default_Delivery_Terms_CD] = src.[Default_Delivery_Terms_CD]
				,[Default_Delivery_Terms] = src.[Default_Delivery_Terms]
				,[Default_Vendor_Payment_Method_CD] = src.[Default_Vendor_Payment_Method_CD]
				,[Default_Vendor_Payment_Method] = src.[Default_Vendor_Payment_Method]
				,[Address_Description] = src.[Address_Description]
				,[Address_State_ID] = src.[Address_State_ID]
				,[Address_Street] = src.[Address_Street]
				,[Address_City] = src.[Address_City]
				,[Address_Zip_Code] = src.[Address_Zip_Code]
				,[Address_Country_Region_ID] = src.[Address_Country_Region_ID]
				,[Country_Name] = src.[Country_Name]
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