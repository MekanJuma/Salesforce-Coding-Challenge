# Salesforce Custom Object Management System
## Overview
This repository contains the Salesforce Custom Object Management System, a robust and scalable solution designed to streamline the management of custom objects within a simulated enterprise environment on the Salesforce platform. The system facilitates the creation, updating, and deletion of custom objects and their records, providing a user-friendly interface built with Lightning Web Components (LWC).

## Features
- **Custom Object Management:** Manage custom objects Project__c and Task__c with fields such as Name, Description, Due Date, and Status.
- **Dynamic Data Interaction:** Perform Create, Read, Update, and Delete (CRUD) operations directly from a rich user interface.
- **Status Filtering:** Filter projects and tasks by their status using a custom-built multi-select picklist.
- **Audit Logging:** Every CRUD operation is logged into the AuditLog__c object, providing an audit trail for system interactions.
- **Scheduled Updates:** An Apex Scheduled Class automatically updates the status of projects and tasks based on their due dates.

## Technologies Used
- **Salesforce Lightning Web Components (LWC):** For building a dynamic and responsive user interface.
- **Apex:** Salesforce's strongly typed, object-oriented programming language used for the backend logic.
- **SOQL:** Salesforce Object Query Language used for data retrieval.
- **Scheduled Apex:** For executing scheduled tasks that update record statuses based on business logic.

## Getting Started
### Prerequisites
- Salesforce Developer Edition Org or a Sandbox environment.
- Salesforce CLI for deploying the components to your org.
- Access to Salesforce Lightning Experience.

## Installation
### Clone the Repository
```bash
git clone https://github.com/MekanJuma/Salesforce-Coding-Challenge.git
cd Salesforce-Coding-Challenge
```

### Deploy to Salesforce
Use Salesforce CLI to deploy the project to your Salesforce org:
```bash
sfdx force:source:deploy -p force-app -u YourOrgAlias
```
Replace YourOrgAlias with your Salesforce org alias.

### Schedule the Batch Job
After deploying, schedule the OverdueStatusUpdater batch class to run automatically:

```apex
OverdueStatusUpdater.scheduleJob();
```
You can execute this code snippet via Anonymous Apex in the Developer Console or through the Salesforce CLI.

## Usage
- Navigate to the **Object Management App** tab in your Salesforce org to access the custom object management system.
- Use the New button in the top bar to create new projects or tasks.
- Filter existing records by status using the multi-select picklist in the top bar.
- Perform edit or delete operations directly from the Object Management Data Table.

### Author: Mekan Jumayev
