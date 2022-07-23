# Jenkins

## Setup Pipeline

Need to have a credential with id: `jenkins-gh-user`, in order to Promote Versions.

Should be setup as a Multi-branch pipeline, targeting `jenkins/Jenkinsfile`

Before setting up the pipeline, you might consider "forking" this repo, so that you can modify the source files, for your cluster/env. It would make sense to change the AGENT_REGISTRY and REGISTRY parameters in the jenkinsfile, based on where you have sourced your images for the agent, and where you are targeting the build to go. 

In this AWS example, the the AGENT_REGISTRY and the REGISTRY are the same, within the same account. Only a single role assignment was needed to give Jenkins the appropriate permissions, which are passed into the build agent via the kubernetes service Account.

For better understanding, run the commands in `setup-jenkins-pipeline-aws.sh`, individally. 

#### https://www.redhat.com/sysadmin/podman-inside-kubernetes