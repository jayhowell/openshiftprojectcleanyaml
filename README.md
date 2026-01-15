# OpenShift YAML Exporter for Argo CD (GitOps)

## Why this exists

- This project was created out of frustration with Kubernetes and Argo CD.
- I frequently find myself doing:

```bash
oc get all -o yaml
```

- Then spending time manually clipping runtime information out of the YAML.
- I really wish Argo CD had a feature like:
  - **"Import from Namespace"**
- This is better (for my workflow) because it allows me to generate **clean Kustomize-ready YAML**, not just YAML for Argo CD.

---

## Overview

- This script exports Kubernetes/OpenShift resources from a namespace into **clean YAML manifests** suitable for **GitOps workflows** (ex: committing to Git and syncing with **Argo CD**).
- The script:
  - Enumerates a predefined set of resource types in a namespace
  - Exports each resource into its own YAML file
  - Removes runtime-generated metadata and `.status` using `yq`
  - Writes output into a local `./export/` directory organized by resource type

---

## Requirements

### Tools

- `oc` (OpenShift CLI)
  - Must be installed
  - Must be logged in to the target cluster
- `yq`
  - Must be installed
  - Script expects **Mike Farah `yq` v4** syntax (`yq eval ...`)

- Verification commands:

```bash
oc version
yq --version
```

### Permissions

- You must be logged in with a user/serviceaccount that can run `oc get` for the exported resource types in the target namespace
- Minimum permissions required:
  - `oc get deployments`
  - `oc get services`
  - `oc get configmaps`
  - `oc get secrets`
  - `oc get pods`
  - `oc get routes`

---

## What Gets Exported

- Default resource types exported:
  - `deployments`
  - `services`
  - `configmaps`
  - `secrets`
  - `pods`
  - `routes`

- Output directory structure:

```text
export/
  deployments/
    <name>.yaml
  services/
    <name>.yaml
  configmaps/
    <name>.yaml
  secrets/
    <name>.yaml
  pods/
    <name>.yaml
  routes/
    <name>.yaml
```

---

## How to run

- Install `yq` (if you don't already have it)
  - You can download it from:
    - https://github.com/mikefarah/yq/releases

- Install `oc` for OpenShift
  - OR install `kubectl` and update the script:
    - Change all `oc` references in the script to `kubectl`

- Log into your OpenShift cluster
  - Use the **link in the top right** of your OpenShift console (Copy Login Command)

- Clone the repo OR copy the script into your own file
  - Example:
    - `command.sh`
  - Do not forget to make it executable:

```bash
chmod +x export.sh
```

- Set your namespace/project in OpenShift:

```bash
oc project foo
```

- Run the export:

```bash
./export.sh
```

- Review the output
  - You will find all of your clean YAML files under the `export/` directory
  - Files are organized by resource type

---

## Usage

### Export the default resource types from the current namespace

- If you do **not** specify a namespace, the script uses your current OpenShift project:

```bash
./export.sh
```

### Export from a specific namespace

```bash
./export.sh -n book-import
```

### Export and remove additional YAML fields

- You can remove additional YAML paths using the `-c` flag
- This is useful for removing fields you do not want managed by GitOps

- Remove all annotations:

```bash
./export.sh -n book-import -c .metadata.annotations
```

- Remove multiple fields (must be **comma + space** separated):

```bash
./export.sh -c '.metadata.annotations, .metadata.labels, .metadata.namespace, .spec.strategy'
```

### Verbose mode

- Verbose mode prints the commands as they are executed:

```bash
./export.sh -V
```

---

## Command Line Options

- `-h`
  - Print help text and examples
- `-n <namespace>`
  - Namespace to export from (defaults to current project)
- `-c <fields>`
  - Additional YAML paths to delete using `yq`
- `-V`
  - Verbose mode (`set -x`)

---

## YAML Cleanup / Normalization

- For each exported object, the script deletes runtime-generated fields that typically create GitOps noise
- Deleted fields:
  - Additional fields passed in via `-c` (if provided)
  - `.metadata.creationTimestamp`
  - `.metadata.generation`
  - `.metadata.resourceVersion`
  - `.metadata.selfLink`
  - `.metadata.uid`
  - `.metadata.managedFields`
  - `.status`

---

## Notes / Limitations

- **Pods** are typically not recommended for GitOps export/import
  - Pods are usually created by controllers (Deployments, Jobs, etc.)
  - Keeping Pod YAML in Git can cause drift and reconciliation noise
- **Secrets** may contain sensitive data
  - Use caution before committing exported Secrets to Git
  - Consider External Secrets, Sealed Secrets, or another secrets-management approach
- This script exports **namespace-scoped** resources only
  - It does not export cluster-scoped resources (CRDs, ClusterRoles, etc.)
- This script does not export:
  - Argo CD `Application` objects
  - Operators / Subscriptions
  - Custom Resource Definitions (CRDs)

---

## Output Location

- All YAML files are written to:

```text
./export/
```

- Existing files may be overwritten if the same resource name is exported again
