# Liferay Cloud Native - GCP Installer

## Welcome
Welcome to the Liferay Cloud Native GCP Installer. This guided tutorial will walk you through the installation process.

To get started, click **Next**.


## Select GCP Project
Before running the installer, you need to select the Google Cloud project where you want to deploy Liferay.

Click the button below to select your project:

<walkthrough-project-setup required="true"></walkthrough-project-setup>

Once selected, you can verify it in your terminal:

```sh
gcloud config get-value project
```

## Run the Installer
Now you can execute the installer. The script will use the project you just selected.

```sh
./installer
```

<walkthrough-footnote>Note: The installer is currently in a placeholder state and will not modify your GCP resources yet.</walkthrough-footnote>

## Summary
You have successfully built the installer and configured your GCP project.

You can <walkthrough-editor-open-file filePath="main.go">explore the code</walkthrough-editor-open-file> to see how it's implemented.
