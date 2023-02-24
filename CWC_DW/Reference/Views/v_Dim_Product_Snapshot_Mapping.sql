CREATE VIEW Reference.v_Dim_Product_Snapshot_Mapping AS

WITH Date_Range AS
(
SELECT Start_Date = MIN([Snapshot_Date_Key]),Stop_Date = MAX([Snapshot_Date_Key])
FROM [CWC_DW].[Fact].[Inventory]
)

SELECT [Snapshot_Date_Key] = d.Date_Key,p.Product_Key
FROM [CWC_DW].[DImension].[Products] p
	CROSS JOIN Date_Range dr
	CROSS JOIN [CWC_DW].[Dimension].[Dates] d
WHERE d.Date_Key BETWEEN dr.Start_Date AND dr.Stop_Date;