
CREATE PROC [Import].[usp_Dimension_Employees_Merge]

AS

WITH emp AS
(
	SELECT 
		 Personnel_Number = e.PersonnelNumber
		,User_ID =  u.Userid
		,Employee_Full_Name = e.Name
		,Username =  u.Username
		
		,License_Source = CASE 
			WHEN left(PERSONNELNUMBER,2) = 'CC' THEN 'Global Response'
			WHEN left(PERSONNELNUMBER,2) = 'CU' THEN 'ContactUS'
			WHEN isnumeric(PERSONNELNUMBER) = 1 THEN 'CWD Corporate'
			WHEN (left(PERSONNELNUMBER,3) in ('CWC','CWD','CWS') and EMPLOYMENTSTARTDATE = '2018-11-17 05:00:00.000') THEN 'Global Response'
			WHEN left(PERSONNELNUMBER,3) = 'GEO' THEN 'GEODIS'
			WHEN left(PERSONNELNUMBER,2) = 'VN' THEN 'Visionet'
			WHEN left(PERSONNELNUMBER,3) in ('CWC','CWD') THEN 'CWD Corporate'
			WHEN left(PERSONNELNUMBER,3) = 'CWI' THEN 'CWI Corporate'
			WHEN left(PERSONNELNUMBER,2) = 'VN' THEN 'Visionet'
			WHEN left(PERSONNELNUMBER,2) = 'IQ' THEN 'iQor'
		END 
		,Summary_Valid_From = CAST(NULLIF(SUMMARYVALIDFROM,'1900-01-01 00:00:00.000') AS DATETIME2(5))
		,Start_Date = CAST(e.EmploymentStartDate AS DATE)
		/*,End_Date = CASE 
						WHEN DATEADD(DAY,-1,LEAD(CAST(e.EmploymentStartDate AS DATE), 1) OVER(PARTITION BY e.Name ORDER BY CAST(e.EmploymentStartDate AS DATE) ASC)) < CAST(e.EmploymentStartDate AS DATE) THEN CAST(e.EmploymentStartDate AS DATE) 
						ELSE DATEADD(DAY,-1,LEAD(CAST(e.EmploymentStartDate AS DATE), 1) OVER(PARTITION BY e.Name ORDER BY CAST(e.EmploymentStartDate AS DATE) ASC))
					END*/
		,is_Active =  ISNULL(u.Enabled,0)
		,Seq = row_number() over (partition by e.PersonnelNumber order by ISNULL(u.Enabled,0) DESC,SUMMARYVALIDFROM)
	FROM [AX_PRODUCTION].[dbo].[HcmEmployeeStaging] e (NOLOCK)
	LEFT JOIN [AX_PRODUCTION].[dbo].[SystemUserStaging] u (NOLOCK) on ltrim(rtrim(u.username)) = ltrim(rtrim(e.name))
	--WHERE u.UserID IN ('myramae.lim','lovelyann.hembra')
)
,src AS
(
	SELECT 
		 [Personnel_Number]
		,[User_ID]
		,[Employee_Full_Name]
		,[License_Source]
		
		,[Start_Date]
		,[End_Date] = CASE 
						WHEN DATEADD(DAY,-1,LEAD([Start_Date], 1) OVER(PARTITION BY [Personnel_Number] ORDER BY [Start_Date] ASC)) < [Start_Date] THEN [Start_Date]
						ELSE DATEADD(DAY,-1,LEAD([Start_Date], 1) OVER(PARTITION BY [Personnel_Number] ORDER BY [Start_Date] ASC))
					END
		,[Summary_Valid_From]
		,[is_Active] 
		,[is_Removed_From_Source] = CAST(0 AS BIT)
		,[is_Excluded] = CAST(0 AS BIT)
		,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	FROM emp
	WHERE seq = 1
)--SELECT * FROM src WHERE Personnel_Number = 'CC-010921-SS'
,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Employees] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.[Personnel_Number] = src.[Personnel_Number] AND tgt.[Start_Date] = src.[Start_Date]
		WHEN NOT MATCHED THEN
			INSERT([Personnel_Number],[User_ID],[Employee_Full_Name],[License_Source],[Start_Date],[End_Date],[Summary_Valid_From],[is_Active]
				  ,[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Personnel_Number],src.[User_ID],src.[Employee_Full_Name],src.[License_Source],src.[Start_Date],src.[End_Date],src.[Summary_Valid_From],src.[is_Active]
				  ,src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
		      ISNULL(tgt.[User_ID],'') <> ISNULL(src.[User_ID],'')
		   OR ISNULL(tgt.[Employee_Full_Name],'') <> ISNULL(src.[Employee_Full_Name],'')
		   OR ISNULL(tgt.[License_Source],'') <> ISNULL(src.[License_Source],'')
		   OR ISNULL(tgt.[End_Date],'') <> ISNULL(src.[End_Date],'')
		   OR ISNULL(tgt.[Summary_Valid_From],'') <> ISNULL(src.[Summary_Valid_From],'')
		   OR ISNULL(tgt.[is_Active],'') <> ISNULL(src.[is_Active],'')
		   OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		   --OR ISNULL(tgt.[is_Excluded],'') <> ISNULL(src.[is_Excluded],'')
		THEN UPDATE SET
		    [User_ID] = src.[User_ID]
		   ,[Employee_Full_Name] = src.[Employee_Full_Name]
		   ,[License_Source] = src.[License_Source]
		   ,[End_Date] = src.[End_Date]
		   ,[Summary_Valid_From] = src.[Summary_Valid_From]
		   ,[is_Active] = src.[is_Active]
		   ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
		   --,[is_Excluded] = src.[is_Excluded]
		   ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
		   ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
