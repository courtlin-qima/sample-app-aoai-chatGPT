 #!/bin/sh

. ./scripts/loadenv.sh

# Cf here for structure of embedding creation api url: https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#embeddings
EMBEDDING_ENDPOINT="$AZURE_OPENAI_ENDPOINT""openai/deployments/$AZURE_OPENAI_EMB_DEPLOYMENT/embeddings?api-version=2023-05-15"

echo 'Running "prepdocs.py"'
./.venv/bin/python ./scripts/prepdocs.py \
    --searchservice "$AZURE_SEARCH_SERVICE" \
    --index "$AZURE_SEARCH_INDEX" \
    --formrecognizerservice "$AZURE_FORMRECOGNIZER_SERVICE" \
    --tenantid "$AZURE_TENANT_ID" \
    --embeddingendpoint $EMBEDDING_ENDPOINT
