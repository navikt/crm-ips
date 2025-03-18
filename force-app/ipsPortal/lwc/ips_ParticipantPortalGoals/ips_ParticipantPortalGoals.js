import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import USER_ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import getParticipantsGoals from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals';
import getUserWorkTrailId from '@salesforce/apex/IPS_ParticipantPortalTrailController.getTrail';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_ParticipantPortalGoals extends NavigationMixin(LightningElement) {

    homeImg = IPS_HOME_LOGOS + '/House.svg';
    warningIcon = IPS_HOME_LOGOS + '/ExclamationmarkTriangle.svg';
    currentUser = Id;
    @track goalRecords;
    @track record;
    recordIds;
    isGoal = false;
    numPops = 2;
    error;

    breadcrumbs = [
        {
            label: 'Mitt jobbspor',
            href: ''
        },
        {
            label: 'mine aktiviteter',
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
            return 'Det er ikke registrert gjennomførte aktiviteter.';
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
    @wire(getParticipantsGoals, { recordId: '$recordIds' })
    wiredGoals({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.goalRecords = data;
                this.isGoal = true;
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