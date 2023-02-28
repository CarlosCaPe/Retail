CREATE TABLE [Fact].[Backorder_Relief_Summary] (
    [Product_Key]                   INT             NOT NULL,
    [Fiscal_Week_Year_Index]        INT             NOT NULL,
    [Fiscal_Week_Year]              VARCHAR (20)    NOT NULL,
    [Backorder_Amount]              NUMERIC (18, 6) NULL,
    [Backorder_Quantity]            SMALLINT        NULL,
    [Backorder_Average_Unit_Retail] NUMERIC (18, 6) NULL,
    [Backorder_Relief_Quantity]     SMALLINT        NULL,
    [Bakcorder_Releif_Amount]       NUMERIC (18, 6) NULL,
    [Backorder_Remainder_Quantity]  SMALLINT        NULL,
    [Backorder_Remainder_Amount]    NUMERIC (30, 6) NULL,
    [is_Show_Relief]                BIT             NULL,
    CONSTRAINT [PK_Backorder_Relief_Summary] PRIMARY KEY CLUSTERED ([Product_Key] ASC, [Fiscal_Week_Year_Index] ASC)
);




GO
CREATE TRIGGER [Fact].[tr_Backorder_Relief_Summary_Audit] 
ON [Fact].[Backorder_Relief_Summary] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Backorder_Relief_Summary]', @Operation, @RecordCount
END