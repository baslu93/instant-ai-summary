public class UserFactory {

    private static final String MINIMUM_ACCESS_PROFILE = 'Minimum Access - Salesforce';
    private static final String PERMISSION_SET_NAME = 'InstantAiSummaryUser';
    private static final String EINSTEIN_PROMPT_TEMPLATES_PSL = 'EinsteinGPTPromptTemplatesPsl';

    /** @description Creates a test user with Minimum Access profile, Einstein Prompt Templates licence and InstantAiSummaryUser permission set. */
    public static User create() {
        Profile p = [
            SELECT Id FROM Profile
            WHERE Name = :MINIMUM_ACCESS_PROFILE
            WITH USER_MODE
            LIMIT 1
        ];

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'instant.ai.summary.test@example.com',
            Username = 'instant.ai.summary.test.' + System.currentTimeMillis() + '@example.com',
            Alias = 'iasuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        PermissionSetLicense psl = [
            SELECT Id FROM PermissionSetLicense
            WHERE DeveloperName = :EINSTEIN_PROMPT_TEMPLATES_PSL
            WITH USER_MODE
            LIMIT 1
        ];
        insert new PermissionSetLicenseAssign(AssigneeId = u.Id, PermissionSetLicenseId = psl.Id);

        PermissionSet ps = [
            SELECT Id FROM PermissionSet
            WHERE Name = :PERMISSION_SET_NAME
            WITH USER_MODE
            LIMIT 1
        ];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        return u;
    }

    /** @description Retrieves the test user created by the create method. */
    public static User getMinAccessInstantAiSummaryUser() {
        return [
            SELECT Id FROM User
            WHERE Alias = 'iasuser'
            WITH USER_MODE
            LIMIT 1
        ];
    }
}
