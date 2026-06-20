(function () {
  "use strict";

  var THEMES = ["light", "dark", "auto"];
  var themeButton = document.querySelector(".theme-toggle");
  var storedTheme = localStorage.getItem("theme") || "auto";

  function resolvedTheme(mode) {
    if (mode === "auto") {
      return matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    return mode;
  }

  function applyTheme(mode) {
    storedTheme = mode;
    localStorage.setItem("theme", mode);
    document.documentElement.dataset.theme = resolvedTheme(mode);
    if (themeButton) {
      themeButton.title = "Theme: " + mode.charAt(0).toUpperCase() + mode.slice(1);
      themeButton.setAttribute("aria-label", themeButton.title);
    }
  }

  if (themeButton) {
    themeButton.addEventListener("click", function () {
      var next = THEMES[(THEMES.indexOf(storedTheme) + 1) % THEMES.length];
      applyTheme(next);
    });
  }

  matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function () {
    if (storedTheme === "auto") {
      document.documentElement.dataset.theme = resolvedTheme("auto");
    }
  });

  applyTheme(storedTheme);

  var left = document.querySelector(".sidebar-left");
  var right = document.querySelector(".sidebar-right");
  var backdrop = document.getElementById("sidebar-backdrop");
  var leftToggle = document.getElementById("sidebar-toggle-left");
  var rightToggle = document.getElementById("sidebar-toggle-right");

  function closeSidebars() {
    if (left) left.classList.remove("open");
    if (right) right.classList.remove("open");
    if (backdrop) backdrop.classList.remove("visible");
  }

  function toggleSidebar(sidebar) {
    var shouldOpen = sidebar && !sidebar.classList.contains("open");
    closeSidebars();
    if (shouldOpen) {
      sidebar.classList.add("open");
      if (backdrop) backdrop.classList.add("visible");
    }
  }

  if (leftToggle && left) leftToggle.addEventListener("click", function () { toggleSidebar(left); });
  if (rightToggle && right) rightToggle.addEventListener("click", function () { toggleSidebar(right); });
  if (backdrop) backdrop.addEventListener("click", closeSidebars);

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") closeSidebars();
  });

  function fillTheoremLeaders() {
    var ruler = document.createElement("span");
    ruler.style.cssText = "position:absolute;visibility:hidden;font-family:var(--mono);white-space:nowrap;";
    ruler.textContent = "..........";
    document.body.appendChild(ruler);
    var dotWidth = Math.max(1, ruler.getBoundingClientRect().width / 10);
    ruler.remove();

    document.querySelectorAll(".theorem-list-entry").forEach(function (entry) {
      var dots = entry.querySelector(".theorem-list-dots");
      var marker = entry.querySelector(".theorem-list-end");
      var page = entry.querySelector(".theorem-list-page");
      var pageLink = page && page.closest("a");
      if (!dots || !marker || !pageLink) return;

      dots.textContent = "";
      var entryRect = entry.getBoundingClientRect();
      var markerRect = marker.getBoundingClientRect();
      var pageWidth = pageLink.getBoundingClientRect().width;
      var remaining = entryRect.right - markerRect.right - pageWidth - 10;
      var count = Math.floor(Math.max(0, remaining) / dotWidth);
      dots.textContent = count >= 2 ? ".".repeat(count) : "";
    });
  }

  function normalizeDisplayMath() {
    document.querySelectorAll('math[display="block"]').forEach(function (math) {
      var wrapper = math.closest(".display-math");
      if (!wrapper && math.parentNode) {
        wrapper = document.createElement("div");
        wrapper.className = "display-math";
        math.parentNode.insertBefore(wrapper, math);
        wrapper.appendChild(math);
      }

      if (!wrapper) return;

      var tag = math.querySelector(".tag, .equation-tag");
      if (tag) {
        tag.classList.add("equation-tag");
        wrapper.appendChild(tag);
      }
    });
  }

  function tocDepthForHeading(heading) {
    var level = Number(heading.tagName.slice(1));
    return Math.max(0, level - 2);
  }

  function nearestHeadingDepth(node) {
    var depth = 1;
    var cursor = node.previousElementSibling;
    while (cursor) {
      if (/^H[2-6]$/.test(cursor.tagName)) {
        return tocDepthForHeading(cursor) + 1;
      }
      cursor = cursor.previousElementSibling;
    }
    return depth;
  }

  function buildLocalToc() {
    var nav = document.querySelector(".local-toc");
    var main = document.querySelector("main.content");
    if (!nav || !main) return;

    var ul = nav.querySelector("ul");
    var muted = nav.querySelector(".muted");
    if (!ul) {
      ul = document.createElement("ul");
      nav.appendChild(ul);
    }

    ul.textContent = "";
    main.querySelectorAll("h2[id],h3[id],h4[id],h5[id],h6[id],.thm-box[id]").forEach(function (node) {
      var link = document.createElement("a");
      link.href = "#" + node.id;

      var li = document.createElement("li");
      if (node.classList.contains("thm-box")) {
        var head = node.querySelector(".thm-head");
        if (!head) return;
        li.className = "toc-theorem";
        li.style.setProperty("--toc-depth", nearestHeadingDepth(node));
        link.textContent = head.textContent.trim().replace(/\.$/, "");
      } else {
        li.className = "toc-heading";
        li.style.setProperty("--toc-depth", tocDepthForHeading(node));
        link.innerHTML = "§" + node.innerHTML;
      }

      li.appendChild(link);
      ul.appendChild(li);
    });

    if (muted) {
      muted.hidden = ul.children.length > 0;
    }
  }

  function relativeHref(url) {
    return new URL(url, location.href).pathname + new URL(url, location.href).hash;
  }

  function normalizedPath(url) {
    var path = new URL(url, location.href).pathname;
    if (path.endsWith("/index.html")) {
      path = path.slice(0, -"index.html".length);
    }
    if (!path.endsWith("/")) {
      path += "/";
    }
    return path;
  }

  function pdfDestByPath() {
    var map = {};
    var loc = 1;
    document.querySelectorAll(".global-nav a[href]").forEach(function (link) {
      var path = normalizedPath(link.getAttribute("href"));
      if (path === "/") return;
      map[path] = "loc-" + loc;
      loc += 1;
    });
    return map;
  }

  function rootHref(path) {
    var home = document.querySelector(".topbar-title");
    var base = home ? home.getAttribute("href").replace(/index\.html$/, "") : "/";
    return relativeHref(new URL(base + path, location.href).href);
  }

  function absoluteRootHref(path) {
    var home = document.querySelector(".topbar-title");
    var base = home ? home.getAttribute("href").replace(/index\.html$/, "") : "/";
    return new URL(base + path, location.href).href;
  }

  function pdfHref(dest, page) {
    var suffix = dest ? "#" + dest : page ? "#page=" + page : "";
    return rootHref("pdf/notes.pdf" + suffix);
  }

  function theoremEntry(title, href, pdfDest, pdfPage) {
    var entry = document.createElement("p");
    entry.className = "theorem-list-entry";

    var link = document.createElement("a");
    link.className = "theorem-list-link";
    link.href = href;
    var titleSpan = document.createElement("span");
    titleSpan.className = "theorem-list-title";
    titleSpan.textContent = title.replace(/\.$/, "");
    titleSpan.appendChild(document.createElement("span")).className = "theorem-list-end";
    link.appendChild(titleSpan);

    var dots = document.createElement("span");
    dots.className = "theorem-list-dots";

    var page = document.createElement("a");
    page.className = "theorem-list-pdf";
    page.href = pdfHref(pdfDest, pdfPage);
    page.setAttribute("aria-label", pdfPage ? "PDF page " + pdfPage : "PDF");
    var pageSpan = document.createElement("span");
    pageSpan.className = "theorem-list-page";
    pageSpan.textContent = pdfPage || "PDF";
    page.appendChild(pageSpan);

    entry.appendChild(link);
    entry.appendChild(dots);
    entry.appendChild(page);
    return entry;
  }

  function collectTheoremsFromDocument(doc, pageUrl) {
    return Array.from(doc.querySelectorAll(".thm-box[id]")).map(function (box) {
      var head = box.querySelector(".thm-head");
      if (!head) return null;
      var href = new URL("#" + box.id, pageUrl).href;
      return {
        href: relativeHref(href),
        pagePath: normalizedPath(pageUrl),
        title: head.textContent.trim()
      };
    }).filter(Boolean);
  }

  function navUrls() {
    return Array.from(document.querySelectorAll(".global-nav a[href]")).map(function (link) {
      return new URL(link.getAttribute("href"), location.href).href;
    }).filter(function (url, index, all) {
      return url.endsWith("/") && all.indexOf(url) === index;
    });
  }

  function loadHtmlTheorems() {
    var parser = new DOMParser();
    return Promise.all(navUrls().map(function (url) {
      if (url === location.href) {
        return Promise.resolve(collectTheoremsFromDocument(document, url));
      }
      return fetch(url)
        .then(function (response) { return response.ok ? response.text() : ""; })
        .then(function (html) {
          if (!html) return [];
          return collectTheoremsFromDocument(parser.parseFromString(html, "text/html"), url);
        })
        .catch(function () { return []; });
    })).then(function (groups) {
      return groups.flat();
    });
  }

  function decodePdfUtf16Hex(hex) {
    var start = hex.startsWith("FEFF") ? 4 : 0;
    var out = "";
    for (var i = start; i + 3 < hex.length; i += 4) {
      out += String.fromCharCode(parseInt(hex.slice(i, i + 4), 16));
    }
    return out;
  }

  function locNumber(dest) {
    return Number(String(dest || "").replace("loc-", ""));
  }

  function loadPdfDestData() {
    return fetch(absoluteRootHref("pdf/notes.pdf"))
      .then(function (response) { return response.ok ? response.arrayBuffer() : null; })
      .then(function (buffer) {
        if (!buffer) return { pages: {}, theorems: [] };
        var text = new TextDecoder("latin1").decode(buffer);
        var pages = {};
        var pattern = /\/Dest\((loc-\d+)\)[\s\S]*?\/Contents<([0-9A-Fa-f]+)>/g;
        var match;
        while ((match = pattern.exec(text))) {
          var decoded = decodePdfUtf16Hex(match[2]);
          var page = decoded.match(/page\s+(\d+)/i);
          if (page) {
            pages[match[1]] = page[1];
          }
        }
        var theoremDests = [];
        var theoremPattern = /\/Dest\((loc-\d+)\)[^\r\n]*\/Contents\((Definition|Theorem|Lemma|Proposition|Corollary|Conjecture|Problem|Example)\s+\d+\)/g;
        while ((match = theoremPattern.exec(text))) {
          theoremDests.push(match[1]);
        }
        theoremDests = theoremDests.sort(function (a, b) {
          return locNumber(a) - locNumber(b);
        });
        var headingDests = Object.keys(pages).sort(function (a, b) {
          return locNumber(a) - locNumber(b);
        });
        var theorems = theoremDests.map(function (dest) {
          var page;
          headingDests.forEach(function (headingDest) {
            if (locNumber(headingDest) < locNumber(dest)) {
              page = pages[headingDest];
            }
          });
          return { dest: dest, page: page };
        });
        return { pages: pages, theorems: theorems };
      })
      .catch(function () { return { pages: {}, theorems: [] }; });
  }

  function buildTheoremList() {
    var container = document.getElementById("theorem-list");
    if (!container) return;

    Promise.all([loadHtmlTheorems(), loadPdfDestData()]).then(function (result) {
      var items = result[0];
      var pdfData = result[1];
      container.textContent = "";
      items.forEach(function (item, index) {
        var pdf = pdfData.theorems[index] || {};
        container.appendChild(theoremEntry(item.title, item.href, pdf.dest, pdf.page));
      });
      requestAnimationFrame(function () {
        fillTheoremLeaders();
        requestAnimationFrame(fillTheoremLeaders);
      });
    });
  }

  function previousTheoremFor(node) {
    var boxes = Array.from(document.querySelectorAll("main.content .thm-box[id]"));
    var previous = null;
    boxes.forEach(function (box) {
      if (box.compareDocumentPosition(node) & Node.DOCUMENT_POSITION_FOLLOWING) {
        previous = box;
      }
    });
    return previous;
  }

  function hydrateReferences() {
    document.querySelectorAll(".ref-link-group[data-ref]").forEach(function (ref) {
      var box = previousTheoremFor(ref);
      if (!box) return;
      var head = box.querySelector(".thm-head strong");
      if (!head) return;

      var href = "#" + box.id;
      ref.textContent = "";
      var link = document.createElement("a");
      link.href = href;
      link.textContent = head.textContent.trim();

      var tooltip = document.createElement("span");
      tooltip.className = "link-choice-tooltip";
      var html = document.createElement("a");
      html.href = href;
      html.textContent = "HTML";
      var pdf = document.createElement("a");
      var destinations = pdfDestByPath();
      var dest = destinations[normalizedPath(location.href)];
      pdf.href = pdfHref(dest);
      pdf.textContent = "PDF";
      Promise.all([loadHtmlTheorems(), loadPdfDestData()]).then(function (result) {
        var items = result[0];
        var pdfData = result[1];
        var key = normalizedPath(location.href) + "#" + box.id;
        var index = items.findIndex(function (item) {
          return item.href === key;
        });
        var exact = pdfData.theorems[index];
        if (exact && exact.dest) {
          pdf.href = pdfHref(exact.dest, exact.page);
        }
      });
      tooltip.appendChild(html);
      tooltip.appendChild(pdf);

      ref.appendChild(link);
      ref.appendChild(tooltip);
    });
  }

  normalizeDisplayMath();
  buildLocalToc();
  buildTheoremList();
  hydrateReferences();
  fillTheoremLeaders();
  addEventListener("resize", function () {
    fillTheoremLeaders();
  });
  addEventListener("load", function () {
    fillTheoremLeaders();
  });
})();
