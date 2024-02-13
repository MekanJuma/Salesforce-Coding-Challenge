# Salesforce Coding Challenge: Custom Object Management System

## Business Requirements

Your task is to develop a robust and scalable custom object management system in Salesforce using Apex and Lightning Web Components (LWC). This system should serve as a one-stop solution for creating, updating, and deleting custom objects and their records in a simulated enterprise environment.

### 1. Custom Objects

Create two custom objects, `Project__c` and `Task__c`, with the necessary fields:
- **Project__c**: Name, Description__c, DueDate__c, Status__c
- **Task__c**: Name, Description__c, DueDate__c, Status__c, Project__c (lookup to Project__c)

### 2. Apex Controller

Build an Apex Controller that can perform CRUD (Create, Read, Update, Delete) operations on these custom objects.

### 3. Lightning Web Component

Create an LWC-based UI that allows users to:
- Create a new Project or Task
- View a list of existing Projects and their Tasks
- Update the attributes of an existing Project or Task
- Delete a Project or Task
- Filter the Projects and Tasks by Status

### 4. Error Handling

Implement robust error handling within the Apex Controller to handle common error conditions like field validation, lookup errors, etc.

### 5. Unit Tests

Write Apex Test Classes covering at least 90% of your Apex code.

### 6. Audit Logging

Create an Audit Log object `AuditLog__c` with fields Action__c, Object__c, RecordId__c, and Date__c. Log every CRUD operation made via the Apex Controller into this object.

### 7. Asynchronous Processing

Implement a scheduled Apex class that changes the Status of Projects and Tasks whose `DueDate__c` is passed to “Overdue”.

## Expected Outcomes

### Apex Controller

- Should be able to create, read, update, and delete `Project__c` and `Task__c` records.
- Should implement error handling and return appropriate error messages.

### LWC Component

- The UI should be user-friendly and intuitive.
- Should support all CRUD operations outlined in the business requirements.
- Should be able to filter Projects and Tasks by Status.

### Unit Tests

- Should cover at least 90% of your Apex classes and triggers.
- Should test all success and failure scenarios including edge cases.

### Audit Logging

- Every CRUD operation should generate a new `AuditLog__c` record with appropriate values.

### Asynchronous Processing

- The Scheduled Apex class should successfully update the Status of overdue Projects and Tasks.

## Testing

1. Manually test the Lightning Web Component to make sure it fulfills all requirements.
2. Run your Apex Test Classes and confirm you meet the coverage requirements.

Good luck, and may the Salesforce be with you!
