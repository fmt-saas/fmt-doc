#!/bin/sh

set -e

ROOT="$(pwd)"
TMP=".tmp"
DOCS="$ROOT/docs"

echo "== Clean =="
rm -rf "$TMP"
mkdir -p "$TMP"
rm -rf "$DOCS"
mkdir -p "$DOCS"

echo "== Parse sources.yml =="

COUNT=$(yq '.sources | length' sources.yml)

NAV_FILE="$TMP/nav.yml"
echo "nav:" > "$NAV_FILE"

i=0
while [ "$i" -lt "$COUNT" ]; do

  NAME=$(yq ".sources[$i].name" sources.yml | tr -d '"')
  REPO=$(yq ".sources[$i].repo" sources.yml | tr -d '"')
  BRANCH=$(yq ".sources[$i].branch" sources.yml | tr -d '"')
  PATH_SRC=$(yq ".sources[$i].path" sources.yml | tr -d '"')
  TARGET=$(yq ".sources[$i].target" sources.yml | tr -d '"')

  echo "→ $NAME"

  CLONE_DIR="$TMP/$i"

  git clone --depth 1 --branch "$BRANCH" "$REPO" "$CLONE_DIR"

  SRC_PATH="$CLONE_DIR/$PATH_SRC"

  # Gestion target = "."
  if [ "$TARGET" = "." ]; then
    DEST_PATH="$DOCS"
    NAV_PREFIX=""
  else
    DEST_PATH="$DOCS/$TARGET"
    NAV_PREFIX="$TARGET/"
  fi

  mkdir -p "$DEST_PATH"

  # Copie robuste (support dossier vide)
  if [ -d "$SRC_PATH" ]; then
    cp -r "$SRC_PATH/." "$DEST_PATH/"
  else
    echo "️Error - Missing path: $SRC_PATH"
	i=$((i + 1))
    continue
  fi

  # NAV
  if [ -f "$DEST_PATH/nav.yml" ]; then
    echo "  - $NAME:" >> "$NAV_FILE"

    # Si root → pas de préfixe
    if [ "$TARGET" = "." ]; then
      sed 's/^/    /' "$DEST_PATH/nav.yml" >> "$NAV_FILE"
    else
      # préfixer les chemins
      sed "s|: |: $NAV_PREFIX|g" "$DEST_PATH/nav.yml" | sed 's/^/    /' >> "$NAV_FILE"
    fi

  else
    echo "  - $NAME:" >> "$NAV_FILE"

    if [ "$TARGET" = "." ]; then
      echo "    - Home: index.md" >> "$NAV_FILE"
    else
      echo "    - Home: $TARGET/index.md" >> "$NAV_FILE"
    fi
  fi

  i=$((i + 1))

done

echo "== Inject nav into mkdocs.yml =="

awk '
  BEGIN {skip=0}
  /^nav:/ {skip=1; next}
  skip && /^[^ ]/ {skip=0}
  !skip {print}
' mkdocs.yml > "$TMP/mkdocs.clean.yml"

cat "$TMP/mkdocs.clean.yml" > mkdocs.yml
echo "" >> mkdocs.yml
cat "$NAV_FILE" >> mkdocs.yml

echo "== Done =="