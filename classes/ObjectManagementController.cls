public with sharing class ObjectManagementController {
    @AuraEnabled(cacheable=false)
    public static SObject getRecordById(String objectName, String recordId) {
        String isTask = objectName == 'Task__c' ? ', Project__c' : '';
        String fields = 'Id, Name, Description__c, DueDate__c, Status__c' + isTask;
        String query = 'SELECT ' + fields + ' FROM ' + objectName + ' WHERE Id = :recordId';
        
        SObject result = Database.query(query);
        return result;
    }

    @AuraEnabled
    public static Id createRecord(String objectTypeName, Map<String, Object> fields) {
        SObject newRecord = (SObject)Type.forName('Schema.' + objectTypeName).newInstance();
        Map<String, Schema.SObjectField> objectFields = newRecord.getSObjectType().getDescribe().fields.getMap();

        for (String fieldName : fields.keySet()) {
            Object fieldValue = fields.get(fieldName);
            
            if (objectFields.containsKey(fieldName) && fieldValue instanceof String) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fieldName).getDescribe();
                if (fieldDescribe.getType() == Schema.DisplayType.Date) {
                    fieldValue = Date.valueOf((String)fieldValue);
                }
            }
            
            newRecord.put(fieldName, fieldValue);
        }
        
        try {
            insert newRecord;

            addAuditLogEntry('Create', objectTypeName, newRecord.Id);
            return newRecord.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating new record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id updateProjectRecord(Project__c recordToUpdate) {
        try {
            update recordToUpdate;

            addAuditLogEntry('Update', 'Project__c', recordToUpdate.Id);
            return recordToUpdate.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id updateTaskRecord(Task__c recordToUpdate) {
        try {
            update recordToUpdate;

            addAuditLogEntry('Update', 'Task__c', recordToUpdate.Id);
            return recordToUpdate.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteRecord(String objectName, Id recordId) {
        try {
            SObject recordToDelete = ((SObject)Type.forName('Schema.' + objectName).newInstance()).clone(false);
            recordToDelete.Id = recordId;
            delete recordToDelete;

            addAuditLogEntry('Delete', objectName, recordId);
            return 'The record has been successfully deleted.';
        } catch (Exception e) {
            throw new AuraHandledException('Deletion failed: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PicklistOption> getStatusOptions() {
        return getStatusOptions('Project__c');
    }

    public static List<PicklistOption> getStatusOptions(String objectApiName) {
        List<PicklistOption> options = new List<PicklistOption>();

        Schema.DescribeFieldResult fieldResult; 

        if (objectApiName == 'Project__c') {
            fieldResult = Schema.Project__c.Status__c.getDescribe();
        } else if (objectApiName == 'Task__c') {  
            fieldResult = Schema.Task__c.Status__c.getDescribe();
        } else {
            throw new AuraHandledException('Invalid object API name provided.');
        }

        Integer key = 0;
        for (Schema.PicklistEntry pe : fieldResult.getPicklistValues()) {
            options.add(new PicklistOption(key, pe.getLabel(), pe.getValue()));
            key++;
        }

        return options;
    }

    @AuraEnabled(cacheable=false)
    public static List<ProjectWrapper> getProjectsAndTasks(List<String> filteredStatus) {
        Map<Id, ProjectWrapper> projectMap = new Map<Id, ProjectWrapper>();

        String taskQuery = 'SELECT Id, Name, Description__c, DueDate__c, Status__c, Project__c, ' +
                            'Project__r.Id, Project__r.Name, Project__r.Status__c, Project__r.Description__c, Project__r.DueDate__c ' +
                            'FROM Task__c';
        if (!filteredStatus.isEmpty()) {
            taskQuery += ' WHERE Status__c IN :filteredStatus';
        }
        
        List<Task__c> tasks = Database.query(taskQuery);

        for (Task__c task : tasks) {
            ProjectWrapper wrapper;
            if (projectMap.containsKey(task.Project__c)) {
                wrapper = projectMap.get(task.Project__c);
            } else {
                wrapper = new ProjectWrapper();
                wrapper.project = task.Project__r;
                projectMap.put(task.Project__c, wrapper);
            }
            wrapper.tasks.add(task);
        }

        Set<Id> projectIds = projectMap.keySet();

        String projectQuery = 'SELECT Id, Name, Status__c, Description__c, DueDate__c FROM Project__c';
        if (!filteredStatus.isEmpty()) {
            projectQuery += ' WHERE Status__c IN :filteredStatus AND Id NOT IN :projectIds';
        } else {
            projectQuery += ' WHERE Id NOT IN :projectIds';
        }

        List<Project__c> directlyFilteredProjects = Database.query(projectQuery);

        for (Project__c project : directlyFilteredProjects) {
            ProjectWrapper wrapper = new ProjectWrapper();
            wrapper.project = project;
            projectMap.put(project.Id, wrapper);
        }

        return new List<ProjectWrapper>(projectMap.values());
    }

    private static void addAuditLogEntry(String action, String objectName, Id recordId) {
        AuditLog__c logEntry = new AuditLog__c(
            Action__c = action,
            Object__c = objectName,
            RecordId__c = (String)recordId,
            Date__c = DateTime.now()
        );
        insert logEntry;
    }    

    public class ProjectWrapper {
        @AuraEnabled public Project__c project;
        @AuraEnabled public List<Task__c> tasks;

        public ProjectWrapper() {
            this.tasks = new List<Task__c>();
        }
    }

    public class PicklistOption {
        @AuraEnabled public Integer key {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        
        public PicklistOption(Integer key, String label, String value) {
            this.key = key;
            this.label = label;
            this.value = value;
        }
    }

}