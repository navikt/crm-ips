public with sharing class IPS_UtilityFlowTranslateController {

     // Define the input parameter class
     public class Input {
        @InvocableVariable(required=true)
        public String inputString;

        @InvocableVariable(required=true)
        public String fieldCategory;
        
    }

    // Define the output parameter class
    public class Output {
        @InvocableVariable
        public String outputString;
    }
    @InvocableMethod(label='IPS Flow Utility Translate' description='Translates a given string based on the string and field API name')
    public static List<Output> translateString(List<Input> request) {
        List<Output> outputs = new List<Output>();

        for (Input req : request) {
            Output output = new Output();
            String inputString = req.inputString;
            String fieldCategory = req.fieldCategory;
            
            if(String.isBlank(inputString)){
                output.outputString = '';
                outputs.add(output);
            }else{
                // Perform translation based on category
                    //Main goal Jobbsporet
                    if (fieldCategory == 'MAINGOAL') {
                        switch on inputString {
                            when 'Work' { output.outputString = 'Arbeid'; }
                            when 'Education/Apprentice' { output.outputString = 'Utdanning'; }
                            when 'AMS' { output.outputString = 'Arbeid'; }
                            when 'Vocational education and training' { output.outputString = 'Arbeid via fag- og yrkesopplæring'; }
                            when else { output.outputString = 'Ukjent hovedmål'; }
                        }
                    }
                    //Status jobbsporet
                    if(fieldCategory == 'STATUS'){
                        switch on inputString {
                            when 'Referred' { output.outputString = 'Henvist'; }
                            when 'Initial contact' { output.outputString = 'Innledende kontakt'; }
                            when 'Mapping' { output.outputString = 'Kartlegging'; }
                            when 'Job development' { output.outputString = 'Jobbutvikling'; }
                            when 'In Education' { output.outputString = 'I utdannelse'; }
                            when 'Working' { output.outputString = 'Jobber'; }
                            when 'Downsizing' { output.outputString = 'Nedtrapping'; }
                            when 'Career mapping and career planning' { output.outputString = 'Yrkeskartlegging og karriereplanlegging'; }
                            when 'Find a suitable job / Collaborate with AG' { output.outputString = 'Finne en passende jobb / samarbeid med arb.g'; }
                            when 'Education and training in and / or outside the workplace' { output.outputString = 'Opplæring og trening på og/eller utenom arbeidsplassen'; }
                            when 'Information and decision support' { output.outputString = 'Informasjon og beslutningsstøtte'; }
                            when 'Discovery' { output.outputString = 'Utforske muligheter'; }
                            when 'Job development CE' { output.outputString = 'Tilpasset jobbutvikling'; }
                            when 'Adapted training and training in the workplace' { output.outputString = 'Tilpasset opplæring og trening på arbeidsplassen'; }
                            when 'Long-term available follow-up and career development' { output.outputString = 'Langvarig tilgjengelig oppfølging og karriereutvikling'; }
                            when 'Ended' { output.outputString = 'Sluttet'; }
                            when else { output.outputString = 'Ukjent status'; }
                        }
                    }

                    if(fieldCategory == 'ENDCAUSE'){
                        switch on inputString {
                            when 'Education' { output.outputString = 'Utdanning'; }
                            when 'Other end causes' { output.outputString = 'Andre sluttårsaker'; }
                            when 'Work' { output.outputString = 'Arbeid'; }
                            when else { output.outputString = 'Ukjent avslutningsårsak'; }
                        }
                    }

                    if(fieldCategory == 'ENDDETAILCAUSE'){
                        switch on inputString {
                            when 'Education - self-financed' { output.outputString = 'Utdanning - egenfinansiert'; }
                            when 'Education - covered by NAV' { output.outputString = 'Utdanning - dekket av NAV'; }
                            when 'Chaining for other work-oriented measures under the auspices of NAV' { output.outputString = 'Kjeding til andre arbeidsrettede tiltak i regi av NAV'; }
                            when 'Other active measures in consultation with NAV (eg medical treatment, or municipal measures)' { output.outputString = 'Andre aktive tiltak i samråd med NAV (eks medisinsk behandling eller kommunale tiltak)'; }
                            when 'Illness' { output.outputString = 'Sykdom'; }
                            when 'Applied for / granted old age pension / AFP' { output.outputString = 'Søkt/innvilget alderspensjon/AFP'; }
                            when 'Applied / granted disability benefits' { output.outputString = 'Søkt/innvilget uføretrygd'; }
                            when 'Other (military, pregnancy, relocation, etc.)' { output.outputString = 'Annet (militær, svangerskap, flytting mm)'; }
                            when 'Work without wage subsidy' { output.outputString = 'Arbeid uten lønnstilskudd'; }
                            when 'Work with wage subsidies from NAV' { output.outputString = 'Arbeid med lønnstilskudd fra NAV'; }
                            when 'Work in combination with other benefits from NAV / granted disability benefits' { output.outputString = 'Arbeid i kombinasjon med andre ytelser fra NAV'; }
                            when 'Work in combination with a graduated disability pension (military, pregnancy, relocation, etc.)' { output.outputString = 'Arbeid i kombinasjon med gradert uførepensjon'; }
                            when 'Not applicable' { output.outputString = 'Ikke aktuell'; }
                            when else { output.outputString = 'Ukjent avslutningsdetaljårsak'; }
                        }
                    }



                    outputs.add(output);
                }


            }
            
        return outputs;
    }
}