CREATE TABLE [Fact].[Catalog_Products] (
    [Catalog_Product_Key]    INT           IDENTITY (1, 1) NOT NULL,
    [Catalog_Key]            SMALLINT      NOT NULL,
    [Product_Key]            INT           NOT NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     SMALLINT      NULL,
    CONSTRAINT [PK_Catalog_Products] PRIMARY KEY CLUSTERED ([Catalog_Product_Key] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Catalog_Products_Audit] ON [Fact].Catalog_Products
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
					INNER JOIN deleted d ON i.Catalog_Product_Key = d.Catalog_Product_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Catalog_Product_Key = d.Catalog_Product_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Catalog_Products]'
		,@Operation
		,@RecordCount
END