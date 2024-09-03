# Use the official Ubuntu as a parent image
FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y curl apt-transport-https gnupg

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install SQLCMD and tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Set PATH for sqlcmd and az
ENV PATH=$PATH:/opt/mssql-tools/bin:/usr/bin

# Copy scripts into the container
COPY create-sql-cmd.sh /usr/local/bin/create-sql-cmd.sh
COPY drop-sql-cmd.sh /usr/local/bin/drop-sql-cmd.sh
COPY manage-sql-cmd.sh /usr/local/bin/manage-sql-cmd.sh

# Make the scripts executable
RUN chmod +x /usr/local/bin/create-sql-cmd.sh
RUN chmod +x /usr/local/bin/drop-sql-cmd.sh
RUN chmod +x /usr/local/bin/manage-sql-cmd.sh

# Set the default command to run the manage-sql-cmd.sh script
CMD ["/usr/local/bin/manage-sql-cmd.sh"]
