﻿CREATE PROCEDURE [procfwk].[CreateNewExecution]
	(
	@CallingDataFactoryName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocalExecutionId UNIQUEIDENTIFIER = NEWID()

	TRUNCATE TABLE [procfwk].[CurrentExecution];

	INSERT INTO [procfwk].[CurrentExecution]
		(
		[LocalExecutionId],
		[StageId],
		[PipelineId],
		[CallingDataFactoryName],
		[ResourceGroupName],
		[DataFactoryName],
		[PipelineName]
		)
	SELECT
		@LocalExecutionId,
		p.[StageId],
		p.[PipelineId],
		@CallingDataFactoryName,
		d.[ResourceGroupName],
		d.[DataFactoryName],
		p.[PipelineName]
	FROM
		[procfwk].[Pipelines] p
		INNER JOIN [procfwk].[Stages] s
			ON p.[StageId] = s.[StageId]
		INNER JOIN [procfwk].[DataFactorys] d
			ON p.[DataFactoryId] = d.[DataFactoryId]
	WHERE
		p.[Enabled] = 1
		AND s.[Enabled] = 1
		AND (charindex(left(datename(month,getdate()),3),p.[ScheduleMonthOfYear]) > 0 OR p.[ScheduleMonthOfYear] = '*')
		AND (charindex(left(datename(weekday,getdate()),3),p.[ScheduleDayOfWeek]) > 0 OR p.[ScheduleDayOfWeek] = '*')
		AND (charindex(',' + datename(day,getdate()) + ',' , ',' + p.[ScheduleDayOfMonth] + ',') > 0 OR p.[ScheduleDayOfMonth] = '*')

	ALTER INDEX [IDX_GetPipelinesInStage] ON [procfwk].[CurrentExecution]
	REBUILD;

	SELECT
		@LocalExecutionId AS ExecutionId
END;