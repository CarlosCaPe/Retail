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
CREATE TRIGGER [Dimension].[tr_Catalog_Promotions_Audit] 
ON [Dimension].[Catalog_Promotions] 
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operation char(1)
    DECLARE @RecordCount int
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
            SET @Operation = 'U'
            SET @RecordCount = (SELECT COUNT(*) FROM inserted) -- use inserted table to count records
        END
        ELSE
        BEGIN
            SET @Operation = 'I'
            SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for insert operations
        END
    END
    ELSE
    BEGIN
        SET @Operation = 'D'
        SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for delete operations
    END
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Catalog_Promotions]', @Operation, @RecordCount
END