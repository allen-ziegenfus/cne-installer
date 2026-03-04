# Liferay Cloud Native Documentation

Welcome to the documentation for the **Liferay Cloud Native GCP Installer**. This project provides a robust, automated infrastructure for deploying Liferay DXP on Google Cloud Platform using GKE Autopilot, Crossplane, and ArgoCD.

## Quick Links

- [Architecture Harmonization Plan](architecture/harmonization-plan.md)
- [Kubernetes Gateway Comparison](architecture/gateway-comparison.md)
- [GitHub App Generator](github-app-generator.html)

## Project Overview

This repository contains the Terraform and Helm configurations required to bootstrap a complete Liferay environment. 

### Key Components

- **GKE Autopilot**: Secure, managed Kubernetes cluster.
- **Crossplane**: Infrastructure-as-Code inside Kubernetes.
- **ArgoCD**: GitOps continuous delivery.
- **Envoy Gateway**: Modern ingress management via the Gateway API.

## Getting Started

To begin the installation, refer to the [root README](../README.md) and the [setup tutorial](../tutorial.md) in the main repository.
