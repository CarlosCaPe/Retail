
CREATE VIEW [Power_BI].[v_Dim_Baked]

AS

SELECT
[Baked Key] = 1
,[Baked] = 'Yes'

UNION ALL

SELECT
[Baked Key] = 2
,[Baked] = 'No';
