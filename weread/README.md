# WeRead (微信读书) EPUB Import Guide: Footnotes and Table of Contents

This covers EPUBs you import yourself. Books sold in the WeRead store may use other, unpublished pipelines; what follows is the general approach, reverse-engineered by the community and verified on real devices.

## Footnotes: summary

- Standard **EPUB3** footnotes (`epub:type="noteref"` + `<aside epub:type="footnote">`) work reliably in Calibre and Apple Books, but **WeRead imports often don't show a popup**; the note is usually treated as a plain link.
- WeRead's own books typically use **image footnotes**: `img.qqreader-footnote`, with the full note text in the **`alt`** attribute. Imports that follow this pattern get a popup.

## Footnotes: HTML markup

```html
<img
  class="qqreader-footnote"
  src="Images/note.png"
  alt="[number] Full citation…"
/>
```

Key points:

1. The `class` must be `qqreader-footnote` (the client recognizes footnotes by it).
2. The popup content is read from **`alt`**, not from a link to an endnotes chapter.
3. `src` points to the book's "注" (note) icon; the path is relative to the XHTML file.
4. You can keep an endnotes list at the back of the book for continuous reading, but it is not used as the popup's data source.

## Footnotes: CSS example

```css
.qqreader-footnote {
  width: 0.9em;
  height: 0.9em;
  margin-left: 0.12em;
  margin-right: 0.08em;
  vertical-align: middle;
  display: inline;
  border: 0;
}
```

## The "注" (note) icon

![注 note icon](note-qqreader.png)

`note-qqreader.png` in this directory is a ready-made 128×128 icon that follows the spec below.

| Item | Spec |
| --- | --- |
| Shape | Perfect circle badge |
| Fill | `#D18647` (sampled from a native WeRead screenshot; an orange-amber / tea brown) |
| Text | White "注" |
| Font | **Serif Song typeface** (e.g. Noto Serif CJK; do not use a sans-serif Hei typeface) |
| Rendering | Draw at 2× and downscale for smoother edges |
| Display | About `0.9em` in CSS, `vertical-align: middle` |

Note: don't sample the color from a night-mode screenshot with a grey background. **Use the native orange-amber shown on a light background.**

## Differences from standard EPUB3 footnotes

| | WeRead image footnote | EPUB3 standard footnote |
| --- | --- | --- |
| Target | WeRead import popup | Calibre, Apple Books, etc. |
| Markup | `img.qqreader-footnote` + `alt` | Superscript + `noteref` |
| Where the note lives | In `alt` | `aside` in an endnotes chapter, with a back link |
| Interoperability | Popup not guaranteed in other readers | Popup not guaranteed in WeRead imports |

## Regenerating the icon (memo)

With Pillow and a serif CJK font: fill a circle with `#D18647`, center a white "注", transparent background. Replace the note icon resource inside the book and repackage; no HTML changes are needed.

## Footnote risk

`qqreader-footnote` is not a public spec and WeRead may stop supporting it. Treat it only as an optimization for imported books, not as an official API.

## Table of contents: which standard

- **Use an EPUB3 `nav.xhtml`** (`epub:type="toc"`). It works in WeRead imports in real-device testing.
- You can also write a **`toc.ncx`** with the same structure, for older readers that only understand NCX. Keep the two in sync.
- The package can be marked `version="3.0"`, with `properties="nav"` on the nav item in the manifest.
- The sidebar is **driven mainly by nav/ncx**, but WeRead also picks up **the HTML `<title>` of each XHTML file in the spine** (see "Duplicate entries `_1` / `_2`" below). It does not rely on nav alone and ignore file titles.
- Books sold in the store use a different interface (chapter UID / level / anchors) that has nothing to do with imported EPUBs.
- Public sources show **no** TOC-specific class equivalent to the footnote class.

## Table of contents: nesting depth

- **Match the original book**: use as many levels as the book has. There is no need to flatten to two or three levels (the earlier finding that "only two levels work" is obsolete).
- One caveat remains: when a parent and its first child are in the same file with adjacent anchors, the first section can be swallowed (see "split out a title page" below).

