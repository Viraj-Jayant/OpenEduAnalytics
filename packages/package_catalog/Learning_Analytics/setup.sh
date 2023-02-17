#!/bin/bash

# Installs the Microsoft Graph module
# This script can be invoked directly to install the Insights module assets into an existing Synapse Workspace.
if [ $# -ne 1 ]; then
    echo "This setup script will install the Learning Analytics Package assets into an existing Synapse workspace."
    echo "Invoke this script like this:  "
    echo "    setup.sh <synapse_workspace_name>"
    exit 1
fi

synapse_workspace=$1
this_file_path=$(dirname $(realpath $0))

echo "--> Setting up the Microsoft Graph module assets."

# 1) install notebooks
eval "az synapse notebook import --workspace-name $synapse_workspace --name LA_build_dimension_tables --spark-pool-name spark3p2med --file @$this_file_path/notebooks/LA_build_dimension_tables.ipynb --only-show-errors"
eval "az synapse notebook import --workspace-name $synapse_workspace --name LA_build_fact_tables --spark-pool-name spark3p2med --file @$this_file_path/notebooks/LA_build_fact_tables.ipynb --only-show-errors"

# 2) setup pipelines
# Note that the ordering below matters because pipelines that are referred to by other pipelines must be created first.


eval "az synapse pipeline create --workspace-name $synapse_workspace --name 1_build_LA_dim_tables --file @$this_file_path/pipeline/1_build_LA_dim_tables.json"
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 2_build_LA_fact_tables --file @$this_file_path/pipeline/2_build_LA_fact_tables.json"
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 0_main_LA_package --file @$this_file_path/pipeline/0_main_LA_package.json"

echo "--> Setup complete. The Learning Analystics package assets have been installed in the specified synapse workspace: $synapse_workspace"