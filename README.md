# IG60 SoftwareAG Cumulocity Buildroot Integration
This repository contains the Buildroot external integration for the SoftwareAG Cumulocity agent.  This is based on the IG60 Laird Linux located here:

https://github.com/LairdCP/IG60-Laird-Linux-Release-Packages

## Building the IG60 Laird Linux image
Refer to the IG60 Laird Linux release notes (above) for details on using Buildroot and repo manifests.  For this integration, you will need to configure a Buildroot external tree.  Use the following steps to obtain the source tree from the integration manifest file:

     mkdir ig60_cumulocity_src
     cd ig60_cumulocity_src
     repo init -u https://github.com/LairdCP/IG60-Integration-Manifests.git -m ig60-softwareag.xml
     repo sync

Then, configure the Buildroot external with the BR2_EXTERNAL environment variable, and perform the build:

     export BR2_EXTERNAL=../softwareag
     make -C softwareag cumulocity_agent
