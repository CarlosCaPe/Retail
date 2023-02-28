CREATE TABLE [Dimension].[Vendors] (
    [Vendor_Key]                       SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Vendor_Account_Number]            VARCHAR (50)  NOT NULL,
    [Vendor_Group]                     VARCHAR (50)  NOT NULL,
    [Vendor_Organization_Name]         VARCHAR (100) NOT NULL,
    [Default_Delivery_Mode_CD]         VARCHAR (10)  NULL,
    [Default_Delivery_Mode]            VARCHAR (50)  NULL,
    [Default_Delivery_Terms_CD]        VARCHAR (15)  NULL,
    [Default_Delivery_Terms]           VARCHAR (61)  NULL,
    [Default_Vendor_Payment_Method_CD] VARCHAR (15)  NULL,
    [Default_Vendor_Payment_Method]    VARCHAR (50)  NULL,
    [Address_Description]              VARCHAR (60)  NULL,
    [Address_State_ID]                 VARCHAR (50)  NULL,
    [Address_Street]                   VARCHAR (250) NULL,
    [Address_City]                     VARCHAR (60)  NULL,
    [Address_Zip_Code]                 VARCHAR (50)  NULL,
    [Address_Country_Region_ID]        VARCHAR (50)  NULL,
    [Country_Name]                     VARCHAR (100) NULL,
    [is_Removed_From_Source]           BIT           NULL,
    [is_Excluded]                      BIT           NULL,
    [ETL_Created_Date]                 DATETIME2 (5) NULL,
    [ETL_Modified_Date]                DATETIME2 (5) NULL,
    [ETL_Modified_Count]               TINYINT       NULL,
    CONSTRAINT [PK_Vendors] PRIMARY KEY CLUSTERED ([Vendor_Key] ASC),
    CONSTRAINT [UK_Vendors] UNIQUE NONCLUSTERED ([Vendor_Account_Number] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Vendors_Audit] 
ON [Dimension].[Vendors] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Vendors]', @Operation, @RecordCount
END