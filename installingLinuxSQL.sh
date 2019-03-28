# Install the SQL Server package

# OR USE THIS https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-2017

# At the login prompt, type student, and then press Enter.
# At the Password prompt, type Pa55w.rd, and then press Enter.
# At the prompt, type the following command, and then press Enter to download the Microsoft SQL Server Red Hat repository configuration file:
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo

# If requested for a password, type Pa55w.rd, and then press Enter.

# At the prompt, type the following command, and then press Enter to install SQL Server:
sudo yum install -y mssql-server

# Configure SQL Server
# At the prompt, type the following command, and then press Enter:
sudo /opt/mssql/bin/mssql-conf setup

# If prompted for your password, type Pa55w.rd, and then press Enter.
# To select the Evaluation edition, type 1, and then press Enter.
# At the license terms prompt, type Yes, and press Enter to accept the license terms.
# At the SQL Server system administrator password prompt, type Pa55w.rd, and press Enter to set the system administrator password.
# At the Confirm the SQL Server system administrator password prompt, type Pa55w.rd, and press Enter to confirm the password.

# Install SQL Server tools
# At the prompt, type the following command, and then press Enter to download the Microsoft SQL Server tools repository configuration file:
sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

# At the prompt, type the following command, and then press Enter to install SQL Server command-line tools:
sudo yum install -y mssql-tools unixODBC-devel

# At the license terms prompt, type yes, and then press Enter to accept the ODBC license terms.

# At the license terms prompt, type yes, and then press Enter to accept the license terms.

# At the prompt, type the following command, and then press Enter to add the tools to the PATH environment variable:

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# Create a database
# At the prompt, type the following command, and then press Enter to connect to SQL Server:
sqlcmd -S localhost -U sa -P 'Pa55w.rd'

# At the prompt, type the following command, and then and press Enter:
CREATE DATABASE Worldwide1
# At the prompt, type the following command, and then and press Enter to run the previous command:
GO

# At the prompt, type the following command, and then and press Enter to verify that the database was created:
SELECT database_id, name FROM sys.databases WHERE name = 'Worldwide1'

# At the prompt, type the following command, and then and press Enter to run the previous command:
GO
