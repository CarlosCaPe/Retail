

CREATE VIEW [Power_BI].[v_Selling_Report_Locations]

AS

SELECT 
	 [Location Key] = [Location_Key]
    ,[Delivery Street] = l.Street
	,[Delivery City] = l.City
	,[Delivery State] = ISNULL(l.State,'{-No State-}')
	,[Delivery Country] = l.Country
	,[Delivery Zip Code] = l.Zip_Code
  FROM [CWC_DW].[Dimension].[Locations] (NOLOCK) l;

