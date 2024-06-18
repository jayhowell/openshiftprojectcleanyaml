ADDITIONAL_FIELDS=$1
if [ $# -eq 1 ]
then
        ADDITIONAL_FIELDS=$1", "
fi

types=("deployments" "services" "configmaps" "secrets" "pods" "routes")

# Create a directory to store the YAML files
mkdir -p export

# Loop through each resource type and export the YAML
for type in "${types[@]}"; do
  echo "Exporting ${type}..."
  #get all the resources that are in each type listed in the types array
  resources="$(oc get $type -o custom-columns=DEP:.metadata.name --no-headers)"
  #Tokenize on the eol character
  IFS=$'\n' resources1=($resources)
  #make the type root directory
  mkdir -p "export/$type"
  #Loop through all of the resources we've tokenized 
  for resource in "${resources1[@]}"; do
    export_file="export/$type/${resource}.yaml"
    echo "-------exporting name $resource to $export_file"
    #get the yaml for the resource itself
    oc get "$type" "$resource" -o yaml > "export/$type/${resource}.yaml"
    #use yq to get rid of all of the runtime information
    yq eval 'del('$ADDITIONAL_FIELDS'.metadata.creationTimestamp, .metadata.generation, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid, .metadata.managedFields, .status)' -i "$export_file"
  done
done
