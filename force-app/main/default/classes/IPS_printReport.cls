public with sharing class IPS_printReport {
        
    @AuraEnabled
        public static blob getBase64String(String reportId){
            List<ips_report__c> report = new List<ips_report__c>();
            report=[
                SELECT id,IPS_report_Type__c,IPS_intervallReport__c,IPS_endReport__c 
                FROM ips_report__c 
                WHERE id =:reportId];
            String reportText = '';
            Blob documentPdf;
    
            for(ips_report__c r:report){
                if(r.IPS_report_Type__c=='Intervall'){
                    reportText += '<html><body>';
                    //reportText +='<p><p style="text-align: left;"><span style="font-size: 14px;"><img src="https://navdialog--c.visualforce.com/resource/1587557877000/logo?"></span></p></p>';
                    reportText += '\r\n';
                    reportText += r.IPS_intervallReport__c;
                    reportText += '</body></html>';
                }else if(r.IPS_report_Type__c=='End Report'){
                    reportText += '<html><body>';
                    //reportText +='<p><p style="text-align: left;"><span style="font-size: 14px;"><img src="https://navdialog--c.visualforce.com/resource/1587557877000/logo?"></span></p></p>';
                    reportText += '\r\n';
                    reportText += r.IPS_endReport__c;
                    reportText += '</body></html>';
                }
            }
                documentPdf =blob.toPdf(reportText);
                Attachment at = new Attachment(name='TEST AV PDF' + '.pdf', body = documentPdf);

                return documentPdf;
            }
        }