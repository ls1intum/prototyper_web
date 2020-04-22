# README

This README documents the steps that are necessary to get the
application up and running using the docker image.

## 0. Preperation
   * Create a new User in Atlassian Jira 
      * Note down username and password 
   * Add the IP adress of your Prototyper host to the allowd jira user authentication services 
      * Jira > User Management > Jira user Servers > Add application 
      * Put "Prototyper" in "Application Name"
      * Create a random Password and note it down 
      * Put all IP adresses of you Prototyper host in the "IP adresses" field 
      

## 1. Install docker and docker-compose. 
- Docker
  - If you are using ubuntu you can [follow this tutorial](https://docs.docker.com/engine/install/ubuntu/) to install docker.
  - Other platforms can also be found on the official [docker documentation](https://docs.docker.com).
- docker-compose
  - The official documentation for installing docker-compose can be found [here](https://docs.docker.com/compose/install/)
## 2. Rename template files
 - Rename `./template.env` to `./.env` and change the values accordingly
   - Make sure to to set the `JIRA_AUTH_TOKEN` variable to `base64encode(<Jira-application-link-username>:<jira-application-link-password>)` in single quotes (`'`). Example: `JIRA_AUTH_TOKEN='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX='` 
 - [Optional for develpment] Update values for test and development in config/secrets.yml
## 3. Configure omniauth
__Create keypair and public key files__
```bash
cd /opt/prototyper
# Create folder for keypair
mkdir pem_key
cd pem_key
# Create key pair
openssl genrsa -out private_key.pem 2048
# Extract the public key
openssl rsa -pubout -in private_key.pem -out pubkey.pem
```

__Move private key to correct location__
```bash
# Copy private key to desired location
mv /opt/prototyper/pem_key/private_key.pem /opt/protoypter/prototyper_web/
```

__Upload public key to bamboo__
- Create an Application Link in bamboo under *Bamboo administration* -> *Application links* -> *Create new link*
- Enter your desired URL
- Fill out the form for this application
  - __Application Name__: Displayed name on list in Bamboo
  - __Application Type__: Generic Application
  - __Consumer key__: Random String, needs to be the same as `BAMBOO_CONSUMER` in `.env` file on Prototyper
  - __Shared secret__: Not used, can be random, but has to be filled in
  - __Request Token URL__: `https://bamboo.ase.in.tum.de/plugins/servlet/oauth/request-token`
  - __Access token URL__: `https://bamboo.ase.in.tum.de/plugins/servlet/oauth/access-token`
  - __Authorize URL__: `https://bamboo.ase.in.tum.de/plugins/servlet/oauth/authorize`
  - __Create incoming link__: Yes
- Afterwards the Incoming Authentication has to be configured:
  - __Consumer key__: Random String, same as `BAMBOO_CONSUMER`
  - __Consumer name__: Name of Application
  - __Description__: None
  - __Public key__: The public key in `pem` format created in the previous step
  - __Consumer Callback URL__: None
  - __Allow 2-Legged OAuth__: false
  - __Execute as__: None
  - __Allow user impersonation through 2-Legged OAuth__: false

## 4. Start the container with docker-compose
Run `docker-compose up -d and your server is running on port 80
## 5. [Optional] Setup Reverse Proxy
Reverse proxy can be set up to handle ssl outside of the prototyper container 
