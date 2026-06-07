#!/usr/bin/env bash
set -euo pipefail
DEMO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Guard: verify all three source repos exist before doing any work
for repo in fee-engine fee-engine-ai-assistant fee-engine-admin-ui; do
  if [[ ! -d "$DEMO_DIR/../$repo" ]]; then
    echo "ERROR: sibling repo '$repo' not found at $DEMO_DIR/../$repo" >&2
    echo "Clone all three source repos at the same parent level as fee-engine-demo." >&2
    exit 1
  fi
done

echo "Building fee-engine JAR..."
cd "$DEMO_DIR/../fee-engine"
mvn package -DskipTests -q
cp target/fee-engine-*.jar "$DEMO_DIR/services/fee-engine/fee-engine.jar"
echo "  -> services/fee-engine/fee-engine.jar"

echo "Building ai-assistant JAR..."
cd "$DEMO_DIR/../fee-engine-ai-assistant"
mvn package -DskipTests -q
cp target/fee-engine-ai-assistant-*.jar "$DEMO_DIR/services/ai-assistant/fee-engine-ai-assistant.jar"
echo "  -> services/ai-assistant/fee-engine-ai-assistant.jar"

echo "Building admin-ui dist..."
cd "$DEMO_DIR/../fee-engine-admin-ui"
VITE_KEYCLOAK_URL=http://localhost:8888/auth \
VITE_KEYCLOAK_REALM=pisp \
VITE_KEYCLOAK_CLIENT_ID=fee-engine-admin-ui \
npm run build
rm -rf "$DEMO_DIR/services/admin-ui/dist"
cp -r dist/ "$DEMO_DIR/services/admin-ui/dist/"
echo "  -> services/admin-ui/dist/"

echo ""
echo "Done. Run: docker compose up --build"
