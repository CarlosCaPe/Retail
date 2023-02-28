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
CREATE TRIGGER [Dimension].[tr_Inventory_Journal_Properties_Audit] 
ON [Dimension].[Inventory_Journal_Properties] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Inventory_Journal_Properties]', @Operation, @RecordCount
END