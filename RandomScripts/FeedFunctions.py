import CTOSecurity as cto
from CTOSecurity import chunks
import requests
import pytz
from datetime import datetime, timedelta, timezone

def retrieveIndicatorList(url):
    try:
        # retrieve the list of URLHaus indicators
        urlhaus_url = url
        results = requests.get(urlhaus_url)
        response = results.json()
        items = list(response.items())
        iocs = [{k: v[0]} for k, v in items]
        start_time = (datetime.now(timezone.utc) - timedelta(minutes=65))
        utc=pytz.UTC
        iocs = [ioc for ioc in iocs if utc.localize(datetime.strptime(list(ioc.values())[0]["dateadded"], "%Y-%m-%d %H:%M:%S UTC")) > start_time]
        return {"success": True, "data": iocs}
    except requests.exceptions.RequestException as req_err:
        return {"success": False, "error_message": f"Error during HTTP request {req_err}"}
    except ValueError as json_err:
        return {"success": False, "error_message": f"Error decoding JSON: {json_err}"}
    except KeyError as key_err:
        return {"success": False, "error_message": f"Missing key in JSON: {key_err}"}
    except Exception as e:
        return {"success": False, "error_message": f"An unexpected error occured: {e}"}

def uploadToSentinel(indicators):
    try:
        # connect to Sentinel
        print("\nConnecting to Sentinel.")
        s = cto.MSSentinel()
        # upload new indicators
        print("\nUploading fresh IOCs to Sentinel Threat Intelligence.")
        chonks = chunks(indicators, 100)
        chonks_len = len(indicators) // 100 + 1
        cntr = 1
        for chonk in chonks:
            print("- Importing chunk {} of {}.".format(cntr, chonks_len))
            s.upload_ti_indicators("Amtrak Cyber Threat Operations", chonk)
            cntr += 1
        return {"success": True, "message": "Upload successfully completed"}
    except cto.SentinelConnectionError as conn_err:
        # Handle connection errors with Sentinel
        return {"success": False, "error_message": f"Error connecting to Sentinel: {conn_err}"}
    except cto.SentinelUploadError as upload_err:
        # Handle errors during the upload process
        return {"success": False, "error_message": f"Error uploading indicators to Sentinel: {upload_err}"}
    except Exception as e:
        # Handle other unexpected errors
        return {"success": False, "error_message": f"An unexpected error occurred: {e}"}