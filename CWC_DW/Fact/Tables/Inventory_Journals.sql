CREATE TABLE [Fact].[Inventory_Journals] (
    [Inventory_Journal_Key]          INT           IDENTITY (1, 1) NOT NULL,
    [Rec_ID]                         BIGINT        NOT NULL,
    [Journal_ID]                     VARCHAR (15)  NOT NULL,
    [Journal_Date]                   DATE          NOT NULL,
    [Journal_Date_Key]               INT           NOT NULL,
    [Product_Key]                    INT           NOT NULL,
    [Inventory_Journal_Property_Key] TINYINT       NOT NULL,
    [Inventory_Journal_Type_Key]     TINYINT       NOT NULL,
    [Inventory_Warehouse_Key]        TINYINT       NOT NULL,
    [Line_Number]                    SMALLINT      NOT NULL,
    [Quantity]                       INT           NOT NULL,
    [is_Removed_From_Source]         BIT           NOT NULL,
    [ETL_Created_Date]               DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]              DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]             TINYINT       NOT NULL,
    CONSTRAINT [UX_Rec_ID] UNIQUE NONCLUSTERED ([Rec_ID] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Inventory_Journals_Audit] ON [Fact].Inventory_Journals
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
					INNER JOIN deleted d ON i.Rec_ID = d.Rec_ID
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Rec_ID = d.Rec_ID
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Inventory_Journals]'
		,@Operation
		,@RecordCount
END