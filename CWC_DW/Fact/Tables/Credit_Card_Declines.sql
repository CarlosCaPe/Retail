CREATE TABLE [Fact].[Credit_Card_Declines] (
    [Credit_Card_Decline_Key]       INT             IDENTITY (1, 1) NOT NULL,
    [Sales_Order_Number]            VARCHAR (50)    NOT NULL,
    [Credit_Card_Authorization_Key] INT             NOT NULL,
    [Sales_Header_Customer_Key]     INT             NULL,
    [Sales_Header_Property_Key]     SMALLINT        NULL,
    [Sales_Header_Location_Key]     INT             NULL,
    [Sales_Header_Created_Date]     DATETIME2 (5)   NULL,
    [Decline_Count]                 INT             NULL,
    [First_Decline_Date]            DATETIME2 (5)   NOT NULL,
    [Last_Decline_Date]             DATETIME2 (5)   NULL,
    [First_Decline_Amount]          NUMERIC (32, 6) NOT NULL,
    [Last_Decline_Amount]           NUMERIC (32, 6) NULL,
    [Success_Count]                 INT             NULL,
    [First_Success_Date]            DATETIME2 (5)   NULL,
    [Last_Success_Date]             DATETIME2 (5)   NULL,
    [First_Success_Amount]          NUMERIC (32, 6) NULL,
    [Last_Success_Amount]           NUMERIC (32, 6) NULL,
    [is_Removed_From_Source]        BIT             NULL,
    [is_Excluded]                   BIT             NULL,
    [ETL_Created_Date]              DATETIME2 (5)   NULL,
    [ETL_Modified_Date]             DATETIME2 (5)   NULL,
    [ETL_Modified_Count]            SMALLINT        NULL,
    CONSTRAINT [PK_Credit_Card_Declines] PRIMARY KEY CLUSTERED ([Credit_Card_Decline_Key] ASC),
    CONSTRAINT [UK_Sales_Order_Number] UNIQUE NONCLUSTERED ([Sales_Order_Number] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Credit_Card_Declines_Audit] ON [Fact].Credit_Card_Declines
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Credit_Card_Decline_Key = d.Credit_Card_Decline_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Credit_Card_Decline_Key = d.Credit_Card_Decline_Key
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Credit_Card_Declines]'
		,@Operation
		,@RecordCount
END