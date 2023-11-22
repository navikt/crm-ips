import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import getManagerUsers from '@salesforce/apex/IPS_ManagerEventController.getManagerUsers';
import getEventList from '@salesforce/apex/ips_ManagerEventController.getEventsForCurrentWeek';
import UserNameFIELD from '@salesforce/schema/User.Name';

export default class Ips_ManagerEvents extends LightningElement {
    @track columnsPart = [
        { label: 'Jobbspesialist', fieldName: 'employeeName', type: 'text' },
        { label: 'Tid', fieldName: 'startTime', type: 'text' },
        { label: 'Emne', fieldName: 'subject', type: 'text' },
        { label: 'Sted', fieldName: 'location', type: 'text' },
        { label: 'Deltaker', fieldName: 'participantName', type: 'text' },
        { label: 'Fødselsnr', fieldName: 'participantIdent', type: 'text' },
        { label: 'Arbeidsgiver', fieldName: 'accountName', type: 'text' },
        { label: 'Kontaktperson', fieldName: 'accountContactName', type: 'text' },
        { label: 'Type', fieldName: 'meetingCategory', type: 'text' }
    ];

    @track columnsEmpl = [
        { label: 'Jobbspesialist', fieldName: 'employeeName', type: 'text' },
        { label: 'Tid', fieldName: 'startTime', type: 'text' },
        { label: 'Emne', fieldName: 'subject', type: 'text' },
        { label: 'Sted', fieldName: 'location', type: 'text' },
        { label: 'Arbeidsgiver', fieldName: 'accountName', type: 'text' },
        { label: 'Kontaktperson', fieldName: 'accountContactName', type: 'text' }
    ];

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track error;
    @track eventList;
    @track currentUserName;

    @track userOptions = [];
    @track value = '- Alle -';
    @track optionsLoaded = false;
    @track initialRecords;
    @track initialPartMeeting;
    @track initialEmplMeeting;
    @track emplMeeting;
    @track data;
    @track partMeeting;
    @track partData;

    connectedCallback() {
        getManagerUsers()
            .then((result) => {
                this.userOptions.push({ label: this.value, value: this.value });
                for (let i = 0; i < result.length; i++) {
                    this.userOptions.push({ label: result[i].employeeName, value: result[i].employeeName });
                }
                this.optionsLoaded = true;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    /* Get leaders name */
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }

    /* get all events the next 7 days */
    @wire(getEventList)
    wiredAEvents({ error, data }) {
        this.data = data;
        this.initialRecords = data;

        if (this.data) {
            let tempEmpl = [];
            let tempPart = [];

            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].isParticipantAttending === true) {
                    tempPart.push(this.data[i]);
                } else {
                    tempEmpl.push(this.data[i]);
                }
            }
            this.emplMeeting = tempEmpl;
            this.initialEmplMeeting = tempEmpl;
            this.partMeeting = tempPart;
            this.initialPartMeeting = tempPart;
        } else if (error) {
            this.error = error;
        }
    }

    handleUserChange(event) {
        console.log(event.detail.value);
        this.value = event.detail.value;
        const searchKey = event.target.value;
        if (searchKey !== '- Alle -') {
            this.emplMeeting = this.initialEmplMeeting;
            this.partMeeting = this.initialPartMeeting;
            this.data = this.initialRecords;

            if (this.data) {
                let searchRecords = [];
                for (let record of this.data) {
                    let valuesArray = Object.values(record);

                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);

                        if (strVal) {
                            if (strVal.includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.data = searchRecords;

                if (this.data) {
                    let tempEmpl = [];
                    let tempPart = [];

                    for (let i = 0; i < this.data.length; i++) {
                        if (this.data[i].isParticipantAttending === true) {
                            tempPart.push(this.data[i]);
                        } else {
                            tempEmpl.push(this.data[i]);
                        }
                    }
                    this.emplMeeting = tempEmpl;
                    this.partMeeting = tempPart;
                }
            }
        } else {
            this.data = this.initialRecords;
            let tempEmpl = [];
            let tempPart = [];

            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].isParticipantAttending === true) {
                    tempPart.push(this.data[i]);
                } else {
                    tempEmpl.push(this.data[i]);
                }
            }
            this.emplMeeting = tempEmpl;
            this.partMeeting = tempPart;
        }
    }
}
