#!/usr/bin/env bash
# build-fixtures.sh: build a sample project with a quick page and a rich page,
# for tests/render-test.mjs.
#
# Usage: bash tests/build-fixtures.sh OUT_DIR

OUT=${1:?usage: build-fixtures.sh OUT_DIR}
KIT=$(cd "$(dirname "$0")/.." && pwd)
S="$KIT/skills"
P="$OUT/project"
rm -rf "$P" && mkdir -p "$OUT" || exit 1

bash "$S/new-project/scripts/new-project.sh" --dir "$P" --name "Render test" \
  --description "Fixture for the render test" --backend Node22 --frontend React19 \
  --learning --solo --single > /dev/null || exit 1
mkdir -p "$P/docs/features"
cp "$KIT/tests/fixtures/feature-demo.md" "$P/docs/features/demo.md"
printf '| [features/demo.md](features/demo.md) | Demo | draft | 2026-10-18 |\n' >> "$P/docs/README.md"
bash "$S/deep-doc/scripts/md-to-html.sh" --project "$P" --all > /dev/null || exit 1

cp "$KIT/tests/fixtures/rich-demo.body.html" "$P/docs/visual/.rich-demo.body.html"
bash "$S/deep-doc/scripts/wrap-page.sh" --project "$P" --title "Rich page demo" \
  --meta "Every component of the page shell" --source docs/features/demo.md \
  --body "$P/docs/visual/.rich-demo.body.html" --out "$P/docs/visual/rich-demo.html" --remove-body > /dev/null || exit 1
echo "$P/docs/visual"
