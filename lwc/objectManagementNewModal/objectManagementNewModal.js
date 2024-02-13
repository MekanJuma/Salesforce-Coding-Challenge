import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStatusOptions from '@salesforce/apex/ObjectManagementController.getStatusOptions';
import createRecord from '@salesforce/apex/ObjectManagementController.createRecord';


export default class ObjectManagementNewModal extends LightningElement {
    @track isLoading = true;
    @track lookupLoading = true;

    @track selectedRecordType = 'Task';
    @track isTaskSelected = true;
    @track newRecord = {
        Status__c: 'New'
    };
    @track statusOptions = [];

    recordTypeOptions = [
        { label: 'Project', value: 'Project' },
        { label: 'Task', value: 'Task' }
    ];

    get isLoaded() {
        if (this.selectedRecordType == 'Task') {
            return !this.isLoading && !this.lookupLoading;
        }
        return !this.isLoading;
    }

    handleLoad() {
        this.lookupLoading = false;
    }

    connectedCallback() {
        this.fetchStatusOptions();
    }

    fetchStatusOptions() {
        getStatusOptions()
            .then(result => {
                this.statusOptions = result;
            })
            .catch(error => {
                console.error('Error fetching status options:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
        this.isTaskSelected = this.selectedRecordType === 'Task';
    }

    handleChange(event) {
        const field = event.target.name || event.target.fieldName;
        const value = event.target.value;

        // console.log(`Field changed: ${field}, Value: ${value}`);
        this.newRecord = { ...this.newRecord, [field]: value };
    }

    handleSave() {
        console.log('newRecord', JSON.stringify(this.newRecord));
        const objectTypeName = this.selectedRecordType === 'Task' ? 'Task__c' : 'Project__c';
        createRecord({ objectTypeName: objectTypeName, fields: this.newRecord })
            .then(result => {
                console.log('Record created with Id: ', result);
                this.showSuccessToast();
                this.dispatchEvent(new CustomEvent('success'));
            })
            .catch(error => {
                console.error('Error creating record: ', error);
                this.showErrorToast('Error creating record!');
            });
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record created successfully',
                variant: 'success'
            })
        );
    }

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}