FROM alekslitvinenk/openvpn:latest

ENV CLIENT="0xVPN-Client"

# Install Python, pip, and essential tools
RUN echo "Installing Python, pip, and essential tools..."
RUN apk add --no-cache python3 py3-pip py3-virtualenv curl

# Create a directory for the Python environment
RUN mkdir -p /etc/openvpn/python

# Log the creation of the virtual environment
RUN echo "Creating a virtual environment in /etc/openvpn/python..."
RUN python3 -m venv /etc/openvpn/python

# Update the PATH to use the virtual environment's binaries
RUN echo "Activating the virtual environment..."
ENV PATH="/etc/openvpn/python/bin:$PATH"

# Log the installation of Python packages within the virtual environment
RUN echo "Installing Python packages within the virtual environment..."
RUN pip install requests
RUN pip install python-dotenv

# Create directory for authentication scripts
RUN echo "Creating directory for authentication scripts..."
RUN mkdir -p /etc/openvpn/authenticator

# Copying authentication scripts from your directory
RUN echo "Copying authentication scripts from your directory..."
COPY openvpn-authentication-scripts/auth.py /etc/openvpn/authenticator/auth.py
COPY openvpn-authentication-scripts/connect.py /etc/openvpn/authenticator/connect.py
COPY openvpn-authentication-scripts/disconnect.py /etc/openvpn/authenticator/disconnect.py
COPY openvpn-authentication-scripts/.env /etc/openvpn/authenticator/.env

# Make scripts executable
RUN echo "Making scripts executable..."
RUN chmod +x /etc/openvpn/authenticator/auth.py \
    && chmod +x /etc/openvpn/authenticator/connect.py \
    && chmod +x /etc/openvpn/authenticator/disconnect.py

RUN sed -i 's/verb 1/verb 11/' /etc/openvpn/server.conf && \
    sed -i '/duplicate-cn/d' /etc/openvpn/server.conf && \
    echo "auth-user-pass-verify /etc/openvpn/authenticator/auth.py via-env" >> /etc/openvpn/server.conf && \
    echo "client-connect /etc/openvpn/authenticator/connect.py" >> /etc/openvpn/server.conf && \
    echo "client-disconnect /etc/openvpn/authenticator/disconnect.py" >> /etc/openvpn/server.conf && \
    echo "script-security 3" >> /etc/openvpn/server.conf && \
    echo "verify-client-cert none" >> /etc/openvpn/server.conf

# Copy the custom scripts
COPY client_config_generate.sh /client_config_generate.sh
COPY custom_entrypoint.sh /custom_entrypoint.sh

# Ensure the scripts are executable
RUN chmod +x /client_config_generate.sh /custom_entrypoint.sh

# Use the custom script as the new entrypoint
ENTRYPOINT ["/custom_entrypoint.sh"]