@IsTest
private class ObjectManagementControllerTest {

    @TestSetup
    static void setupTestData() {
        List<Project__c> projects = new List<Project__c>{
            new Project__c(Name='Test Project 1', Description__c='Description 1', DueDate__c=Date.today(), Status__c='New'),
            new Project__c(Name='Test Project 2', Description__c='Description 2', DueDate__c=Date.today(), Status__c='Completed')
        };
        insert projects;

        List<Task__c> tasks = new List<Task__c>{
            new Task__c(Name='Task 1', Description__c='Task Description 1', DueDate__c=Date.today(), Status__c='New', Project__c=projects[0].Id),
            new Task__c(Name='Task 2', Description__c='Task Description 2', DueDate__c=Date.today().addDays(1), Status__c='In Progress', Project__c=projects[1].Id)
        };
        insert tasks;
    }
    
    @IsTest
    static void testGetRecordByIdProject() {
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        SObject result = ObjectManagementController.getRecordById('Project__c', String.valueOf(testProject.Id));
        System.assertNotEquals(null, result, 'The result should not be null.');
        Project__c projectResult = (Project__c)result;
        System.assertEquals(testProject.Id, projectResult.Id, 'The IDs should match.');
    }

    @IsTest
    static void testCreateRecord() {
        Map<String, Object> fields = new Map<String, Object>{
            'Name' => 'New Project',
            'Description__c' => 'New Project Description',
            'DueDate__c' => String.valueOf(Date.today()),
            'Status__c' => 'New'
        };
        Id recordId = ObjectManagementController.createRecord('Project__c', fields);
        Project__c createdProject = [SELECT Name, Description__c, DueDate__c, Status__c FROM Project__c WHERE Id = :recordId];
        System.assertEquals('New Project', createdProject.Name);
        List<AuditLog__c> auditLogs = [SELECT Id FROM AuditLog__c WHERE RecordId__c = :String.valueOf(recordId)];
        System.assertEquals(1, auditLogs.size());
    }

    @IsTest
    static void testUpdateProjectRecord() {
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        testProject.Name = 'Updated Project Name';
        ObjectManagementController.updateProjectRecord(testProject);
        Project__c updatedProject = [SELECT Name FROM Project__c WHERE Id = :testProject.Id];
        System.assertEquals('Updated Project Name', updatedProject.Name);
    }

    @IsTest
    static void testUpdateTaskRecord() {
        Task__c testTask = [SELECT Id FROM Task__c LIMIT 1];
        testTask.Name = 'Updated Task Name';
        ObjectManagementController.updateTaskRecord(testTask);
        Task__c updatedTask = [SELECT Name FROM Task__c WHERE Id = :testTask.Id];
        System.assertEquals('Updated Task Name', updatedTask.Name);
    }

    @IsTest
    static void testDeleteRecord() {
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        ObjectManagementController.deleteRecord('Project__c', testProject.Id);
        List<Project__c> projectsAfterDeletion = [SELECT Id FROM Project__c WHERE Id = :testProject.Id];
        System.assertEquals(0, projectsAfterDeletion.size());
    }

    @IsTest
    static void testGetProjectsAndTasksWithFilter() {
        List<String> statusFilter = new List<String>{'New'};
        List<ObjectManagementController.ProjectWrapper> wrappers = ObjectManagementController.getProjectsAndTasks(statusFilter);
        System.assertNotEquals(0, wrappers.size());
        for (ObjectManagementController.ProjectWrapper wrapper : wrappers) {
            System.assertEquals('New', wrapper.project.Status__c);
        }
    }

    @IsTest
    static void testGetProjectsAndTasksWithoutFilter() {
        List<ObjectManagementController.ProjectWrapper> wrappers = ObjectManagementController.getProjectsAndTasks(new List<String>{});
        System.assertNotEquals(0, wrappers.size());
    }
    
    @IsTest
    static void testGetStatusOptionsProject() {
        List<ObjectManagementController.PicklistOption> options = ObjectManagementController.getStatusOptions('Project__c');
        System.assertNotEquals(0, options.size(), 'There should be at least one status option for Project__c.');
        Boolean statusFound = false;
        for (ObjectManagementController.PicklistOption option : options) {
            if (option.value == 'New') {
                statusFound = true;
                break;
            }
        }
        System.assert(statusFound, 'Expected status value not found in options.');
    }
}