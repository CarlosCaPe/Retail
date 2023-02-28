CREATE TABLE [Fact].[Forecast] (
    [Forecast_Date_Key]      INT           NOT NULL,
    [Forecast_Date]          DATE          NULL,
    [Print_Cycle]            VARCHAR (25)  NULL,
    [Pct_Week]               FLOAT (53)    NULL,
    [Demand]                 INT           NULL,
    [Orders]                 INT           NULL,
    [Units]                  INT           NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    CONSTRAINT [PK_Forecast] PRIMARY KEY CLUSTERED ([Forecast_Date_Key] ASC)
);




GO
CREATE TRIGGER [Fact].[tr_Forecast_Audit] 
ON [Fact].Forecast 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Forecast]', @Operation, @RecordCount
END