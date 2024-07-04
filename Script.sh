#!/bin/bash

#I have divided the script into 3 parts...
#Part 1 :: Here We are Running the AWS Inspector scan and waiting untill it completes the scan
#Part 2 :: Next we are downloading the report of that scan generated by inspector into the server where this script is running



#PART1======================================================================================

AWS_REGION="us-east-1"
ASSESSMENT_TEMPLATE_ARN="arn:aws:inspector:us-east-1:161786843916:target/0-ptyjBgbD/template/0-DXuMsqUo"
REGION="us-east-1"

# Start the AWS Inspector scan and get the scan ARN
SCAN_ARN=$(aws inspector start-assessment-run --assessment-template-arn $ASSESSMENT_TEMPLATE_ARN --output text)
echo " "
echo "Inspector Scan has been started..."
sleep 2
# Wait for the scan to complete
while true; do
  # Get the scan status
  SCAN_STATUS=$(aws inspector describe-assessment-runs --assessment-run-arns $SCAN_ARN --query 'assessmentRuns[0].state' --output text)
  echo " "
  echo "Scan status: $SCAN_STATUS"
  sleep 2
  # Check if the scan is completed
  if [ "$SCAN_STATUS" == "COMPLETED" ]; then
    break
  fi
  sleep 3
done
echo " "
echo "Scan is Completed successfully"
echo " "
echo "Prepairing Scan report, this will only take few seconds"
sleep 2







#PART2======================================================================================

# Get the latest assessment run ARN
LATEST_RUN_ARN=$(aws inspector list-assessment-runs --region $REGION --query "assessmentRunArns[0]" --output json | tr -d '"')
echo $LATEST_RUN_ARN

sleep 5
# Get the findings report URL for the latest assessment run
REPORT_URL=$(aws inspector get-assessment-report --assessment-run-arn $LATEST_RUN_ARN --report-file-format "PDF" --report-type "FULL" --query "url" --output text)
echo $REPORT_URL

# Download the report
wget -O /home/ubuntu/report.pdf "$REPORT_URL"
echo "Latest Inspector report downloaded to ./latest_inspector_report.pdf"

