/**
 * @description Aura-enabled service that generates a Record Summary from a Prompt Template.
 */
public with sharing class AiSummaryGenerateFromPrompt {

    @TestVisible
    private static EinsteinLLMServiceInterface service = new EinsteinLLMServiceImpl();

    /**
     * @description Calls the Einstein LLM to generate a summary for the given record using the specified Prompt Template.
     * @param promptTemplateDeveloperName The developer name of the Prompt Template to use.
     * @param recordId The ID of the record to summarize.
     * @return The generated summary text.
     */
    @AuraEnabled
    public static String generate(String promptTemplateDeveloperName, String recordId) {
        validate(promptTemplateDeveloperName, recordId);

        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.isPreview = false;

        Schema.SObjectType sObjectType = ((Id) recordId).getSObjectType();
        @SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult') // object type is resolved dynamically from the recordId at runtime
        String objectName = sObjectType.getDescribe(Schema.SObjectDescribeOptions.DEFERRED).getName();

        ConnectApi.WrappedValue recordValue = new ConnectApi.WrappedValue();
        recordValue.value = new Map<String, Object>{ 'id' => recordId };

        input.inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:' + objectName => recordValue
        };

        input.additionalConfig = new ConnectApi.EinsteinLLMAdditionalConfigInput();
        input.additionalConfig.numGenerations = 1;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result;
        try {
            result = service.generateMessagesForPromptTemplate(promptTemplateDeveloperName, input);
        } catch (Exception e) {
            throw handledException(e.getMessage());
        }
        if (result?.generations == null || result.generations.isEmpty()) {
            throw handledException('No response generated.');
        }
        return result.generations[0]?.text;
    }

    private static void validate(String promptTemplateDeveloperName, String recordId) {
        if (String.isBlank(promptTemplateDeveloperName)) {
            throw handledException('Prompt template is required.');
        }
        if (String.isBlank(recordId)) {
            throw handledException('Record ID is required.');
        }
    }

    private static AuraHandledException handledException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
}
