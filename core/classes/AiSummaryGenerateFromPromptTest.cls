@IsTest
private class AiSummaryGenerateFromPromptTest {

    private static final String TEMPLATE_DEV_NAME = 'AccountSummary';
    private static final Id RECORD_ID = '001000000000001AAA';
    private static final String GENERATED_TEXT = 'This is an AI-generated summary.';

    @TestSetup
    static void setup() {
        UserFactory.create();
    }

    /** @description Stub that always throws a CalloutException to simulate an LLM service failure. */
    private class ThrowingEinsteinLLMService implements StubProvider {
        @SuppressWarnings('PMD.ExcessiveParameterList') // signature mandated by StubProvider interface
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            throw new CalloutException('Service unavailable');
        }
    }

    /** @description Stub that returns a pre-configured LLM response to simulate a successful service call. */
    private class MockEinsteinLLMService implements StubProvider {
        private ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result;

        MockEinsteinLLMService(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result) {
            this.result = result;
        }

        @SuppressWarnings('PMD.ExcessiveParameterList') // signature mandated by StubProvider interface
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'generateMessagesForPromptTemplate'){
                return result;
            }
            return null;
        }
    }

    private static ConnectApi.EinsteinPromptTemplateGenerationsRepresentation buildMock(String text) {
        ConnectApi.EinsteinLLMGenerationItemOutput generation = new ConnectApi.EinsteinLLMGenerationItemOutput();
        generation.text = text;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result =
            new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        result.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>{ generation };
        return result;
    }

    private static void setMock(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation mock) {
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMServiceInterface) Test.createStub(
            EinsteinLLMServiceInterface.class, new MockEinsteinLLMService(mock)
        );
    }

    @IsTest
    static void shouldGenerateResponse() {
        setMock(buildMock(GENERATED_TEXT));

        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            String result = AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
            Test.stopTest();

            Assert.areEqual(GENERATED_TEXT, result);
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenNoResponseGenerated() {
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation empty =
            new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        empty.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>();
        setMock(empty);

        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('No response generated.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenPromptTemplateIsNotProvided() {
        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate('', RECORD_ID);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Prompt template is required.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenRecordIdIsNotProvided() {
        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, '');
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Record ID is required.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenServiceThrows() {
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMServiceInterface) Test.createStub(
            EinsteinLLMServiceInterface.class, new ThrowingEinsteinLLMService()
        );

        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Service unavailable', e.getMessage());
            }
            Test.stopTest();
        }
    }
}
