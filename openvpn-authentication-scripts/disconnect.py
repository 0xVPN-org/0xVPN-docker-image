#!/etc/openvpn/python/bin/python3

import sys
import os
import requests
from dotenv import load_dotenv


def main():
    message_1 = os.environ.get('username')
    username = message_1.split('@')[0]
    url = os.getenv("DISCONNECT_URL")
    api_key = os.getenv("API_KEY")
    headers = {"X-API-KEY": api_key, "Content-Type": "application/json"}
    json_data = {"message": username}
    try:
        response = requests.post(url, headers=headers, json=json_data)
        response.raise_for_status()
        if response.status_code == 200:
            sys.exit(0)  # Success: valid signature and data
        else:
            sys.exit(1)  # Failure
    except Exception as e:
        sys.exit(1)

if __name__ == "__main__":
    load_dotenv()
    main()
