#!/bin/sh

# Specify in which folder documents are located, if the info has been provided.
# Else, use the default './data' value, which was implicitely used, up until now.
DOCUMENTS_FOLDER_PATH="./data";
if [ ! -z $1 ]; then
    DOCUMENTS_FOLDER_PATH=$1;
fi
echo "Will ingest document(s) location in '$DOCUMENTS_FOLDER_PATH'.";

# Load env variables
. ./scripts/loadenv.sh

# Cf here for structure of embedding creation api url: https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#embeddings
EMBEDDING_ENDPOINT="$AZURE_OPENAI_ENDPOINT""openai/deployments/$AZURE_OPENAI_EMB_DEPLOYMENT/embeddings?api-version=2023-05-15"

echo 'Running "prepdocs.py"'
./.venv/bin/python ./scripts/prepdocs.py \
    --searchservice "$AZURE_SEARCH_SERVICE" \
    --index "$AZURE_SEARCH_INDEX" \
    --formrecognizerservice "$AZURE_FORMRECOGNIZER_SERVICE" \
    --tenantid "$AZURE_TENANT_ID" \
    --embeddingendpoint $EMBEDDING_ENDPOINT \
    --documentsfolderpath $DOCUMENTS_FOLDER_PATH