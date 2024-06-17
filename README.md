Kubernetes/OpenShift clean yaml exporter
==================
This project was created out of frustration with Kubernetes and ArgoCD.  I find myself doing "oc get all -o yaml" and then having to clip runtime information out of my yamls.  
I really wish there was a feature in ArgoCD that said, "Import from Namespace".  But this is better because it allows me to generate clean Kustomize scripts, not just for argocd.

How to run
--------------
1.  Install yq(if you don't already have it)
2.  Install oc for openshift or install kubectl(and change all the oc references in the script to kubectl"
3.  Log into your openshift cluster using the link in the top right of your console.
4.  clone the repo or just copy the script into a command.sh of your choosing(don't forget to chmod it for execution)
5.  In oc or kubectl go into the project you want to export "oc project foo"
6.  execute "./export.sh"
7.  You'll find all of your clean yaml files under the names of what they are in the export directory. 
