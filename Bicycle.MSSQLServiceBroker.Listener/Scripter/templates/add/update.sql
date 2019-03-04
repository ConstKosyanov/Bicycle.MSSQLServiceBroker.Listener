CREATE TRIGGER [%Scheme%].[%Table%_ServiceBrokerListenerForUpdate] ON [%Scheme%].[%Table%] FOR UPDATE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceNameForUpdate]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceNameForUpdate'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForUpdate]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM inserted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForUpdate] (@messageBody);
    COMMIT;
END	
GO
--=========================================