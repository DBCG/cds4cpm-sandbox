#!/bin/bash

echo "beginning sleep"
# Give the new server a couple minutes to come up
 sleep 5m
#QUESTIONNAIRE_ID="/Questionnaire/mypain-questionnaire-ufl"
#echo $QUESTIONNAIRE_ID
#BASE_URL= "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir"
#echo $BASE_URL
#QUESTIONNAIRE_URL=$BASE_URL$QUESTIONNAIRE_ID
#echo $BASE_URL
#echo $QUESTIONNAIRE_URL

#load patient bundles
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/benufldevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/noConditionsufldevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/noObs1ufldevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/noObs2ufldevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/noObs3ufldevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/noUDSnoMyPainDevelopbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/ZachBakerbundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/TommyJonesBundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/SallyEchoBundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/bundles/UFLPatients/AlphaDeltaBundle.json" | curl -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir" -H "Content-Type:application/json"

#load questionnaire
curl "https://raw.githubusercontent.com/cqframework/cds4cpm/master/input/resources/questionnaire/mypain-questionnaire-ufl.json" | curl -X PUT -H "Content-Type:application/json" -d @- "https://cloud.alphora.com/ufl/r4/cqf-ruler/fhir/Questionnaire/mypain-questionnaire-ufl"