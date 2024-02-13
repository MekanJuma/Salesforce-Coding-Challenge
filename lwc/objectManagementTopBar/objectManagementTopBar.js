import { LightningElement, track } from 'lwc';
import getStatusOptions from '@salesforce/apex/ObjectManagementController.getStatusOptions';


export default class ObjectManagementTopBar extends LightningElement {
    @track isLoading = true;
    @track selectedStatuses = [];
    @track statusOptions = [];

    connectedCallback() {
        this.fetchStatusOptions();
    }

    fetchStatusOptions() {
        getStatusOptions()
            .then(result => {
                this.statusOptions = result;
                console.log('statuses', result);
            })
            .catch(error => {
                console.error('Error fetching status options:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleStatusChange(event) {
        this.selectedStatuses = event.detail;
        console.log('st before', JSON.stringify(event.detail));
        const filterChangeEvent = new CustomEvent('statuschange', {
            detail: this.selectedStatuses
        });
        this.dispatchEvent(filterChangeEvent);
    }

    handleNewClick() {
        this.dispatchEvent(new CustomEvent('createrecordmodal'));
    }
}