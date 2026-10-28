/** @description Concrete implementation of EinsteinLLMServiceInterface that delegates to ConnectApi.EinsteinLLM static methods. */
public class EinsteinLLMServiceImpl implements EinsteinLLMServiceInterface {
    /** @description {@inheritDoc} */
    @SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidBooleanMethodParameters') // mirrors ConnectApi.EinsteinLLM.getPromptTemplates signature
    public ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation getPromptTemplates(
        String query, String sortBy, Integer offset, Integer pageLimit,
        List<String> fields, String type, String relatedEntity, Boolean isActive
    ) {
        return ConnectApi.EinsteinLLM.getPromptTemplates(query, sortBy, offset, pageLimit, fields, type, relatedEntity, isActive);
    }

    /** @description {@inheritDoc} */
    public ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generateMessagesForPromptTemplate(
        String promptTemplateDeveloperName,
        ConnectApi.EinsteinPromptTemplateGenerationsInput input
    ) {
        return ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplateDeveloperName, input);
    }
}
