import { LightningElement,api,track,wire } from 'lwc';
import getCV from '@salesforce/apex/IPS_CVController.getCV';

export default class Ips_CV extends LightningElement {
    @api recordId;
    @api actorId;

    @track cv;
    @track sectionClass = 'slds-section slds-is-open';
    @track iconName = 'utility:chevrondown';

    responded = false;
    error = false;
    isExpanded = true;

    @wire(getCV, { recordId: '$recordId' })
    wiredCV({ data, error }) {
        if (data) {
            this.cv = data;
            this.responded = true;
        }
        if (error) {
            this.cv = null;
            this.error = true;
            console.log(JSON.stringify(error, null, 2));
        }
    }

    get isLoaded() {
        return this.error == true || this.responded == true;
    }

    get hasCv() {
        return this.isLoaded == true && this.cv !== null;
    }

    get utfylt() {
        return this.badges.length == 0 ? true : false;
    }

    get sistEndret() {
        if (this.cv == null) {
            return null;
        }
        let dato = new Date(this.cv.sistEndret);
        let dag = ('0' + dato.getDate()).slice(-2);
        let maned = ('0' + (dato.getMonth() + 1)).slice(-2);
        let ar = dato.getFullYear();
        let time = dato.getHours();
        let minutt = dato.getMinutes();
        return dag + '.' + maned + '.' + ar + ' kl. ' + time + ':' + minutt;
    }

    get synligForArbeidsgiver() {
        if (this.cv == null) {
            return null;
        }
        return this.cv.synligForArbeidsgiver == true ? 'Ja' : 'Nei';
    }

    get sammendrag() {
        return this.cv?.sammendrag ? this.cv.sammendrag : null;
    }

    get arbeidserfaring() {
        return this.cv?.arbeidserfaring ? this.cv.arbeidserfaring : null;
    }

    get utdanning() {
        return this.cv?.utdanning ? this.cv.utdanning : null;
    }

    get fagdokumentasjoner() {
        return this.cv?.fagdokumentasjoner ? this.cv.fagdokumentasjoner : null;
    }

    get annenErfaring() {
        return this.cv?.annenErfaring ? this.cv.annenErfaring : null;
    }

    get forerkort() {
        return this.cv?.forerkort ? this.cv.forerkort : null;
    }

    get kurs() {
        if (!this.cv?.kurs) {
            return null;
        }
        let list = [];
        let data = this.cv.kurs;

        for (var k in data) {
            let newTidsenhet = data[k].varighet.tidsenhet.toLowerCase();

            let newVarighet = { varighet: data[k].varighet.varighet, tidsenhet: newTidsenhet };
            let newKurs = {
                tittel: data[k].tittel,
                arrangor: data[k].arrangor,
                fraDato: data[k].fraDato,
                varighet: newVarighet
            };
            list.push(newKurs);
        }
        return list;
    }

    get godkjenninger() {
        return this.cv?.godkjenninger ? this.cv.godkjenninger : null;
    }

    get andreGodkjenninger() {
        return this.cv?.andreGodkjenninger ? this.cv.andreGodkjenninger : null;
    }

    get sprak() {
        if (!this.cv?.sprak) {
            return null;
        }
        let list = [];
        let data = this.cv.sprak;

        for (var s in data) {
            let muntlig = data[s].muntligNiva.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, ' ');
            muntlig = muntlig.charAt(0) + muntlig.slice(1).toLowerCase();
            let skriftlig = data[s].skriftligNiva.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, ' ');
            skriftlig = skriftlig.charAt(0) + skriftlig.slice(1).toLowerCase();

            let newSprak = { sprak: data[s].sprak, muntligNiva: muntlig, skriftligNiva: skriftlig };
            list.push(newSprak);
        }
        return list;
    }

    get yrker() {
        return this.cv?.jobbprofil?.onsketYrke ? this.cv.jobbprofil.onsketYrke : null;
    }

    get arbeidssted() {
        return this.cv?.jobbprofil?.onsketArbeidssted ? this.cv.jobbprofil.onsketArbeidssted : null;
    }

    get ansettelsesform() {
        if (!this.cv?.jobbprofil?.onsketAnsettelsesform) {
            return null;
        }
        let list = [];
        let data = this.cv.jobbprofil.onsketAnsettelsesform;
        for (var a in data) {
            let tittel = data[a].tittel.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, ' ').replace('AE', 'Æ');
            tittel = tittel.charAt(0) + tittel.slice(1).toLowerCase();
            list.push(tittel);
        }
        return list;
    }

    get arbeidstidsordning() {
        if (!this.cv?.jobbprofil?.onsketArbeidstidsordning) {
            return null;
        }
        let list = [];
        let data = this.cv.jobbprofil.onsketArbeidstidsordning;
        for (var a in data) {
            let tittel = data[a].tittel.charAt(0) + data[a].tittel.slice(1).toLowerCase();
            list.push(tittel);
        }
        return list;
    }

    get heltidDeltid() {
        if (!this.cv?.jobbprofil?.heltidDeltid) {
            return null;
        }
        let list = [];
        let tid = this.cv.jobbprofil.heltidDeltid;
        if (tid.heltid == true) {
            list.push('Heltid');
        }
        if (tid.deltid == true) {
            list.push('Deltid');
        }
        return list;
    }

    get kompetanse() {
        return this.cv?.jobbprofil?.kompetanse ? this.cv.jobbprofil.kompetanse : null;
    }

    get badges() {
        let badgeList = [];
        if (this.sammendrag === '' || this.sammendrag == null) {
            badgeList.push('Sammendrag');
        }
        if (!this.utdanning?.length) {
            badgeList.push('Utdanninger');
        }
        if (!this.fagdokumentasjoner?.length) {
            badgeList.push('Fagbrev');
        }
        if (!this.arbeidserfaring?.length) {
            badgeList.push('Arbeidserfaringer');
        }
        if (!this.annenErfaring?.length) {
            badgeList.push('Andre erfaringer');
        }
        if (!this.forerkort?.length) {
            badgeList.push('Førerkort');
        }
        if (!this.godkjenninger?.length) {
            badgeList.push('Offentlige godkjenninger');
        }
        if (!this.andreGodkjenninger?.length) {
            badgeList.push('Andre godkjenninger');
        }
        if (!this.kurs?.length) {
            badgeList.push('Kurs');
        }
        if (!this.sprak?.length) {
            badgeList.push('Språk');
        }
        if (!this.kompetanse?.length) {
            badgeList.push('Kompetanser');
        }
        if (
            (this.yrker == null && this.arbeidssted == null && this.ansettelsesform == null) ||
            (this.ansettelsesform.length == 0 && this.arbeidstidsordning == null) ||
            (this.arbeidstidsordning.length == 0 && this.heltidDeltid == null) ||
            this.heltidDeltid.length == 0
        ) {
            badgeList.push('Jobbønsker');
        }
        return badgeList;
    }

    resolve(path, obj) {
        return path.split('.').reduce(function (prev, curr) {
            return prev ? prev[curr] : null;
        }, obj || self);
    }
}