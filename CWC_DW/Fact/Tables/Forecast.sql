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
 CREATE TRIGGER [Fact].[tr_Forecast_Audit] ON [Fact].Forecast
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
					INNER JOIN deleted d ON i.Forecast_Date_Key = d.Forecast_Date_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Forecast_Date_Key = d.Forecast_Date_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Forecast]'
		,@Operation
		,@RecordCount
END