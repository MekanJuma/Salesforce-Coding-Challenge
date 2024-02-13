public class OverdueStatusUpdater implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    private String objectType;

    public OverdueStatusUpdater() {
        this.objectType = 'Task__c';
    }

    private OverdueStatusUpdater(String objectType) {
        this.objectType = objectType;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (objectType.equals('Task__c')) {
            return Database.getQueryLocator([
                SELECT Id FROM Task__c WHERE DueDate__c < TODAY AND Status__c != 'Overdue'
            ]);
        } else if (objectType.equals('Project__c')) {
            return Database.getQueryLocator([
                SELECT Id FROM Project__c WHERE DueDate__c < TODAY AND Status__c != 'Overdue'
            ]);
        }
        return null;
    }

    public void execute(Database.BatchableContext BC, List<SObject> records) {
        for (SObject record : records) {
            record.put('Status__c', 'Overdue');
        }
        update records;
    }

    public void finish(Database.BatchableContext BC) {
        if (objectType.equals('Task__c')) {
            Database.executeBatch(new OverdueStatusUpdater('Project__c'), 200);
        }
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(this, 200);
    }

    public static String scheduleJob() {
        String cronExpr = '0 0 23 * * ?'; // Every night at 11 PM
        return System.schedule('Overdue Status Update', cronExpr, new OverdueStatusUpdater());
    }
}
