Help()
{
   # Display Help
   echo "This function will export clean yaml out of Openshift to be consumed by ArgoCD"
   echo
   echo "Syntax: export.sh [-h|n|c|r|d]"
   echo "options:"
   echo "h     Print this Help."
   echo "n     Specify the namespace to export from"
   echo "c     Add additional Clean up elements in the Yaml"
   echo "r     Add additional Resource Types(resource included are deployments,services,configmaps,secrets,pods, androutes)"
   echo "d     echos all commands being run. "

   echo
}


# Get the options
while getopts ":hn:c:d" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      n) # Specify the namespace to export from
         NAMESPACEARG="-n '$OPTARG'";;
      c) # Specify the namespace to export from
         ADDITIONAL_FIELDS=$OPTARG;;
      d) #debug statements
         set -x;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

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
