# Liferay Cloud Native - GCP Installer

## Welcome
Welcome to the Liferay Cloud Native GCP Installer. This guided tutorial will walk you through the installation process.

To get started, click **Next**.

## Build the Installer
First, we will compile the Go source code into an executable binary. This ensures that the environment has all necessary dependencies.

Run the following command in your terminal:

```sh
go build -o installer main.go
```

Once the build is complete, click **Next**.

## Run the Installer
Now you can execute the installer. This script will guide you through the GCP configuration.

Click the button below to run the binary:

```sh
./installer
```

<walkthrough-footnote>Note: The installer is currently in a placeholder state and will not modify your GCP resources yet.</walkthrough-footnote>

## Summary
You have successfully built and run the installer. 

In a production environment, this script would now:
1. Prompt for **GCP Project** selection.
2. **Enable APIs** (Compute, Kubernetes, etc.).
3. Initialize **Terraform/OpenTofu** to provision infrastructure.

You can <walkthrough-editor-open-file filePath="main.go">explore the code</walkthrough-editor-open-file> to see how it's implemented.
