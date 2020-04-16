== README

This README documents the steps that are necessary to get the
application up and running using the docker image.

0. Preperation
   * Create a new User in Atlassian Jira 
      * Note down username and password 
   * Add the IP adress of your Prototyper host to the allowd jira user authentication services 
      * Jira > User Management > Jira user Servers > Add application 
      * Put "Prototyper" in "Application Name"
      * Create a random Password and note it down 
      * Put all IP adresses of you Prototyper host in the "IP adresses" field 
      

1. Install docker and docker-compose. If you are using ubuntu you can [follow this tutorial](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=94798094)
2. Rename `./template.env` to `./.env` and change the values accordingly
   * Make sure to to set the `JIRA_AUTH_TOKEN` variable to `base64encode(<Jira-application-link-username>:<jira-application-link-password>)` in single quotes (`'`). Example: `JIRA_AUTH_TOKEN='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX='` 
3. Rename `./config/secrets_template.yml` to  `./config/secrets.yml`
   * [Optional for develpment] Update values for test and development 
4. Configure omniauth
   * Generate Public/private key pair in .pem format 
   * Store the `private_key.pem` in the application root dir 
   * The public key is used to authenticate with bamboo. You have to add the public key in the bamboo application link
      * Bamboo administartion > Application links 
      * Enter the hostname of your prototyper instance 
      * Click "create new link"
      * Edit the new application link 
      * Click on "Incoming Authentication"
      * Put a random but fixed string in "Consumer Key"
      * Put "Prototyper" into "Consumer Name"
      * Put the public key from earlier in the "Public Key" field 
      * Hit save
4. Run 'docker-compose up -d' and your server is running on port 80
5. [Optional] Setup reverse proxy to handle ssl outside of the prototyper container 
