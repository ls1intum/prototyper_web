== README

This README documents the steps that are necessary to get the
application up and running using the docker image.

1. Install docker and docker-compose. If you are using ubuntu you can [follow this tutorial](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=94798094)
2. Rename `./template.env` to `./.env` and change the values accordingly
    * Make sure to to set the `JIRA_AUTH_TOKEN` variable to `base64encode(<Jira-application-link-username>:<jira-application-link-password>)` in single quotes (`'`). Example: `JIRA_AUTH_TOKEN='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX='` 
3. Rename `./config/secrets_template.yml` to  `./config/secrets.yml`
    * [Optional for develpment] Update values for test and development 
4. Run 'docker-compose up -d' and your server is running on port 80
5. [Optional] Setup reverse proxy to handle ssl outside of the prototyper container 
