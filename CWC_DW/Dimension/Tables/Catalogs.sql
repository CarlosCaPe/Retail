CREATE TABLE [Dimension].[Catalogs] (
    [Catalog_Key]            SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Catalog_Number]         VARCHAR (10)  NOT NULL,
    [Catalog_Name]           VARCHAR (60)  NOT NULL,
    [Catalog_Description]    VARCHAR (128) NULL,
    [Catalog_Drop_Date]      DATE          NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    PRIMARY KEY CLUSTERED ([Catalog_Key] ASC),
    CONSTRAINT [UK_Catalog_Number] UNIQUE NONCLUSTERED ([Catalog_Number] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Catalogs_Audit] ON [Dimension].[Catalogs]
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
					INNER JOIN deleted d ON i.Catalog_Key = d.Catalog_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Catalog_Key = d.Catalog_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Catalogs]'
		,@Operation
		,@RecordCount
END