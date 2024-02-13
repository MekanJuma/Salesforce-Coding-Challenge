import { LightningElement, api, track, wire } from 'lwc';
import getProjectsAndTasks from '@salesforce/apex/ObjectManagementController.getProjectsAndTasks';


export default class ObjectManagementDataTable extends LightningElement {
    @track error;
    @track isLoading = true;

    @track filteredStatus = [];
    @track projectsWithTasks = [];

    @api
    reloadData(data) {
        console.log('Reloading data...', JSON.stringify(data));
        this.filteredStatus = data.filteredStatus || [];
        this.isLoading = true;
        this.fetchProjectsAndTasks();
    }

    connectedCallback() {
        this.fetchProjectsAndTasks();
    }

    fetchProjectsAndTasks() {
        const statusValues = this.filteredStatus.length > 0 ? this.filteredStatus.map(status => status.value) : [];
        console.log('statusValues', JSON.stringify(statusValues));
        getProjectsAndTasks({ filteredStatus: statusValues })
            .then(result => {
                console.log('result', result);
                this.projectsWithTasks = result.map(projectWrapper => {
                    let project = projectWrapper.project || { isVisible: false };
                    
                    let isVisible = true;
                    if (statusValues.length > 0) {
                        isVisible = statusValues.includes(projectWrapper.project.Status__c);
                    }
                    if (project.Id == null) {
                        isVisible = false;
                    }

                    return {
                        ...project,
                        isExpanded: statusValues.length > 0 || project.isVisible == false ? true : false,
                        iconName: statusValues.length > 0 ? 'utility:chevrondown' : 'utility:chevronright',
                        statusStyle: this.getStatusStyle(project.Status__c),
                        isVisible: isVisible,
                        hasTasks: projectWrapper.tasks.length > 0,
                        _children: projectWrapper.tasks.map(task => ({
                            ...task,
                            statusStyle: this.getStatusStyle(task.Status__c),
                            isVisible: isVisible || (statusValues.length > 0 && statusValues.includes(task.Status__c))
                        }))
                    };
                });
        })
        .catch(error => {
            console.error('Error fetching projects and tasks:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    toggleExpand(event) {
        const projectId = event.currentTarget.dataset.id;
        const projectIndex = this.projectsWithTasks.findIndex(project => project.Id === projectId);
        if (projectIndex !== -1) {
            this.projectsWithTasks[projectIndex].isExpanded = !this.projectsWithTasks[projectIndex].isExpanded;
            
            this.projectsWithTasks[projectIndex].iconName = this.projectsWithTasks[projectIndex].isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
            
            this.projectsWithTasks = [...this.projectsWithTasks];
        }
    }

    getStatusStyle(status) {
        switch(status) {
            case 'New':
                return 'slds-truncate status-pill status-new';
            case 'In Progress':
                return 'slds-truncate status-pill status-in-progress';
            case 'Completed':
                return 'slds-truncate status-pill status-completed';
            case 'Overdue':
                return 'slds-truncate status-pill status-overdue';
            case 'Canceled':
                return 'slds-truncate status-pill status-canceled';
            default:
                return 'slds-truncate';
        }
    }
    
    handleMenuAction(event) {
        const actionName = event.detail.value;
        const recordId = event.target.dataset.recordId;
        const recordName = event.target.dataset.recordName;
        const objectName = event.target.dataset.objectName;
        const objectLabel = event.target.dataset.objectLabel;

        this.dispatchEvent(new CustomEvent(actionName, {
            detail: { recordId, recordName, objectName, objectLabel }
        }));
    }

}