CREATE TABLE [Fact].[Demand_Summary] (
    [Date_Key]                    INT             NOT NULL,
    [Demand]                      NUMERIC (38, 6) NULL,
    [Units]                       INT             NULL,
    [Orders]                      INT             NULL,
    [Amount_Canceled]             NUMERIC (38, 6) NULL,
    [Units_Canceled]              INT             NULL,
    [Amount_Backorder]            NUMERIC (38, 6) NULL,
    [Units_Backorder]             INT             NULL,
    [Orders_Backorder]            INT             NULL,
    [Backorder_Shipped_Amount]    NUMERIC (38, 6) NULL,
    [Backorder_Shipped_Quantity]  INT             NULL,
    [Backorder_Canceled_Amount]   NUMERIC (38, 6) NULL,
    [Backorder_Canceled_Quantity] INT             NULL,
    [is_Removed_From_Source]      BIT             NULL,
    [ETL_Created_Date]            DATETIME2 (5)   NULL,
    [ETL_Modified_Date]           DATETIME2 (5)   NULL,
    [ETL_Modified_Count]          SMALLINT        NULL,
    CONSTRAINT [PK_Demand_Summary] PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);




GO
CREATE TRIGGER [Fact].[tr_Demand_Summary_Audit] 
ON [Fact].Demand_Summary 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Demand_Summary]', @Operation, @RecordCount
END