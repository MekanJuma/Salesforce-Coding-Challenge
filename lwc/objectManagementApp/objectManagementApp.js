import { LightningElement, track } from 'lwc';

export default class ObjectManagementApp extends LightningElement {
    @track records = [];

    isEdit = false;
    isDelete = false;
    isNew = false;

    record = {};

    handleEditRecord(event) {
        this.isEdit = true;
        this.record = event.detail;
    }

    handleDeleteRecord(event) {
        this.isDelete = true;
        this.record = event.detail;
    }

    handleNewModal() {
        this.isNew = true;
    }

    handleModalClose() {
        this.isEdit = false;
        this.isDelete = false;
        this.isNew = false;
    }

    handleSuccess() {
        this.handleModalClose();
        this.template.querySelector('c-object-management-data-table').reloadData({filteredStatus: []});
    }

    handleFilterChange(event) {
        this.filteredStatus = event.detail;
        this.template.querySelector('c-object-management-data-table').reloadData({filteredStatus: event.detail});
    }
}