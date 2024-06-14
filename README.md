# 0xVPN-docker-image
Docker Image for 0xVPN Node Operator Setup v1.0

## Important Notes

Requires API Key from 0xVPN to run.

Please contact us at t.me/zerox_vpn_portal to get your API Key.

## Installation

Add your node operator API Key after the `API_KEY=` at the `.env` file which is located in `openvpn-authentication-scripts` directory.

cd to the docker directory and run the following command to build the docker image:
```
docker build -t 0xvpn-openvpn .
```

To run the docker container, run the following command:
```
docker run -it --cap-add=NET_ADMIN -p 1194:1194/udp -p 80:8080/tcp --name 0xvpn 0xvpn-openvpn
```