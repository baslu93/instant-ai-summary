/**
 * @description Picklist Data Source for LWC containing the active Record Summary Prompt Templates for the Object of the Context Record Page.
 */
public class AiSummaryPromptsFilterByObject extends VisualEditor.DynamicPicklist {
    private static final String PROMPT_TEMPLATE_TYPE = 'einstein_gpt__recordSummary';
    private static final String RELATED_ENTITY_FIELD = 'RelatedEntity';
    private static final String IS_ACTIVE_FIELD = 'IsActive';
    private static final String MASTER_LABEL_FIELD = 'MasterLabel';
    private static final String DEVELOPER_NAME_FIELD = 'DeveloperName';

    @TestVisible
    private static EinsteinLLMServiceInterface service = new EinsteinLLMServiceImpl();

    private VisualEditor.DesignTimePageContext context;
    private List<Option> memoizedOptions;

    /**
     * @description Constructor.
     * @param context The design-time page context containing the entity name.
     */
    public AiSummaryPromptsFilterByObject(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    private List<Option> options() {
        if (memoizedOptions == null) {
            memoizedOptions = getPromptTemplates(context?.entityName);
        }
        return memoizedOptions;
    }

    public override VisualEditor.DataRow getDefaultValue() {
        List<Option> opts = options();
        return opts.isEmpty() ? null : new VisualEditor.DataRow(opts[0].label, opts[0].value);
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();
        for (Option opt : options()) {
            rows.addRow(new VisualEditor.DataRow(opt.label, opt.value));
        }
        return rows;
    }

    /**
     * @description Retrieves active Record Summary Prompt Templates matching the given object API name.
     * @param inputObjectApiName The API name of the object to filter templates by.
     * @return List of Options containing the label and developer name of each matching template.
     */
    public static List<Option> getPromptTemplates(String inputObjectApiName) {
        List<Option> results = new List<Option>();
        Integer page = 0;
        Boolean hasMoreRecords = true;
        do {
            ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation result =
                service.getPromptTemplates(null, null, page, 50, new List<String>{RELATED_ENTITY_FIELD}, PROMPT_TEMPLATE_TYPE, null, true);

            hasMoreRecords = result?.hasMoreRecords == true;
            if(result?.promptRecords == null) {
                break;
            }
            for (ConnectApi.EinsteinPromptRecordRepresentation record : result.promptRecords) {
                String objectApiName = (String) record.fields?.get(RELATED_ENTITY_FIELD)?.value;
                Boolean isActive = (Boolean) record.fields?.get(IS_ACTIVE_FIELD)?.value;
                if (objectApiName != null && objectApiName.equalsIgnoreCase(inputObjectApiName) && isActive == true) {
                    String label = (String) record.fields?.get(MASTER_LABEL_FIELD)?.value;
                    String devName = (String) record.fields?.get(DEVELOPER_NAME_FIELD)?.value;
                    results.add(new Option(label, devName));
                }
            }
            page++;
        } while (hasMoreRecords);
        return results;
    }

    /** @description Represents the picklist entry structure. */
    public class Option {
        public final String label;
        public final String value;

        /**
         * @description Constructor.
         * @param label The display label of the picklist entry.
         * @param value The developer name value of the picklist entry.
         */
        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
