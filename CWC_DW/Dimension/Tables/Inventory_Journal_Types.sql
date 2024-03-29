﻿CREATE TABLE [Dimension].[Inventory_Journal_Types] (
    [Inventory_Journal_Type_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Inventory_Journal_Type_CD]  VARCHAR (5)   NULL,
    [Inventory_Journal]          VARCHAR (25)  NULL,
    [is_Removed_From_Source]     BIT           NULL,
    [ETL_Created_Date]           DATETIME2 (5) NULL,
    [ETL_Modified_Date]          DATETIME2 (5) NULL,
    [ETL_Modified_Count]         TINYINT       NULL,
    CONSTRAINT [PK_Inventory_Journal_Types] PRIMARY KEY CLUSTERED ([Inventory_Journal_Type_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Inventory_Journal_Types_Audit] ON [Dimension].[Inventory_Journal_Types]
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
					INNER JOIN deleted d ON i.Inventory_Journal_Type_Key = d.Inventory_Journal_Type_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Inventory_Journal_Type_Key = d.Inventory_Journal_Type_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Inventory_Journal_Types]'
		,@Operation
		,@RecordCount
END