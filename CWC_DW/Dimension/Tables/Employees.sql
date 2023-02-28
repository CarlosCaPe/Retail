CREATE TABLE [Dimension].[Employees] (
    [Employee_Key]           SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Personnel_Number]       NVARCHAR (25)  NOT NULL,
    [User_ID]                NVARCHAR (20)  NULL,
    [Employee_Full_Name]     NVARCHAR (100) NOT NULL,
    [License_Source]         VARCHAR (15)   NULL,
    [Start_Date]             DATE           NOT NULL,
    [End_Date]               DATE           NULL,
    [Summary_Valid_From]     DATETIME2 (5)  NULL,
    [is_Active]              BIT            NOT NULL,
    [is_Removed_From_Source] BIT            NOT NULL,
    [is_Excluded]            BIT            NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Count]     TINYINT        NOT NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([Employee_Key] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Employees_Audit] 
ON [Dimension].[Employees] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Employees]', @Operation, @RecordCount
END