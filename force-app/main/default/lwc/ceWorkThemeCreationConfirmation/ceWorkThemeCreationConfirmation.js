import { LightningElement, api } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

export default class CeWorkThemeCreationConfirmation extends LightningElement {
    @api createdThemesText;

    @api
    validate() {
        this.dispatchEvent(new RefreshEvent());
        return { isValid: true };
    }
}
