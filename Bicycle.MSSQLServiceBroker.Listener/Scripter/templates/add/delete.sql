CREATE TRIGGER [%Scheme%].[%Table%_ServiceBrokerListenerForDelete] ON [%Scheme%].[%Table%] FOR DELETE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceNameForDelete]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceNameForDelete'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForDelete]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM deleted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForDelete] (@messageBody);
    COMMIT;
END	
GO
--=========================================