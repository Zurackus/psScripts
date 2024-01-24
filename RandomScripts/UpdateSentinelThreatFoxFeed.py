import CTOSecurity as cto
from CTOSecurity import chunks
import uuid
import FeedFunctions
from datetime import datetime, timedelta, timezone

error_message = ""
print("Retrieving ThreatFox indicators.")
url = "https://threatfox.abuse.ch/export/json/recent/"
result = FeedFunctions.retrieveIndicatorList(url)
if result["success"]:
    # Operation was successful
    iocs = result["data"]
    print("Successfully retrieved indicators:")
    # format the indicators for Sentinel upload
    print("\nFormatting IOCs in Sentinel upload format.")
    indicators = []
    for ioc in iocs:
        indicator_id = list(ioc.keys())[0]
        indicator_type = list(ioc.values())[0]["ioc_type"].replace("ip:port", "IP address")
        malware_type = list(ioc.values())[0]["malware_printable"]
        indicator_value = list(ioc.values())[0]["ioc_value"]
        if list(ioc.values())[0]["tags"]:
            tags = list(ioc.values())[0]["tags"].split(",")
        else:
            tags = []
        if indicator_type == "IP address":
            indicator_value = indicator_value.split(":")[0]
            pattern = "[ipv4-addr:value = '{}']".format(indicator_value)
        elif indicator_type == "domain":
            pattern = "[domain-name:value = '{}']".format(indicator_value)
        elif indicator_type == "url":
            pattern = "[url:value = '{}']".format(indicator_value)
        elif indicator_type == "md5_hash":
            pattern = "[file.hashes.MD5 = '{}']".format(indicator_value)
        elif indicator_type == "sha256_hash":
            pattern = "[file.hashes.'SHA-256' = '{}']".format(indicator_value)
        else:
            continue
        confidence_level = list(ioc.values())[0]["confidence_level"]
        indicators.append(
            {
                "id": "indicator--" + str(uuid.uuid4()),
                "spec_version": "2.1",
                "type": "indicator",
                "created": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "modified": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "name": "ThreatFox {} indicator for {}".format(indicator_type, malware_type),
                "description": "For more information see {}".format("https://threatfox.abuse.ch/ioc/" + indicator_id),
                "indicator_types": ["malicious-activity"],
                "pattern": pattern,
                "pattern_type": "stix",
                "valid_from": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "valid_until": (datetime.now(timezone.utc) + timedelta(7)).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "labels": list(set(["ThreatFox", "CTO", malware_type] + tags)),
                "confidence": confidence_level
            }
        )
    
    uploadResult = FeedFunctions.uploadToSentinel(indicators)

    if uploadResult["success"]:
        print(uploadResult["message"])
    else:
        # Operation failed
        error_message = uploadResult["error_message"]
else:
    # Operation failed
    error_message = result["error_message"]

if error_message != "":
    email = cto.Email()
    recipients = cto.team_emails
    subject = "ThreatFox Threat Intel Update Process Failed"
    timestamp = datetime.now().strftime("%c")
    body = "{}\n\nError message:\n\n{}".format(timestamp, error_message)
    result = email.send_email(recipients, subject, body)
else:
    print("Script completed successfully")