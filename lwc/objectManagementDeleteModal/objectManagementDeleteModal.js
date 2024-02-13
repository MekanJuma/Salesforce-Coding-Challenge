import { LightningElement, api } from 'lwc';
import deleteRecord from '@salesforce/apex/ObjectManagementController.deleteRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ObjectManagementDeleteModal extends LightningElement {
    @api record = {};

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleDelete() {
        deleteRecord({ objectName: this.record.objectName, recordId: this.record.recordId })
            .then(() => {
                this.showToast('Success', 'The record has been successfully deleted.', 'success');
                this.dispatchEvent(new CustomEvent('success'));
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}