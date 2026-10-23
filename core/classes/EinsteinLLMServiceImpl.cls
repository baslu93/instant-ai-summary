public class EinsteinLLMServiceImpl implements EinsteinLLMService {
    public ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation getPromptTemplates(
        String networkId, String language, Integer page, Integer pageSize,
        List<String> additionalFields, String promptTemplateType, String status, Boolean requireActive
    ) {
        return ConnectApi.EinsteinLLM.getPromptTemplates(networkId, language, page, pageSize, additionalFields, promptTemplateType, status, requireActive);
    }

    public ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generateMessagesForPromptTemplate(
        String promptTemplateDeveloperName,
        ConnectApi.EinsteinPromptTemplateGenerationsInput input
    ) {
        return ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplateDeveloperName, input);
    }
}
