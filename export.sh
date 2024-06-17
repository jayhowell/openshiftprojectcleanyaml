types=("deployments" "services" "configmaps" "secrets" "pods" "routes")

# Create a directory to store the YAML files
mkdir -p exporttest

# Loop through each resource type and export the YAML
for type in "${types[@]}"; do
  echo "Exporting ${type}..."
  resources="$(oc get $type -o custom-columns=DEP:.metadata.name --no-headers)"
  IFS=$'\n' resources1=($resources)
  echo "resources are $resources1"
  for resource in "${resources1[@]}"; do
    mkdir -p "exporttest/$type"
    export_file="exporttest/$type/${resource}.yaml"
    echo "-------exporting name $resource to $export_file"
    
    oc get "$type" "$resource" -o yaml > "exporttest/$type/${resource}.yaml"
    yq eval 'del(.metadata.creationTimestamp, .metadata.generation, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid, .metadata.managedFields, .status)' -i "$export_file"
  done
done
