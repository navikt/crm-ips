import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CeCreateWorkThemeModal extends LightningModal {
    /** Work Trail whose related list is being updated. */
    @api recordId;

    flowError = false;

    /** Supplies the Work Trail ID expected by the creation flow. */
    get flowInputVariables() {
        return [{ name: 'recordId', type: 'String', value: this.recordId }];
    }

    /** Closes the modal after completion and presents a message if the flow fails. */
    handleFlowStatusChange(event) {
        const { status } = event.detail;
        if (status === 'FINISHED') {
            this.close('created');
        } else if (status === 'ERROR') {
            this.flowError = true;
        }
    }
}
