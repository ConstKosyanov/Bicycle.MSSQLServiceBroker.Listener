CREATE MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeFor%Operation%]
VALIDATION = WELL_FORMED_XML
GO
--=========================================
CREATE CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractFor%Operation%]([%Scheme%_%Table%_ServiceBrokerListenerMessageTypeFor%Operation%] SENT BY INITIATOR)
GO
--=========================================
CREATE QUEUE [%Scheme%_%Table%_ServiceBrokerListenerQueueFor%Operation%]
GO
--=========================================
CREATE SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceFor%Operation%]
ON QUEUE [%Scheme%_%Table%_ServiceBrokerListenerQueueFor%Operation%]([%Scheme%_%Table%_ServiceBrokerListenerContractFor%Operation%])
GO
--=========================================