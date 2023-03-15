
CREATE PROC [Import].[usp_Reference_Inventory_Statuses_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT Inventory_Status_ID = [STATUSID]
			,Inventory_Status = [STATUSNAME]
			,is_Will_Block_Inventory = CAST([WILLSTATUSBLOCKINVENTORY] AS BIT)
		FROM [Entity_Staging].[dbo].[WHSInventoryStatusStaging]
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Reference].[Inventory_Statuses]
		)
	MERGE INTO tgt
	USING src
		ON src.Inventory_Status_ID = tgt.Inventory_Status_ID
	WHEN NOT MATCHED
		THEN
			INSERT (
				Inventory_Status_ID
				,Inventory_Status
				,is_Will_Block_Inventory
				)
			VALUES (
				src.Inventory_Status_ID
				,src.Inventory_Status
				,src.is_Will_Block_Inventory
				)
	WHEN MATCHED
		AND ISNULL(tgt.Inventory_Status, '') <> ISNULL(src.Inventory_Status, '')
		OR ISNULL(tgt.is_Will_Block_Inventory, '') <> ISNULL(src.is_Will_Block_Inventory, '')
		THEN
			UPDATE
			SET Inventory_Status = src.Inventory_Status
				,is_Will_Block_Inventory = src.is_Will_Block_Inventory;

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