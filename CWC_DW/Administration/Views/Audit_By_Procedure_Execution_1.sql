
CREATE VIEW [Administration].[Audit_By_Procedure_Execution]
AS
SELECT
	 
	 PT.PROCEDURE_NAME
	,count(PU.Procedure_Update_Key) as Executions
	,Pu.Start_Date AS Execution_Start_Date
	,PU.End_Date AS Execution_End_Date
	,DATEDIFF(minute, PU.Start_Date, PU.End_Date) AS Execution_Elapsed_Time_Minutes
	,PU.STATUS AS Execution_Status
	,ISNULL(sum(PU.Affected_Rows),0) AS Execution_Merge_Rows
	,ISNULL(sum(AT_U.Record_Count),0) AS Updated_Rows
	,ISNULL(sum(AT_I.Record_Count),0) AS Inserted_Rows
	,ISNULL(sum(AT_L.Record_Count),0) AS Logical_Deleted_Rows
FROM	
	[Administration].[Procedure_Tables] PT
	LEFT OUTER JOIN [Administration].[Procedure_Updates]	PU		ON PT.PROCEDURE_NAME = PU.PROCEDURE_NAME
	LEFT OUTER JOIN [Administration].[Audit_table]			AT_U	ON AT_U.Table_Name = PT.Table_Name
																	AND AT_U.Audit_Date BETWEEN PU.Start_Date	AND PU.End_Date
																	AND AT_U.Operation = 'U'
	LEFT OUTER JOIN [Administration].[Audit_table]			AT_I	ON AT_I.Table_Name = PT.Table_Name
																	AND AT_I.Audit_Date BETWEEN PU.Start_Date
																	AND PU.End_Date
																	AND AT_I.Operation = 'I'
	LEFT OUTER JOIN [Administration].[Audit_table]			AT_L	ON AT_L.Table_Name = PT.Table_Name
																	AND AT_L.Audit_Date BETWEEN PU.Start_Date
																	AND PU.End_Date
																	AND AT_L.Operation = 'L'

--WHERE PT.Procedure_Table_Key = 2
GROUP BY
	 PT.PROCEDURE_NAME
	,Pu.Start_Date 
	,PU.End_Date 
	,PU.STATUS