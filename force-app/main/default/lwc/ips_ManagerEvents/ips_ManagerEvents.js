import { LightningElement ,api, wire, track} from 'lwc';
import getEventList from '@salesforce/apex/ips_ManagerEventController.getEventsForCurrentWeek';

export default class Ips_ManagerEvents extends LightningElement {

    @track columns = [
        { label: 'Medarbeider', fieldName: 'employeeName', type: 'text', sortable: true },
        { label: 'Tid', fieldName: 'startTime', type: 'text'},
        { label: 'Emne', fieldName: 'subject', type: 'text' },
        { label: 'Sted', fieldName: 'location', type: 'text'},
        { label: 'Deltaker', fieldName: 'participantName', type: 'text', sortable: true },
        { label: 'Fødselsnr', fieldName: 'participantIdent', type: 'text' },
        { label: 'Hjemmeadresse', fieldName: 'participantAddress', type: 'text' },
    ];

    @track error;
    @track eventList ;
    @wire(getEventList)
    wiredAEvents({
        error,
        data
    }) {
        if (data) {
            this.eventList = data;
        } else if (error) {
            this.error = error;
            console.log(error);
        }
    }
}