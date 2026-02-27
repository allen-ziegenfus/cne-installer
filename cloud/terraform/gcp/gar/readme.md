This translates your AWS ECR setup to GCP Artifact Registry (GAR).

As discussed, the key structural difference is that in AWS you create a "Repository" for every single image name. In GCP, you create one "Artifact Registry" (like a folder) that can store many different Docker images.

To maintain compatibility with your other modules (which expect a list of repositories), I have structured the outputs.tf to generate a map of URLs that look exactly like what your system expects, even though they all live in one GCP Registry.