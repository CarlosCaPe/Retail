CREATE TABLE [Dimension].[Inventory_Journal_Types] (
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


CREATE TRIGGER [Dimension].[tr_Inventory_Journal_Types_Audit] 
ON [Dimension].[Inventory_Journal_Types] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Inventory_Journal_Types]', @Operation, @RecordCount
END