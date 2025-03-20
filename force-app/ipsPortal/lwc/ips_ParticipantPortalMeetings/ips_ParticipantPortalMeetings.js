import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import USER_ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import getParticipantsMeetings from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantCompletedMeetings';
import getUserWorkTrailId from '@salesforce/apex/IPS_ParticipantPortalTrailController.getTrail';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_ParticipantPortalMeetings extends LightningElement {
    homeImg = IPS_HOME_LOGOS + '/House.svg';
    warningIcon = IPS_HOME_LOGOS + '/ExclamationmarkTriangle.svg';
    currentUser = Id;
    @track meetingRecords;
    @track record;
    recordIds;
    isMeeting = false;
    numPops = 2;
    error;

    breadcrumbs = [
        {
            label: 'Mitt jobbspor',
            href: ''
        },
        {
            label: 'mine møter',
            href: ''
        }
    ];

    @wire(getRecord, {
        recordId: '$currentUser',
        fields: [USER_ACCOUNT_FIELD, USER_CONTACT_FIELD]
    })
    userContactAccount;

    get userAccountId() {
        return getFieldValue(this.userContactAccount.data, USER_ACCOUNT_FIELD);
    }

    get userContactId() {
        return getFieldValue(this.userContactAccount.data, USER_CONTACT_FIELD);
    }

    get warningText(){
        return 'Det er ikke registrert fullførte møter i ditt jobbspor.';
    }

/* Fetch recordId from logged in user */
@wire(getUserWorkTrailId, { recordId: '$userAccountId' })
wiredtrail({ error, data }) {
    if (data) {
        this.record = data[0];
        this.recordIds = this.record?.jobbsporId;
    } else if (error) {
        this.error = error;
    }
}

 /* Get all completed goals for logged in user */
 @wire(getParticipantsMeetings, { recordId: '$recordIds',contactId: '$userContactId' })
 wiredMeetings({ error, data }) {
     if (data) {
         if (data.length > 0) {
             this.meetingRecords = data;
             this.isMeeting = true;
         }
     } else if (error) {
         this.error = error;
     }
 }

 navigateToPage(event) {
     const page = event.target.name;
     this[NavigationMixin.Navigate]({
         type: 'comm__namedPage',
         attributes: {
             name: page
         }
     });
 }



}