## Table of contents: first section in the same file gets swallowed

Symptom: when a chapter is expanded, the sidebar is **missing the first section right after the chapter heading**, even though the text is still there.

Likely cause: when the parent and its first child point to **the same XHTML file** with adjacent anchors, the sidebar folds the child away.

## Table of contents: the fix (split out a title page)

For every chapter that has sections under it:

1. Create a new title-page XHTML containing only the chapter heading (and any chapter intro).
2. Keep the original file's text starting from **the first section**.
3. Add the title page to the manifest in `content.opf`; in the **spine, place the title page immediately before the original file**.
4. In **`nav.xhtml` (and `toc.ncx`, if you keep one)**: point the parent at the **title page**; children still point to the section anchors in the original file. Keep both TOCs consistent.
5. If the book also has an HTML contents page, update that chapter's link to point to the title page too.

### `nav.xhtml` snippet

```html
<nav epub:type="toc" id="toc">
  <ol>
    <li>
      <a href="chapter-title-page.xhtml#chapter-anchor">Chapter title</a>
      <ol>
        <li><a href="original-file.xhtml#section-anchor">First section</a></li>
        <!-- remaining sections… -->
      </ol>
    </li>
  </ol>
</nav>
```

### NCX snippet (optional, for dual TOCs)

```xml
<navPoint playOrder="…">
  <navLabel><text>Chapter title</text></navLabel>
  <content src="chapter-title-page.xhtml#chapter-anchor"/>
  <navPoint playOrder="…">
    <navLabel><text>First section</text></navLabel>
    <content src="original-file.xhtml#section-anchor"/>
  </navPoint>
  <!-- remaining sections… -->
</navPoint>
```

## Table of contents: duplicate entries `_1` / `_2` / `(continued)` (seen on device)

Importing *The Wealth of Nations* produced sidebar entries such as `VII: Of Colonies_1`, `Editor’s Introduction_1`, `Endnotes 1–500_1`, or `… (continued)`.

### Causes

1. **Colliding `<title>`s**: two XHTML files in the spine have the same HTML `<title>` (e.g. both the title page and the body say `V: Of Bounties`), so WeRead appends `_1`, `_2` to tell them apart.
2. **Title page and body both marked as chapters**: after splitting out a title page, if the body wrapper still carries the same `id` and `role="doc-chapter"` / `epub:type="chapter"`, it is treated as a second chapter with the same name.
3. **Splitting files to avoid very long chapters**: after splitting one chapter into several XHTML files, if the continuation files' `<title>` is "original title" or "original title (continued)", WeRead pulls them into the TOC too. Leaving the continuation `<title>` empty helps, but WeRead may still split a very long single file on its own and label the parts `_1`.

### Practical options

| Approach | TOC result | Cost |
| --- | --- | --- |
| **Merge back into one file** (try this first) | Fewer `_1`/`_2`/`(continued)` entries caused by split files | Very long chapters may still be split automatically by WeRead |
| Split files, leave continuation `<title>` empty, and keep them out of nav | Sidebar shows only the single nav entry | WeRead may still name untitled files; check on a real device |
| Split files and give each part a **distinct** title in nav | You can jump into the middle of a chapter | Longer TOC; readers have to accept the new names |

Real sections (e.g. I / II / III under Colonies) should each go into nav with **distinct titles**. That is the book's actual structure, not continuation files.

### Checklist

- Keep non-empty `<title>`s in the spine unique where possible (if two chapters are both called `Introduction`, rename one to e.g. `Book II Introduction`).
- Only the title page carries the chapter id / `doc-chapter`; the body wrapper must not repeat the same id and chapter role.
- If continuation files must be split out: leave their `<title>` empty and don't write `(continued)`.
- After making changes, **delete the old book in WeRead before re-importing**.

## Packaging notes

- `mimetype` must be the **first** entry in the zip and stored uncompressed.
- After changing the TOC or footnotes, **delete the old book in WeRead before re-importing** to avoid a cached old TOC or old resources.
