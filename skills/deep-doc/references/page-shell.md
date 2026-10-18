# Page shell: components

`assets/page-shell.html` is one self-contained page: styles and scripts inline, light and dark mode following the system setting, and a contents sidebar built from the `h2` and `h3` headings. Libraries load from jsDelivr only when the page needs them, pinned to exact versions with SRI hashes: Mermaid 11.4.1 (diagrams), Chart.js 4.4.7 (charts), and for quick pages marked 18.0.14 (Markdown) with DOMPurify 3.4.16 (sanitising). Offline, diagrams show their source, charts show their data table, and quick pages show the raw Markdown.

`<skill-dir>` below is the deep-doc skill's base directory.

## Two kinds of page

| | Quick page | Rich page |
|---|---|---|
| Made by | `scripts/md-to-html.sh` | Claude writes a body fragment; `scripts/wrap-page.sh` wraps it |
| Token cost | almost none | the whole page body |
| Content | the Markdown, rendered in the browser | hand-built HTML with every component below |
| When | default, and `--all` for a whole site | only when the user asks for one |

Both land in `docs/visual/`, record their Markdown source (so `check-project.sh` can report outdated pages), and are never edited by hand.

## Markdown features in quick pages

Quick pages render GitHub-flavoured Markdown, plus:

- ` ```mermaid ` blocks become diagrams.
- ` ```chart ` blocks holding the JSON config described under **Charts** become interactive charts (with a data table).
- GitHub alerts become callouts: `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`.
- Links to other `.md` docs point at their generated pages; other relative links point at the files themselves.

Tabs, step-throughs and tiles exist only in rich pages.

## How to build a rich page

1. Write the **body only** (no `<html>`, `<head>`, `<body>`, `<h1>`) to `docs/visual/.<page>.body.html`.
2. Wrap it:

   ```bash
   bash "<skill-dir>/scripts/wrap-page.sh" --title "Page title" \
     --meta "One line: type · date · source" --source docs/<source>.md \
     --body docs/visual/.<page>.body.html --out docs/visual/<page>.html --remove-body
   ```

   The script fills in the title (as `<title>` and `<h1>`) and the meta line, records the source, inserts the fragment, and removes the fragment file. Never paste or edit the shell by hand.
3. Open the result in a browser if you can, and check it.

## Headings

Use `<h2>` for sections and `<h3>` for subsections; the sidebar is built from them. Headings inside tabs and step-throughs are left out of the sidebar.

## Lead paragraph

```html
<p class="lead">The answer or the summary, in two or three sentences.</p>
```

## Callouts

Types: `note` (default), `tip`, `warning`, `danger`.

```html
<aside class="callout warning">
  <p class="callout-title">Watch out</p>
  <p>Tokens expire after 15 minutes, so long uploads must refresh first.</p>
</aside>
```

## Mermaid diagrams

Escape `<`, `>` and `&` inside the diagram as `&lt;`, `&gt;` and `&amp;`.

```html
<pre class="mermaid">
flowchart LR
  B[Browser] -->|POST /login| A[API]
  A -->|checks password| D[(Users DB)]
</pre>
```

## Charts (Chart.js, from a small JSON config)

```html
<figure class="chart">
  <script type="application/json">
  {
    "type": "bar",
    "title": "Monthly cost by option",
    "labels": ["Option A", "Option B", "Option C"],
    "series": [{ "name": "Cost", "data": [120, 340, 90] }],
    "prefix": "$",
    "suffix": "/mo"
  }
  </script>
  <figcaption>Cost at 10,000 users, from the vendors' pricing pages [2][3].</figcaption>
</figure>
```

| Key | Meaning |
|---|---|
| `type` | `bar`, `line`, `pie` or `doughnut` |
| `labels` | category labels (x axis, or slices) |
| `series` | `[{ "name": …, "data": [numbers] }]`; one series for pie/doughnut; at most 8 |
| `title` | optional chart title |
| `prefix`, `suffix` | optional value formatting: `"$"`, `"%"`, `" ms"` |
| `horizontal` | `true` for horizontal bars (long labels) |
| `stacked` | `true` to stack series |
| `beginAtZero` | default `true`; set `false` only for line charts where zero is meaningless |
| `valueTitle`, `categoryTitle` | optional axis titles |
| `height` | optional height in px (default 320) |
| `chartjs` | escape hatch: a full Chart.js config used as is (no theme colours) |

Colours come from the fixed series palette, in order, and switch with light and dark mode. Every chart gets a "Data table" view automatically. One measure per chart: never two y-axes. If you have two measures, make two charts.

## Tabs

For alternatives side by side (options, platforms, before and after).

```html
<div class="tabs">
  <section data-tab="Option A"><p>…</p></section>
  <section data-tab="Option B"><p>…</p></section>
</div>
```

## Collapsible sections

```html
<details>
  <summary>Full error list</summary>
  <p>…</p>
</details>
```

## Step-through (processes, with Previous and Next buttons)

```html
<div class="steps">
  <section data-step="The user submits the form"><p>…</p></section>
  <section data-step="The API checks the password"><p>…</p></section>
  <section data-step="A session token is returned"><p>…</p></section>
</div>
```

## Headline number tiles

```html
<div class="tiles">
  <div class="tile"><div class="tile-value">42%</div><div class="tile-label">Faster checkout</div><div class="tile-note">vs. March</div></div>
  <div class="tile"><div class="tile-value">3</div><div class="tile-label">Open risks</div></div>
</div>
```

## Status badges

Classes: `good`, `warn`, `bad`, `info`, plain `badge` for neutral. The text carries the meaning; the colour only supports it.

```html
<span class="badge good">On track</span>
<span class="badge warn">At risk</span>
<span class="badge bad">Blocked</span>
<span class="badge info">In progress</span>
<span class="badge">Not started</span>
```

## Tables

Plain `<table>` with `<thead>`. They are wrapped automatically so they scroll sideways on phones. Add `class="num"` to numeric cells to right-align them.

## Sources

Cite inline with `<a class="cite" href="#s1">[1]</a>`. List the sources at the end:

```html
<h2>Sources</h2>
<ol class="sources">
  <li id="s1"><a href="https://example.com/pricing">Pricing</a>. Example Inc., accessed 2026-10-18.</li>
</ol>
```
