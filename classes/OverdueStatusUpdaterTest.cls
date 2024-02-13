@IsTest
private class OverdueStatusUpdaterTest {

    @TestSetup
    static void setupTestData() {
        Project__c project = new Project__c(Name='Test Project', Status__c='New', DueDate__c=Date.today().addDays(-1));
        insert project;

        Task__c task = new Task__c(Name='Test Task', Status__c='New', DueDate__c=Date.today().addDays(-1), Project__c=project.Id);
        insert task;
    }

    @IsTest
    static void testBatchExecutionForTasks() {
        Test.startTest();
        Database.executeBatch(new OverdueStatusUpdater(), 1);
        Test.stopTest();

        Task__c updatedTask = [SELECT Status__c FROM Task__c LIMIT 1];
        System.assertEquals('Overdue', updatedTask.Status__c, 'The task status should be updated to Overdue.');

        Project__c updatedProject = [SELECT Status__c FROM Project__c LIMIT 1];
        System.assertEquals('Overdue', updatedProject.Status__c, 'The project status should be updated to Overdue.');
    }

    @IsTest
    static void testScheduling() {
        String jobId = OverdueStatusUpdater.scheduleJob();
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];

        System.assertNotEquals(null, ct, 'The job should be scheduled.');
        System.assertEquals('0 0 23 * * ?', ct.CronExpression, 'The cron expression should match the expected schedule.');
    }

    @IsTest
    static void testBatchExecutionWithFutureDueDate() {
        Project__c futureProject = new Project__c(Name='Future Project', Status__c='New', DueDate__c=Date.today().addDays(5));
        insert futureProject;

        Task__c futureTask = new Task__c(Name='Future Task', Status__c='New', DueDate__c=Date.today().addDays(5), Project__c=futureProject.Id);
        insert futureTask;

        Test.startTest();
        Database.executeBatch(new OverdueStatusUpdater(), 1);
        Test.stopTest();

        Project__c queriedProject = [SELECT Status__c FROM Project__c WHERE Id = :futureProject.Id];
        Task__c queriedTask = [SELECT Status__c FROM Task__c WHERE Id = :futureTask.Id];

        System.assertNotEquals('Overdue', queriedProject.Status__c, 'Future-dated project should not be marked as Overdue.');
        System.assertNotEquals('Overdue', queriedTask.Status__c, 'Future-dated task should not be marked as Overdue.');
    }
}
