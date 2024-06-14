#!/etc/openvpn/python/bin/python3

import sys
import os
import requests
import base64
from dotenv import load_dotenv


def main():
    message_1 = os.environ.get('username')
    message_2 = os.environ.get('password')
    combined_message = message_1 + message_2
    username = combined_message.split('@')[0]
    password = combined_message.split('@')[1] + '@' + combined_message.split('@')[2]
    password_bytes = password.encode("ascii")
    base64_bytes = base64.b64encode(password_bytes)
    encoded_password = base64_bytes.decode("ascii")
    url = os.getenv("AUTH_URL")
    api_key = os.getenv("API_KEY")
    headers = {"X-API-KEY": api_key, "Content-Type": "application/json"}
    json_data = {"message": username, "encodedData": encoded_password}
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
