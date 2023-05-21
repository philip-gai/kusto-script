# kusto-script

[![Tests](https://github.com/philip-gai/kusto-script/actions/workflows/tests.yaml/badge.svg)](https://github.com/philip-gai/kusto-script/actions/workflows/tests.yaml)

Run a Kusto script or inline query against your [Azure Data Explorer](https://learn.microsoft.com/en-us/azure/data-explorer/data-explorer-overview) cluster in your GitHub Actions workflow.

## Usage

First, authenticate with Azure using `Azure/login` and setup the Kusto CLI using [`philip-gai/setup-kusto`](https://github.com/philip-gai/setup-kusto). Then you can run an inline query or a a Kusto script using `philip-gai/kusto-script`. If you are running a script, make sure to run `actions/checkout` before `philip-gai/kusto-script` so your script is accessible by the action. You can also deploy functions and views by passing in `kusto-script-folders`.

```yaml
    steps:
      - uses: actions/checkout@v3.5.2 # If running a Kusto script
      - uses: Azure/login@v1 # Use OIDC if possible
        with:
          client-id: ${{ env.AZURE_CLIENT_ID }} # Value from Azure AAD
          tenant-id: ${{ env.AZURE_TENANT_ID }} # Value from Azure AAD
          allow-no-subscriptions: true
      - uses: philip-gai/setup-kusto@v1
      - name: Run inline query
        uses: philip-gai/kusto-script@main # Replace @main with @tag
        with:
          kusto-uri: ${{ env.KUSTO_URI }} # Example: https://mycluster.kusto.windows.net or https://mycluster.kusto.windows.net/MyDatabase
          kusto-query: ".show databases"
      - name: Run a single Kusto script
        uses: philip-gai/kusto-script@main # Replace @main with @tag
        with:
          kusto-uri: ${{ env.KUSTO_URI }} # Example: https://mycluster.kusto.windows.net or https://mycluster.kusto.windows.net/MyDatabase
          kusto-script: "kusto-scripts/show-commands.kql" # Relative to the repository root
      - name: Deploy functions and views
        uses: philip-gai/kusto-script@main # Replace @main with @tag
        with:
          kusto-uri: ${{ env.KUSTO_URI }} # Example: https://mycluster.kusto.windows.net or https://mycluster.kusto.windows.net/MyDatabase
          kusto-script-folders: "kusto-scripts/functions kusto-scripts/views" # Relative to the repository root. Space separated list of folders.
```
