CREATE TABLE [Fact].[Trade_Agreement_Prices] (
    [Trade_Agreement_Price_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Product_Key]               INT             NOT NULL,
    [Price_Disc_Rec_ID]         BIGINT          NOT NULL,
    [Price]                     NUMERIC (18, 6) NOT NULL,
    [Start_Date]                DATE            NOT NULL,
    [End_Date]                  DATE            NOT NULL,
    [is_Removed_From_Source]    BIT             NOT NULL,
    [ETL_Created_Date]          DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]         DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]        INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([Trade_Agreement_Price_Key] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Product_Key]
    ON [Fact].[Trade_Agreement_Prices]([Product_Key] ASC, [is_Removed_From_Source] ASC, [Start_Date] ASC, [End_Date] ASC);


GO
 CREATE TRIGGER [Fact].[tr_Trade_Agreement_Prices_Audit] ON [Fact].Trade_Agreement_Prices
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
					INNER JOIN deleted d ON i.Trade_Agreement_Price_Key = d.Trade_Agreement_Price_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Trade_Agreement_Price_Key = d.Trade_Agreement_Price_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Trade_Agreement_Prices]'
		,@Operation
		,@RecordCount
END