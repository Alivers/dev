# Importing EPUBs into WeRead (微信读书): Footnotes and TOC

**Date**: 2026-10-30 · **Scope**: EPUBs you import yourself. Books sold in the WeRead store go through a different, unpublished pipeline (chapter UIDs, levels, anchors) and none of this applies to them.

WeRead's import path is undocumented. Everything below comes from community reverse engineering plus on-device testing. Statements marked *(EPUB spec)* are standard EPUB requirements. WeRead can change behavior in any client update, so re-test after upgrading.

## Quick checklist

Footnotes:

- [ ] Each footnote is an `<img class="qqreader-footnote">` whose `alt` holds the full note text, wrapped in an EPUB3 noteref link to an `aside` with the same text.
- [ ] The 注 icon is in the book and listed in the manifest.

Table of contents:

- [ ] `nav.xhtml` is the TOC (optionally mirrored in `toc.ncx`), and its depth matches the book.
- [ ] Every chapter with subsections has its own title-page file, and the nav parent points to it.
- [ ] No two spine files share a non-empty `<title>`, and only the title page carries the chapter role.

Packaging:

- [ ] `mimetype` is the first zip entry, stored uncompressed, and the book passes `epubcheck`.
- [ ] Delete the old copy in WeRead before importing the new one.

## 1. Footnotes

### Why WeRead needs an image footnote

| | WeRead image footnote | EPUB3 standard footnote |
| --- | --- | --- |
| Works in | WeRead imports | Calibre, Apple Books, most other readers |
| Markup | `<img class="qqreader-footnote" alt="…">` | `<a epub:type="noteref">` + `<aside epub:type="footnote">` |
| Note text lives in | The `alt` attribute | An `aside` (usually in an endnotes file), with a back link |

WeRead's own store books use image footnotes, and the import client recognizes them by the class on the image. A plain EPUB3 noteref in an imported book usually behaves as an ordinary link, with no popup.

### Markup that works in both

Put the WeRead image *inside* an EPUB3 noteref link. WeRead finds the image by its class and shows the `alt` text; other readers follow the noteref to the `aside`.

```html
<!-- chapter file -->
<p>…the division of labour.<a epub:type="noteref" role="doc-noteref" class="noteref-img" id="ref-12" href="notes.xhtml#note-12"><img class="qqreader-footnote" src="../Images/note-en.png" alt="[12] Smith, Wealth of Nations, Book I, ch. 1."/></a></p>

<!-- notes.xhtml -->
<aside epub:type="footnote" role="doc-footnote" id="note-12">
  <p><a href="ch01.xhtml#ref-12" role="doc-backlink">↩</a> [12] Smith, <i>Wealth of Nations</i>, Book I, ch. 1.</p>
</aside>
```

Tested 2026-10-30 by converting all 287 notes in *The Almanack of Naval Ravikant*:

| Reader | Tapping the icon |
| --- | --- |
| WeRead | Popup with the `alt` text |
| Apple Books | Popup with the `aside`; the ↩ back link shows inside it |
| Calibre, Kindle | Not tested |

Also tested and rejected: the bare image followed by a separate superscript link (`<img …/><sup><a epub:type="noteref">12</a></sup>`). It works in WeRead, but readers see two markers, and in Apple Books tapping the bare icon opens the image viewer.

For a WeRead-only book, the bare `<img class="qqreader-footnote" …/>` without the link is enough.

### Rules for the image

- The class must be exactly `qqreader-footnote`.
- WeRead's popup shows the `alt` text and never reads the `aside`, so the note text exists twice. Generate both from one source so they can't drift apart.
- Put the image right after the word or sentence it annotates, with no space before it.
- `src` is relative to the XHTML file, and the image must be listed in the `content.opf` manifest *(EPUB spec)*:

```xml
<item id="note-icon" href="Images/note-en.png" media-type="image/png"/>
```

```css
/* Sits slightly up and to the right of the word, like a superscript but not as small. */
.qqreader-footnote {
  width: 0.85em;
  height: 0.85em;
  margin: 0 0.08em 0 0.04em;
  vertical-align: -0.02em;
  border: 0;
}
/* Books often style noterefs as small superscript, which would shrink the
   0.9em icon with them. Reset it on the wrapping link. */
a.noteref-img {
  font-size: 1em;
  vertical-align: baseline;
  text-decoration: none;
  border: 0;
}
```

If the book's own noteref class sets `font-size` with a more specific selector, match it (e.g. `a.scribe_footnote-ref.noteref-img`).

### Writing the `alt` text

`alt` is a plain attribute string, which has some consequences:

- No formatting: italics, links and line breaks are lost. Write citations so they read fine as plain text.
- Escape `&`, `<` and `"` as `&amp;`, `&lt;` and `&quot;`, or the XHTML is invalid and the whole file may fail to load.
- Screen readers read `alt` aloud inline, so very long notes make the text hard to listen to. That is the cost of this approach.

### The 注 icon

![注 note icon](note-qqreader.png)

[`note-qqreader.png`](note-qqreader.png) in this directory is a ready-made 128×128 icon that matches the spec below.

| Item | Spec |
| --- | --- |
| Shape | Filled circle, transparent background |
| Fill | `#D18647` (orange-amber, sampled from WeRead's native icon on a light background; don't sample from night mode, which is grey) |
| Glyph | White 注 in a **serif (Song/Ming) face** such as Noto Serif CJK, not a sans-serif Hei face |
| Rendering | Draw at 2× and downscale for smooth edges |

To regenerate it, draw the circle and glyph with Pillow and a serif CJK font, then replace the image file in the book and repackage. The HTML does not change.

