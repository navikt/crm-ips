for (ips_Education__c e : [select id, ips_What_did_work_with_this_education__c, ips_What_did_not_work_with_thiseducation__c from ips_Education__c]) {
    String tmp = e.ips_What_did_work_with_this_education__c;
    e.ips_What_did_work_with_this_education__c = e.ips_What_did_not_work_with_thiseducation__c;
    e.ips_What_did_not_work_with_thiseducation__c = tmp;
    update e;
}
