
CREATE VIEW [Power_BI].[v_Dim_B2B]

AS

SELECT
[B2B Key] = 1
,[B2B] = 'Yes'

UNION ALL

SELECT
[Baked Key] = 2
,[B2B] = 'No';