For English books, [`note-en.png`](note-en.png) ![n note icon](note-en.png) is the same badge with a white lowercase "n" (for *note*) in Liberation Serif Regular, a metric-compatible stand-in for Times New Roman, drawn at 2× (256 px) and downscaled to 128 px.

### Caveats

- `qqreader-footnote` is not a public spec. Treat it as an optimization for WeRead that may stop working; the EPUB3 noteref around it keeps other readers working either way.
- Only WeRead and Apple Books have been tested on a device.

## 2. Table of contents

### Format

Use an EPUB3 `nav.xhtml` (`<nav epub:type="toc">`); WeRead imports read it correctly. For older readers that only understand NCX, you can also ship a `toc.ncx` with the same structure, and you have to keep the two in sync by hand.

Required wiring *(EPUB spec)*: `<package version="3.0">`, the nav item in the manifest has `properties="nav"`, and if you ship an NCX the spine names its manifest id, e.g. `<spine toc="ncx">`.

Match the book's real nesting depth. The earlier finding that WeRead only shows two levels is obsolete; a three-level nav (part, chapter, section) with title-page splits displayed correctly in WeRead on 2026-10-30.

### How WeRead builds the sidebar

Two inputs matter, and most TOC bugs come from forgetting the second:

1. **The nav (or NCX) tree** sets the structure.
2. **The HTML `<title>` of every spine file** is scanned too. A file with a non-empty `<title>` that isn't in the nav can still show up as an entry, and two files with the same `<title>` get suffixed `_1`, `_2` to tell them apart.

There is no TOC-specific class like the footnote one.

### Problem: the first subsection disappears

**Symptom**: when you expand a chapter in the sidebar, its first subsection is missing, even though the text is in the book.

**Likely cause**: the chapter and its first subsection point into the same XHTML file at adjacent anchors, and the sidebar folds the child into the parent.

**Fix: give each chapter its own title page.** For every chapter that has subsections:

1. Create a title-page XHTML holding only the chapter heading (and any chapter intro). Give it the chapter's `<title>`, the chapter `id`, and the chapter role (`epub:type="chapter"` / `role="doc-chapter"`).
2. Trim the original file so it starts at the first subsection. Remove the chapter `id` and chapter role from its wrapper, and give it an **empty `<title>`** or one that is distinct from the chapter title. Otherwise you trade this bug for the duplicate-entry bug below.
3. In `content.opf`, add the title page to the manifest and put it in the spine **immediately before** the original file.
4. In `nav.xhtml` (and `toc.ncx`), point the chapter at the title page; the subsections keep pointing at their anchors in the original file.
5. If the book has an HTML contents page, point that chapter's link at the title page too.

```html
<nav epub:type="toc" id="toc">
  <ol>
    <li>
      <a href="ch05-title.xhtml">V: Of Bounties</a>
      <ol>
        <li><a href="ch05.xhtml#s1">First subsection</a></li>
        <!-- remaining subsections… -->
      </ol>
    </li>
  </ol>
</nav>
```

The NCX equivalent, if you ship one:

```xml
<navPoint id="ch05" playOrder="…">
  <navLabel><text>V: Of Bounties</text></navLabel>
  <content src="ch05-title.xhtml"/>
  <navPoint id="ch05-s1" playOrder="…">
    <navLabel><text>First subsection</text></navLabel>
    <content src="ch05.xhtml#s1"/>
  </navPoint>
</navPoint>
```

### Problem: duplicate entries (`_1`, `_2`, `(continued)`)

**Symptom** (seen importing *The Wealth of Nations*): sidebar entries like `VII: Of Colonies_1`, `Editor’s Introduction_1`, `Endnotes 1–500_1`, or `… (continued)`.

**Causes**, all versions of "two spine files look like the same chapter":

1. Two files share a `<title>`. The usual way this happens is a title-page split where both files kept the chapter title (see step 2 above).
2. After a split, the body file still carries the chapter `id` and chapter role, so it is treated as a second chapter.
3. A long chapter was split into continuation files whose `<title>` repeats the chapter title or adds `(continued)`, so WeRead lists them as entries.

The first two are fixed by doing the title-page split as described above. For continuation files, pick one:

| Approach | Sidebar result | Cost |
| --- | --- | --- |
| **Merge continuations back into one file** (try first) | No extra entries from splitting | WeRead may still auto-split a very long file and label the parts `_1` |
| Keep the split; give continuation files an empty `<title>` and leave them out of the nav | Only the nav entry shows | WeRead may still name untitled files; check on a device |
| Keep the split and give each part its own distinct nav entry | Readers can jump to mid-chapter | Longer TOC with invented part names |

This is only about continuation files. Real subsections (e.g. I, II, III under *Of Colonies*) belong in the nav, each with its own title. If two genuinely different chapters share a name (two `Introduction`s), rename one, e.g. `Book II Introduction`.

## 3. Packaging and re-importing

The `mimetype` file must be the first entry in the zip, stored uncompressed, and contain exactly `application/epub+zip` with no trailing newline *(EPUB spec)*. From the unpacked book's root:

```sh
rm -f ../book.epub
zip -X0 ../book.epub mimetype
zip -Xr9D ../book.epub META-INF OEBPS   # adjust to your content folder name
epubcheck ../book.epub
```

`epubcheck` catches broken `alt` escaping, missing manifest items and nav wiring errors before WeRead does, and WeRead's own failure modes are much harder to diagnose.

WeRead caches the TOC and resources of an imported book. After any change, **delete the old copy in WeRead first, then import**, or you may be testing the old version.
