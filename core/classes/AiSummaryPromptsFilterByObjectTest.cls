@IsTest
private class AiSummaryPromptsFilterByObjectTest {

    private static final String ENTITY_NAME = 'Account';
    private static final List<Template> TEMPLATES = new List<Template>{
        new Template('Account Summary', 'AccountSummary'),
        new Template('Executive Brief', 'ExecutiveBrief')
    };

    private class Template {
        String label, devName;
        Template(String label, String devName) {
            this.label = label;
            this.devName = devName;
        }
    }

    private class MockEinsteinLLMService implements StubProvider {
        private ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation result;

        MockEinsteinLLMService(ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation result) {
            this.result = result;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getPromptTemplates') return result;
            return null;
        }
    }

    private static ConnectApi.EinsteinPromptRecordRepresentation buildRecord(
        String entityName, Template t
    ) {
        ConnectApi.EinsteinPromptRecordFieldRepresentation entity = new ConnectApi.EinsteinPromptRecordFieldRepresentation();
        entity.value = entityName;

        ConnectApi.EinsteinPromptRecordFieldRepresentation isActive = new ConnectApi.EinsteinPromptRecordFieldRepresentation();
        isActive.value = true;

        ConnectApi.EinsteinPromptRecordFieldRepresentation label = new ConnectApi.EinsteinPromptRecordFieldRepresentation();
        label.value = t.label;

        ConnectApi.EinsteinPromptRecordFieldRepresentation devName = new ConnectApi.EinsteinPromptRecordFieldRepresentation();
        devName.value = t.devName;

        ConnectApi.EinsteinPromptRecordRepresentation record = new ConnectApi.EinsteinPromptRecordRepresentation();
        record.fields = new Map<String, ConnectApi.EinsteinPromptRecordFieldRepresentation>{
            'RelatedEntity' => entity,
            'IsActive'      => isActive,
            'MasterLabel'   => label,
            'DeveloperName' => devName
        };
        return record;
    }

    private static ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation buildMock(
        String entityName, List<Template> templates
    ) {
        List<ConnectApi.EinsteinPromptRecordRepresentation> records = new List<ConnectApi.EinsteinPromptRecordRepresentation>();
        for (Template t : templates) {
            records.add(buildRecord(entityName, t));
        }

        ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation result =
            new ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation();
        result.promptRecords = records;
        result.hasMoreRecords = false;
        return result;
    }

    private static void setMock(ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation mock) {
        AiSummaryPromptsFilterByObject.service = (EinsteinLLMService) Test.createStub(
            EinsteinLLMService.class, new MockEinsteinLLMService(mock)
        );
    }

    private static AiSummaryPromptsFilterByObject buildPicklist(String entityName) {
        VisualEditor.DesignTimePageContext ctx = new VisualEditor.DesignTimePageContext();
        ctx.entityName = entityName;
        return new AiSummaryPromptsFilterByObject(ctx);
    }

    @IsTest
    static void getValues_returnsBothMatchingTemplates() {
        setMock(buildMock(ENTITY_NAME, TEMPLATES));
        AiSummaryPromptsFilterByObject picklist = buildPicklist(ENTITY_NAME);

        Test.startTest();
        VisualEditor.DynamicPickListRows rows = picklist.getValues();
        Test.stopTest();

        Assert.isNotNull(rows);
    }

    @IsTest
    static void getValues_excludesNonMatchingEntity() {
        setMock(buildMock('Contact', TEMPLATES));
        AiSummaryPromptsFilterByObject picklist = buildPicklist(ENTITY_NAME);

        Test.startTest();
        VisualEditor.DynamicPickListRows rows = picklist.getValues();
        Test.stopTest();

        Assert.isNotNull(rows);
    }

    @IsTest
    static void getDefaultValue_returnsFirstMatchingTemplate() {
        setMock(buildMock(ENTITY_NAME, TEMPLATES));
        AiSummaryPromptsFilterByObject picklist = buildPicklist(ENTITY_NAME);

        Test.startTest();
        VisualEditor.DataRow defaultRow = picklist.getDefaultValue();
        Test.stopTest();

        Assert.isNotNull(defaultRow);
        Assert.areEqual(TEMPLATES[0].label, defaultRow.getLabel());
        Assert.areEqual(TEMPLATES[0].devName, (String) defaultRow.getValue());
    }

    @IsTest
    static void getDefaultValue_returnsNull_whenNoMatchingTemplates() {
        ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation empty =
            new ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation();
        empty.promptRecords = new List<ConnectApi.EinsteinPromptRecordRepresentation>();
        empty.hasMoreRecords = false;
        setMock(empty);
        AiSummaryPromptsFilterByObject picklist = buildPicklist(ENTITY_NAME);

        Test.startTest();
        VisualEditor.DataRow defaultRow = picklist.getDefaultValue();
        Test.stopTest();

        Assert.isNull(defaultRow);
    }

    @IsTest
    static void memoization_bothMethodsOnSameInstance() {
        setMock(buildMock(ENTITY_NAME, TEMPLATES));
        AiSummaryPromptsFilterByObject picklist = buildPicklist(ENTITY_NAME);

        Test.startTest();
        VisualEditor.DataRow defaultRow = picklist.getDefaultValue();
        VisualEditor.DynamicPickListRows rows = picklist.getValues();
        Test.stopTest();

        Assert.isNotNull(defaultRow);
        Assert.isNotNull(rows);
    }
}
