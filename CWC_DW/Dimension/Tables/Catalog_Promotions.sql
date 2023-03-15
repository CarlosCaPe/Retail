CREATE TABLE [Dimension].[Catalog_Promotions] (
    [Catalog_Promotion_Key]  INT            IDENTITY (1, 1) NOT NULL,
    [Catalog_Key]            SMALLINT       NULL,
    [Source_CD]              VARCHAR (50)   NULL,
    [Coupon_CD]              VARCHAR (60)   NULL,
    [Catalog_Number]         VARCHAR (10)   NULL,
    [Catalog_Name]           VARCHAR (60)   NULL,
    [Catalog_Description]    VARCHAR (150)  NULL,
    [Catalog_Drop_Date]      DATE           NULL,
    [Promotion_Message]      NVARCHAR (400) NULL,
    [is_Removed_From_Source] BIT            NULL,
    [ETL_Created_Date]       DATETIME2 (5)  NULL,
    [ETL_Modified_Date]      DATETIME2 (5)  NULL,
    [ETL_Modified_Count]     SMALLINT       NULL,
    CONSTRAINT [PK_Catalog_Promotions] PRIMARY KEY CLUSTERED ([Catalog_Promotion_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Catalog_Promotions_Audit] ON [Dimension].[Catalog_Promotions]
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
					INNER JOIN deleted d ON i.Catalog_Promotion_Key = d.Catalog_Promotion_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Catalog_Promotion_Key = d.Catalog_Promotion_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Catalog_Promotions]'
		,@Operation
		,@RecordCount
END