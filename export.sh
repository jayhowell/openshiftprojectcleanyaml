Help()
{
   # Display Help
   echo "This function will export clean yaml out of Openshift to be consumed by ArgoCD"
   echo
   echo "Syntax: export.sh [-h|n|c|r|d]"
   echo "options:"
   echo "-h     Print this Help."
   echo "-n     Namespace to export from"
   echo "-c     Additional yaml cleanup elements.  Arguments must have a period at the beginning and must have a comma and a space separating elements."
   echo "-r     Resource Types(resource included are deployments,services,configmaps,secrets,pods, androutes)"
   echo "-V     Verbose - echos all commands being run. "
   echo
   echo "All yaml files will be placed in the ./export directory"
   echo
   echo "EXAMPLES:"
   echo "Export the yaml from the book-import namespace and delete all annotations(.metadata.annotations) in the yaml"
   echo "./export.sh -c .metadata.annotations -n book-import"
   echo 
   echo "Export the yaml from the current project and delete these tags in the yaml '.metadata.annotations,.metadata.labels,.metadata.namespace,.spec.strategy'"
   echo "./export.sh -c '.metadata.annotations,.metadata.labels,.metadata.namespace,.spec.strategy' "
   echo
   echo "Export the default resource types(deployments,services,configmaps,secrets,pods, androutes) from the current project"
   echo "./export.sh"

   echo
}


# Get the options
while getopts ":hn:c:V" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      n) # Specify the namespace to export from
         NAMESPACEARG=$("-n $OPTARG");;
      c) # Specify the namespace to export from
         ADDITIONAL_FIELDS=$OPTARG", ";;
      V) #debug statements
         set -x;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

echo "Namespace:"$NAMESPACEARG
types=("deployments" "services" "configmaps" "secrets" "pods" "routes")

# Create a directory to store the YAML files
mkdir -p export

# Loop through each resource type and export the YAML
for type in "${types[@]}"; do
  
  echo "Exporting ${type}..."
  #get all the resources that are in each type listed in the types array
  resources="$(oc get $type $NAMESPACEARG -o custom-columns=DEP:.metadata.name --no-headers)"
  #Tokenize on the eol character
  IFS=$'\n' resources1=($resources)
  #make the type root directory
  mkdir -p "export/$type"
  #Loop through all of the resources we've tokenized 
  for resource in "${resources1[@]}"; do 
    export_file="export/$type/${resource}.yaml"
    echo "-------exporting name $resource to $export_file"
    #get the yaml for the resource itself
    oc get "$type" "$resource" $NAMESPACEARG -o yaml > "export/$type/${resource}.yaml"
    #use yq to get rid of all of the runtime information
    yq eval 'del('$ADDITIONAL_FIELDS'.metadata.creationTimestamp, .metadata.generation, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid, .metadata.managedFields, .status)' -i "$export_file"
  done
done