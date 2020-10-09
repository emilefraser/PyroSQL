SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
CREATE PROCEDURE [LOG].[sp_FlowExecutionLog]
(
    @FlowName varchar(max),
	@MasterEntity varchar(max),
	@TransactionData varchar(max),
	@TransactionPerson varchar(max),
	@IsError bit
)
AS
BEGIN
	
	DECLARE @LogDT datetime2(7) = GetDate() --date of log entry
	DECLARE @Inputs varchar(max) --inputs received into flow execution step
	DECLARE @Outputs varchar(max) -- outputs receieved from flow execution step
	DECLARE @ErrorDescription varchar(max)-- error desc if IsError = true

		--testing
	--DECLARE @IsError bit = 1
	--declare @TransactionData varchar(max) = '[{"name":"Execute_stored_procedure","inputs":{"method":"post","path":"/datasets/default/procedures/%255BAPP%255D.%255Bsp_CRUD_Role%255D","host":{"api":{"runtimeUrl":"https://europe-002.azure-apim.net/apim/sql"},"connection":{"name":"/providers/Microsoft.PowerApps/apis/shared_sql/connections/5cb71a8626ad451181998c804460352a"}},"authentication":{"value":"Key eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlV6NnlhaGotbDBfUzNuWUZCZWhmSmtVcFVCSSJ9.eyJ0cyI6IjliMDgyOWI5LWJlMzktNDMzNi1hNzY2LWY4YzlkYzJjNzFhNCIsImNzIjoiZXVyb3BlLTAwMi9sb2dpY2Zsb3dzLzUxY2RlNzEwODQwMjRkNzNhNGNhODUwODczZThmN2FmLTc0NWQ3MWEzMGY4ZjNmMjgiLCJ2IjoiOTIyMzM3MjAzNjg1NDc3NTgwNyIsImlzcyI6Imh0dHBzOi8vZXVyb3BlLTAwMi5henVyZS1hcGltLm5ldC8iLCJleHAiOjE1Nzc5NDg3MDksIm5iZiI6MTU3NTI3MDMwOX0.hfNrqVpQeMqSg6dwg6fCEV8nRavjRDnrkwxJuiADUbZUgkGQWpP8XlmmGZ4b_KDohIBTCK-38rhkH4JZjri7f5nTIlfCda7nUZXbv7WetyYv0pcbBho_MnNZLBUJ2ghXVmBOTWsFiTI3HYorUtYE5ks9C20hRwWvs69iA-j2BNPwiR9QuP5ZKMdkeDMZ6ccOaHCog_QeUaS7knXEHUJeTDxTEONC-XWIDii1h3qvUV9JLyFYuWjsd1xH5JOWdlJIlMN9NbSoIGlQiifNSF9iiVXYilM7q-G9s5FKoYWaVPVzBHptBBSUgJIAJUUWJ4r6oqlTOzRoPGcNQIYt6baGyQ","type":"Raw"},"body":{"MasterEntity":"DataManager Configuration","RoleCode":"AWEEEEEEEEEEEE","RoleDescription":"haha ","RoleID":0,"TransactionAction":"Create","TransactionPerson":"MPereira@tharisa.com"}},"outputs":{"statusCode":502,"headers":{"Pragma":"no-cache","x-ms-datasourceerror":"True","x-ms-request-id":"12f833c6-7b1f-44fb-ae2e-17e69f43f81c","Strict-Transport-Security":"max-age=31536000; includeSubDomains","X-Content-Type-Options":"nosniff","X-Frame-Options":"DENY","Timing-Allow-Origin":"*","x-ms-apihub-cached-response":"true","Cache-Control":"no-store, no-cache","Date":"Tue, 03 Dec 2019 11:40:36 GMT","Content-Length":"516","Content-Type":"application/json","Expires":"-1"},"body":{"error":{"code":502,"source":"europe-002.azure-apim.net","clientRequestId":"12f833c6-7b1f-44fb-ae2e-17e69f43f81c","message":"BadGateway","innerError":{"status":502,"message":"Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.\r\nclientRequestId: 12f833c6-7b1f-44fb-ae2e-17e69f43f81c","source":"sql-we.azconn-we.p.azurewebsites.net"}}}},"startTime":"2019-12-03T11:40:23.1056382Z","endTime":"2019-12-03T11:40:37.0669222Z","trackingId":"16c6381e-23f2-48f4-8a12-244c8ab3620b","clientTrackingId":"08586263183880432537308408641CU75","code":"BadGateway","status":"Failed","retryHistory":[{"startTime":"2019-12-03T11:40:23.1056382Z","endTime":"2019-12-03T11:40:23.5288183Z","code":"BadGateway","clientRequestId":"6536f08c-6d03-4044-a14f-12770990b835","serviceRequestId":"6536f08c-6d03-4044-a14f-12770990b835"},{"startTime":"2019-12-03T11:40:28.6132663Z","endTime":"2019-12-03T11:40:28.7695156Z","code":"BadGateway","clientRequestId":"b6d159b4-2084-4a27-9836-84fe717a1601","serviceRequestId":"b6d159b4-2084-4a27-9836-84fe717a1601"}]}]'
	--end testing

	SET @TransactionData = SUBSTRING(SUBSTRING(@TransactionData, 1, LEN(@TransactionData) - 1), 2, LEN(@TransactionData)) -- remove '[' and ']' outer brackets from json object
	
	SET @Inputs = JSON_QUERY(@TransactionData, '$.inputs.body') --extract flow execution step inputs
	--select @Inputs --test
	
	SET @Outputs = JSON_QUERY(@TransactionData, '$.outputs.body') --extract flow execution step outputs
	--select @Outputs--test
	
	SET @TransactionData = '{}' --reset full response received
	SET @TransactionData = JSON_MODIFY(@TransactionData, '$.Inputs', @Inputs) -- add inputs to empty json string
	SET @TransactionData = JSON_MODIFY(@TransactionData, '$.Ouputs', @Outputs) -- append outputs to json string
	
	--select @TransactionData --test
	
	
	IF @IsError = 1 --if there is an error
		BEGIN
			SET @ErrorDescription = JSON_VALUE(@Outputs, '$.message') --get error message
			IF @ErrorDescription IS NULL
				BEGIN
					SET @ErrorDescription = JSON_VALUE(@Outputs, '$.error.innerError.message') --get error message
				END
			select @ErrorDescription --test
		END
	
	
	INSERT INTO [LOG].[FlowExecutionLog](
											FlowName , 
											MasterEntity ,
											TransactionData , 
											TransactionPerson , 
											IsError , 
											ErrorDescription , 
											LogDT
										)
	VALUES(
			@FlowName , 
			@MasterEntity , 
			@TransactionData , 
			@TransactionPerson , 
			@IsError ,
			@ErrorDescription, 
			@LogDT
		)


END

GO
