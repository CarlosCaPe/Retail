CREATE TABLE [Dimension].[Inventory_Journal_Properties] (
    [Inventory_Journal_Property_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Counting_Reason_CD]             VARCHAR (50)  NOT NULL,
    [Inventory_Status_CD]            VARCHAR (50)  NULL,
    [Counting_Reason]                VARCHAR (50)  NOT NULL,
    [Inventory_Status]               VARCHAR (50)  NULL,
    [is_Removed_From_Source]         BIT           NOT NULL,
    [ETL_Created_Date]               DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]              DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]             TINYINT       NOT NULL,
    CONSTRAINT [PK_Inventory_Journal_Properties] PRIMARY KEY CLUSTERED ([Inventory_Journal_Property_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Inventory_Journal_Properties_Audit] ON [Dimension].[Inventory_Journal_Properties]
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Inventory_Journal_Property_Key = d.Inventory_Journal_Property_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Inventory_Journal_Property_Key = d.Inventory_Journal_Property_Key
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Inventory_Journal_Properties]'
		,@Operation
		,@RecordCount
END