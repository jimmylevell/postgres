# About Postgres
Postgres service (postgres database and pgadmin web interface) of levell.  

## Frameworks used
- Postgres  
- pgadmin   

# Docker image details  
## Postgres
Base image: postgres  
Exposed ports: 5432  
Additional installed resources:  
- Troubleshooting: vim, net-tools, dos2unix  

## pgadmin
Base image: dpage/pgadmin4  
Exposed ports: 80  
Additional installed resources:  
- Troubleshooting: vim, net-tools, dos2unix  

### Configuration
Store the secret of the admin user in docker secret
```
printf pgadminpassword | docker secret create pgadmin_password -
```

# Deployment
## General
Service: postgres  
Data Path: /home/docker/levell/postgres/  

## Postgres
### General
Access URL: none  

### Attached Networks
- levell - access to levell services

### Attached volumes
postgresdata: postgres data  

### Environment variables 
#### Secret for postgres user
POSTGRES_PASSWORD_FILE

## pgadmin
### General
Access URL: postgresinterface.app.levell.ch  

### Attached Networks
- traefik-public - access to reverse proxy
- levell - access to levell services

### Attached volumes
None  

### Environment variables 
#### Credential of admin user 
PGADMIN_DEFAULT_EMAIL: default admin user for login  
PGADMIN_DEFAULT_PASSWORD: password of default admin  