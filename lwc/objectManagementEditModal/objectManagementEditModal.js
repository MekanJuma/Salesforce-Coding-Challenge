import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordById from '@salesforce/apex/ObjectManagementController.getRecordById';
import getStatusOptions from '@salesforce/apex/ObjectManagementController.getStatusOptions';
import updateProjectRecord from '@salesforce/apex/ObjectManagementController.updateProjectRecord';
import updateTaskRecord from '@salesforce/apex/ObjectManagementController.updateTaskRecord';


export default class ObjectManagementEditModal extends LightningElement {
    @track isLoading = true;
    @track editFormLoading = true;

    @api record = {};

    @track editRecord = {};
    @track error;

    statusOptions = [];

    get isLoaded() {
        if (this.record.objectName == 'Task__c') {
            return !this.isLoading && !this.editFormLoading;
        }
        return !this.isLoading;
    }

    get isTask() {
        return this.record.objectName == 'Task__c';
    }

    connectedCallback() {
        Promise.all([
            getRecordById({ objectName: this.record.objectName, recordId: this.record.recordId }),
            getStatusOptions({ objectApiName: this.record.objectName })
        ])
        .then(([recordResult, statusOptionsResult]) => {
            this.editRecord = recordResult;
            this.statusOptions = statusOptionsResult;
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast(error.body.message);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleChange(event) {
        const field = event.target.name || event.target.fieldName;
        const value = event.target.value;

        console.log(`Field changed: ${field}, Value: ${value}`);
        this.editRecord = { ...this.editRecord, [field]: value };
    }

    handleSave() {
        console.log('record: ', JSON.stringify(this.editRecord));
        if (this.record.objectName == 'Task__c') {
            updateTaskRecord({ recordToUpdate: this.editRecord })
                .then(result => {
                    this.showSuccessToast();
                    this.dispatchEvent(new CustomEvent('success'));
                })
                .catch(error => {
                    this.showErrorToast(error.body.message);
                });
        } else {
            updateProjectRecord({ recordToUpdate: this.editRecord })
                .then(result => {
                    this.showSuccessToast();
                    this.dispatchEvent(new CustomEvent('success'));
                })
                .catch(error => {
                    this.showErrorToast(error.body.message);
                });
        }
        
    }

    closeModal() {
        this.resetFields();
        this.dispatchEvent(new CustomEvent('close'));
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record updated successfully',
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

    handleLoad() {
        this.editFormLoading = false;
    }
    
    resetFields() {
        this.editRecord = {};
    }
}