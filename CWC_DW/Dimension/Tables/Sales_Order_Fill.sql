CREATE TABLE [Dimension].[Sales_Order_Fill] (
    [Sales_Order_Fill_Key]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [Fill_CD]                TINYINT      NOT NULL,
    [Sales_Order_Fill]       VARCHAR (50) NOT NULL,
    [Fill_Days]              VARCHAR (50) NOT NULL,
    [Fill_Days_Index]        TINYINT      NULL,
    [Sales_Order_Days]       VARCHAR (50) NULL,
    [Sales_Order_Days_Index] TINYINT      NULL,
    [1_Day_Fill]             VARCHAR (50) NOT NULL,
    [7_Day_Fill]             VARCHAR (50) NOT NULL,
    [30_Day_Fill]            VARCHAR (50) NOT NULL,
    [60_Day_Fill]            VARCHAR (50) NOT NULL,
    [90_Day_Fill]            VARCHAR (50) NOT NULL,
    [120_Day_Fill]           VARCHAR (50) NOT NULL,
    [Over_120_Day_Fill]      VARCHAR (50) NOT NULL,
    [Range_Start]            SMALLINT     NOT NULL,
    [Range_Stop]             SMALLINT     NULL,
    CONSTRAINT [PK__Sales_Or__00E3FB8F287C2450] PRIMARY KEY CLUSTERED ([Sales_Order_Fill_Key] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Sales_Order_Fill_Audit] 
ON [Dimension].[Sales_Order_Fill] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Sales_Order_Fill]', @Operation, @RecordCount
END