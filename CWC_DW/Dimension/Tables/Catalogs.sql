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
CREATE TRIGGER [Dimension].[tr_Catalogs_Audit] 
ON [Dimension].[Catalogs] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Catalogs]', @Operation, @RecordCount
END