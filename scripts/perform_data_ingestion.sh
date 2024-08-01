 #!/bin/sh

. ./scripts/loadenv.sh

echo 'Running "auth_update.py"'
./.venv/bin/python ./scripts/auth_update.py \
    --appid "$AUTH_APP_ID" \
    --uri "$BACKEND_URI"

echo 'Running "prepdocs.py"'
./.venv/bin/python ./scripts/prepdocs.py \
    --searchservice "$AZURE_SEARCH_SERVICE" \
    --index "$AZURE_SEARCH_INDEX" \
    --formrecognizerservice "$AZURE_FORMRECOGNIZER_SERVICE" \
    --tenantid "$AZURE_TENANT_ID" \
    --embeddingendpoint "$AZURE_OPENAI_EMBEDDING_ENDPOINT"
