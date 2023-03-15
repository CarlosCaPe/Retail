CREATE TABLE [Dimension].[Shipping_Advice_Cancels] (
    [Shipping_Advice_Cancel_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [is_Canceled]                INT           NOT NULL,
    [Cancel_Reason_CD]           VARCHAR (50)  NULL,
    [Cancel]                     VARCHAR (12)  NULL,
    [Cancel_Reason]              VARCHAR (50)  NULL,
    [is_Removed_From_Source]     BIT           NOT NULL,
    [ETL_Created_Date]           DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]          DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]         SMALLINT      NOT NULL,
    CONSTRAINT [PK_Shipping_Advice_Cancels] PRIMARY KEY CLUSTERED ([Shipping_Advice_Cancel_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Shipping_Advice_Cancels_Audit] ON [Dimension].[Shipping_Advice_Cancels]
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
					INNER JOIN deleted d ON i.Shipping_Advice_Cancel_Key = d.Shipping_Advice_Cancel_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Shipping_Advice_Cancel_Key = d.Shipping_Advice_Cancel_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Shipping_Advice_Cancels]'
		,@Operation
		,@RecordCount
END