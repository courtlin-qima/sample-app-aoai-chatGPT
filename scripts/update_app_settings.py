"""
Before run the sample, please set the values of the client ID, tenant ID and client secret
of the AAD application as environment variables: AZURE_CLIENT_ID, AZURE_TENANT_ID,
AZURE_CLIENT_SECRET. For more info about how to get the value, please see:
https://docs.microsoft.com/azure/active-directory/develop/howto-create-service-principal-portal
"""

import json
import os
import re
import subprocess

from azure.identity import DefaultAzureCredential
from azure.mgmt.web import WebSiteManagementClient


def main():
    # Load env var defined in the .env file associated to the currently selected azd env
    env_vars = load_env_values()

    # Define the list of env vars to upload / put in the env of the backend webapp service
    needed_env_var_names = set(load_needed_env_var_names())
    to_upload_env_vars = {
        k: v
        for k, v in env_vars.items()
        if k in needed_env_var_names and v
    }
    
    # Create client for interacting with the webapp service
    subscription_id = env_vars["AZURE_SUBSCRIPTION_ID"]
    resource_group_name = env_vars["AZURE_RESOURCE_GROUP"]
    web_app_service_name = env_vars["BACKEND_SERVICE_NAME"]
    client = WebSiteManagementClient(
        credential=DefaultAzureCredential(),
        subscription_id=subscription_id,
    )

    # Upload the desired env vars
    # WARNING: The 'update' in question works by overwritting all the app settings,
    # so we need to fetch the current ones first, in order not to remove any by mistake
    existing_app_settings = client.web_apps.list_application_settings(
        resource_group_name=resource_group_name,
        name=web_app_service_name,
    )
    updated_app_settings = {
        k: getattr(existing_app_settings, k)
        for k in ["id", "name", "kind", "type", "properties"]
    }
    updated_app_settings["properties"].update(to_upload_env_vars)
    client.web_apps.update_application_settings(
        resource_group_name=resource_group_name,
        name=web_app_service_name,
        app_settings=updated_app_settings,
    )

    # Restart the webapp service
    response = client.web_apps.restart(
        resource_group_name=resource_group_name,
        name=web_app_service_name,
        synchronous=True,
    )


def load_env_values():
    args = ["azd", "env", "get-values"]
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    out, err = process.communicate()
    out_content = out.decode("utf-8")
    err_content  = err.decode("utf-8")
    if process.returncode > 0:
        raise ValueError(
            f"Subprocess did not exit normally:\nstdout = {out_content};\nstderr "
            f"= {err_content}"
        )
    return {
        k.strip(): re.sub(r"['\"]", "", v.strip())
        for k, v in (
            line.split("=")[:2]
            for line in out_content.strip().split("\n")
            if line
        )
    }


def load_needed_env_var_names():
    file_path = os.path.join(os.path.dirname(__file__), "needed_app_settings.json")
    with open(file_path, "r", encoding="utf-8") as f:
        return list(json.load(f))


if __name__ == "__main__":
    main()