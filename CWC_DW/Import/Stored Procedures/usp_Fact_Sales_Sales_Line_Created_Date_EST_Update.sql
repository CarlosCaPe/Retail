
CREATE PROC [Import].[usp_Fact_Sales_Sales_Line_Created_Date_EST_Update] AS

WITH Sales_Date AS
	(
		SELECT 
		 Sales_Key
		,Sales_Line_Created_Date_EST = DATEADD(hh,(select cast(replace(current_utc_offset,':00','') as int)  from [sys].[time_zone_info] tz
															where tz.name = 'US Eastern Standard Time'),s.[Sales_Line_Created_Date])
		FROM CWC_DW.Fact.Sales (NOLOCK) s
	)
UPDATE s
SET Sales_Line_Created_Date_EST = sd.Sales_Line_Created_Date_EST
FROM CWC_DW.Fact.Sales (NOLOCK) s
INNER JOIN Sales_Date sd ON s.Sales_Key = sd.Sales_Key
WHERE ISNULL(s.Sales_Line_Created_Date_EST,'') <> ISNULL(sd.Sales_Line_Created_Date_EST,'')
;

