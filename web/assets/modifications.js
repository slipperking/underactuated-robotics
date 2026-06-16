(function () {
  "use strict";

  var currentScript = document.currentScript;
  var navScriptUrl = currentScript && currentScript.src
    ? new URL(currentScript.src, window.location.href)
    : new URL(window.location.href);
  var typstColorizeCounter = 0;

  function colorizeTypstSvg(svg) {
    if (!svg || svg.dataset.typstColorized === "true") {
      return;
    }

    svg.dataset.typstColorized = "true";

    var ns = "http://www.w3.org/2000/svg";
    var defs = svg.querySelector("defs");
    if (!defs) {
      defs = document.createElementNS(ns, "defs");
      svg.insertBefore(defs, svg.firstChild);
    }

    var filterId = "typst-colorize-" + (++typstColorizeCounter);
    var filter = document.createElementNS(ns, "filter");
    filter.setAttribute("id", filterId);
    filter.setAttribute("color-interpolation-filters", "sRGB");

    var flood = document.createElementNS(ns, "feFlood");
    flood.setAttribute("flood-color", "var(--typst-svg-color, transparent)");
    flood.setAttribute("flood-opacity", "1");
    flood.setAttribute("result", "typstColor");

    var composite = document.createElementNS(ns, "feComposite");
    composite.setAttribute("in", "typstColor");
    composite.setAttribute("in2", "SourceAlpha");
    composite.setAttribute("operator", "in");
    composite.setAttribute("result", "colorLayer");

    var merge = document.createElementNS(ns, "feMerge");
    var mn1 = document.createElementNS(ns, "feMergeNode");
    mn1.setAttribute("in", "SourceGraphic");
    var mn2 = document.createElementNS(ns, "feMergeNode");
    mn2.setAttribute("in", "colorLayer");
    merge.appendChild(mn1);
    merge.appendChild(mn2);

    filter.appendChild(flood);
    filter.appendChild(composite);
    filter.appendChild(merge);
    defs.appendChild(filter);

    svg.style.setProperty("--_typst-filter", "url(#" + filterId + ")");
    svg.classList.add("typst-frame", "typst-colorized");
  }

  function colorizeTypstSvgFrames() {
    document.querySelectorAll(".typst-frame-wrapper").forEach(function (wrapper) {
      wrapper.querySelectorAll("svg").forEach(colorizeTypstSvg);
    });

    document.querySelectorAll("svg.typst-frame").forEach(colorizeTypstSvg);
  }

  var THEMES = ["light", "dark", "auto"];
  var THEME_ICON_LIGHT = '<svg viewBox="0 0 512 512" width="18" height="18" aria-hidden="true" fill="currentColor"><path d="M361.5 1.2c5 2.1 8.6 6.6 9.6 11.9L391 121l107.9 19.8c5.3 1 9.8 4.6 11.9 9.6s1.5 10.7-1.6 15.2L446.9 256l62.3 90.3c3.1 4.5 3.7 10.2 1.6 15.2s-6.6 8.6-11.9 9.6L391 391 371.1 498.9c-1 5.3-4.6 9.8-9.6 11.9s-10.7 1.5-15.2-1.6L256 446.9l-90.3 62.3c-4.5 3.1-10.2 3.7-15.2 1.6s-8.6-6.6-9.6-11.9L121 391 13.1 371.1c-5.3-1-9.8-4.6-11.9-9.6s-1.5-10.7 1.6-15.2L65.1 256 2.8 165.7c-3.1-4.5-3.7-10.2-1.6-15.2s6.6-8.6 11.9-9.6L121 121 140.9 13.1c1-5.3 4.6-9.8 9.6-11.9s10.7-1.5 15.2 1.6L256 65.1 346.3 2.8c4.5-3.1 10.2-3.7 15.2-1.6zM160 256a96 96 0 1 1 192 0 96 96 0 1 1 -192 0zm224 0a128 128 0 1 0 -256 0 128 128 0 1 0 256 0z"></path></svg>';
  var THEME_ICON_DARK = '<svg viewBox="0 0 384 512" width="18" height="18" aria-hidden="true" fill="currentColor"><path d="M223.5 32C100 32 0 132.3 0 256S100 480 223.5 480c60.6 0 115.5-24.2 155.8-63.4c5-4.9 6.3-12.5 3.1-18.7s-10.1-9.7-17-8.5c-9.8 1.7-19.8 2.6-30.1 2.6c-96.9 0-175.5-78.8-175.5-176c0-65.8 36-123.1 89.3-153.3c6.1-3.5 9.2-10.5 7.7-17.3s-7.3-11.9-14.3-12.5c-6.3-.5-12.6-.8-19-.8z"></path></svg>';
  var THEME_ICON_AUTO = '<svg viewBox="0 0 512 512" width="18" height="18" aria-hidden="true" fill="currentColor"><path d="M448 256c0-106-86-192-192-192V448c106 0 192-86 192-192zM0 256a256 256 0 1 1 512 0A256 256 0 1 1 0 256z"></path></svg>';
  var THEME_ICONS = {
    light: THEME_ICON_LIGHT,
    dark: THEME_ICON_DARK,
    auto: THEME_ICON_AUTO,
  };

  var themeBtn = document.querySelector(".theme-toggle");
  var storedMode = localStorage.getItem("theme") || "auto";

  function resolveTheme(mode) {
    if (mode === "auto") {
      return matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    return mode;
  }

  function applyTheme(mode) {
    storedMode = mode;
    localStorage.setItem("theme", mode);
    document.documentElement.dataset.theme = resolveTheme(mode);
    if (themeBtn) {
      themeBtn.innerHTML = THEME_ICONS[mode] || THEME_ICONS.auto;
      themeBtn.title =
        mode === "light" ? "Theme: Light" :
          mode === "dark" ? "Theme: Dark" :
            "Theme: Auto";
      themeBtn.setAttribute("aria-label", themeBtn.title);
    }
  }

  if (themeBtn) {
    themeBtn.addEventListener("click", function () {
      var idx = (THEMES.indexOf(storedMode) + 1) % THEMES.length;
      applyTheme(THEMES[idx]);
    });
  }

  matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function () {
    if (storedMode === "auto") {
      document.documentElement.dataset.theme = resolveTheme("auto");
    }
  });

  applyTheme(storedMode);
  colorizeTypstSvgFrames();

  var sidebarLeft = document.querySelector(".sidebar-left");
  var sidebarRight = document.querySelector(".sidebar-right");
  var backdrop = document.getElementById("sidebar-backdrop");
  var toggleLeft = document.getElementById("sidebar-toggle-left");
  var toggleRight = document.getElementById("sidebar-toggle-right");

  function closeSidebars() {
    if (sidebarLeft) sidebarLeft.classList.remove("open");
    if (sidebarRight) sidebarRight.classList.remove("open");
    if (backdrop) backdrop.classList.remove("visible");
  }

  if (toggleLeft && sidebarLeft) {
    toggleLeft.addEventListener("click", function () {
      var opening = !sidebarLeft.classList.contains("open");
      closeSidebars();
      if (opening) {
        sidebarLeft.classList.add("open");
        backdrop.classList.add("visible");
      }
    });
  }

  if (toggleRight && sidebarRight) {
    toggleRight.addEventListener("click", function () {
      var opening = !sidebarRight.classList.contains("open");
      closeSidebars();
      if (opening) {
        sidebarRight.classList.add("open");
        backdrop.classList.add("visible");
      }
    });
  }

  if (backdrop) {
    backdrop.addEventListener("click", closeSidebars);
  }

  window.addEventListener("resize", function () {
    if (window.innerWidth > 960 && sidebarLeft && sidebarLeft.classList.contains("open")) {
      closeSidebars();
    }
    if (window.innerWidth > 1200 && sidebarRight && sidebarRight.classList.contains("open")) {
      closeSidebars();
    }
  });

  var navCollapseButtons = document.querySelectorAll(".nav-collapse-toggle");
  var navStateStorageKey = "global-nav-collapsed";

  function readNavCollapseState() {
    try {
      return JSON.parse(sessionStorage.getItem(navStateStorageKey) || "{}");
    } catch (_err) {
      return {};
    }
  }

  function writeNavCollapseState(state) {
    try {
      sessionStorage.setItem(navStateStorageKey, JSON.stringify(state));
    } catch (_err) {
    }
  }

  var navCollapseState = readNavCollapseState();

  function getNavCollapsedStyleTag() {
    var styleTag = document.getElementById("nav-collapsed-state");
    if (!styleTag) {
      styleTag = document.createElement("style");
      styleTag.id = "nav-collapsed-state";
      document.head.appendChild(styleTag);
    }
    return styleTag;
  }

  function syncNavCollapsedStyle() {
    var styleTag = getNavCollapsedStyleTag();
    var ids = Object.keys(navCollapseState).filter(function (id) {
      return navCollapseState[id];
    });
    styleTag.textContent = ids.map(function (id) {
      return "#" + id + "{display:none;}";
    }).join("");
  }

  function isActiveBranch(listItem) {
    return !!(listItem && (listItem.classList.contains("active") || listItem.querySelector("li.active")));
  }

  function shouldCollapseNavGroup(button) {
    var listItem = button.closest("li");
    if (!listItem) return false;

    var containerId = button.getAttribute("aria-controls");
    if (!containerId) return false;

    if (isActiveBranch(listItem)) {
      return false;
    }

    if (Object.prototype.hasOwnProperty.call(navCollapseState, containerId)) {
      return !!navCollapseState[containerId];
    }

    var nestedGroup = !!listItem.parentElement.closest(".nav-children");
    return nestedGroup;
  }

  function setNavCollapsed(button, collapsed) {
    var containerId = button.getAttribute("aria-controls");
    if (!containerId) return;

    var container = document.getElementById(containerId);
    if (!container) return;

    button.setAttribute("aria-expanded", collapsed ? "false" : "true");
    button.setAttribute("aria-label", collapsed ? "Expand subsection" : "Collapse subsection");
    container.hidden = collapsed;

    var listItem = button.closest("li");
    if (listItem) {
      listItem.classList.toggle("collapsed", collapsed);
    }

    navCollapseState[containerId] = collapsed;
    syncNavCollapsedStyle();
    writeNavCollapseState(navCollapseState);
  }

  navCollapseButtons.forEach(function (button) {
    setNavCollapsed(button, shouldCollapseNavGroup(button));
    button.addEventListener("click", function () {
      var expanded = button.getAttribute("aria-expanded") !== "false";
      setNavCollapsed(button, expanded);
    });
  });

  var searchOverlay = document.getElementById("search-overlay");
  var searchInput = document.getElementById("search-input");
  var searchResults = document.getElementById("search-results");
  var searchTrigger = document.querySelector(".search-trigger");
  var pagefind = null;
  var searchTimeout = null;

  function openSearch() {
    if (!searchOverlay) return;
    searchOverlay.classList.add("visible");
    if (searchInput) {
      searchInput.value = "";
      searchInput.focus();
    }
    if (searchResults) searchResults.innerHTML = "";
    loadPagefind();
  }

  function closeSearch() {
    if (searchOverlay) searchOverlay.classList.remove("visible");
  }

  async function loadPagefind() {
    if (pagefind) return;
    try {
      pagefind = await import(new URL("./pagefind/pagefind.js", navScriptUrl).href);
      var baseMeta = document.querySelector('meta[name="pagefind-base"]');
      var baseUrl = baseMeta ? baseMeta.getAttribute("content") : "/";
      await pagefind.options({ baseUrl: baseUrl });
      await pagefind.init();
    } catch (e) {
      console.warn("Pagefind not available:", e);
    }
  }

  function performSearch(query) {
    if (!searchResults) return;
    if (!query || query.length < 2) {
      searchResults.innerHTML = "";
      return;
    }
    if (!pagefind) {
      searchResults.innerHTML = '<div class="search-no-results">Search index not available.</div>';
      return;
    }

    pagefind.search(query).then(function (results) {
      if (!results || !results.results || results.results.length === 0) {
        searchResults.innerHTML = '<div class="search-no-results">No results found.</div>';
        return;
      }
      var items = results.results.slice(0, 8);
      Promise.all(items.map(function (r) { return r.data(); })).then(function (dataList) {
        var html = "";
        var count = 0;
        for (var i = 0; i < dataList.length && count < 12; i++) {
          var data = dataList[i];
          var pageTitle = (data.meta && data.meta.title) || "Untitled";
          var subs = data.sub_results;
          if (subs && subs.length > 0) {
            for (var j = 0; j < subs.length && count < 12; j++) {
              var sub = subs[j];
              var url = sub.url || data.url || "#";
              var title = sub.title || pageTitle;
              var excerpt = sub.excerpt || "";
              var breadcrumb = (title !== pageTitle)
                ? '<div class="search-result-page">' + escapeHtml(pageTitle) + '</div>'
                : '';
              html += '<a class="search-result" href="' + url + '">'
                + breadcrumb
                + '<div class="search-result-title">' + escapeHtml(title) + '</div>'
                + '<div class="search-result-excerpt">' + excerpt + '</div>'
                + '</a>';
              count++;
            }
          } else {
            var url = data.url || "#";
            var excerpt = data.excerpt || "";
            html += '<a class="search-result" href="' + url + '">'
              + '<div class="search-result-title">' + escapeHtml(pageTitle) + '</div>'
              + '<div class="search-result-excerpt">' + excerpt + '</div>'
              + '</a>';
            count++;
          }
        }
        searchResults.innerHTML = html;
      });
    }).catch(function () {
      searchResults.innerHTML = '<div class="search-no-results">Search error.</div>';
    });
  }

  function escapeHtml(s) {
    var div = document.createElement("div");
    div.textContent = s;
    return div.innerHTML;
  }

  if (searchTrigger) {
    searchTrigger.addEventListener("click", openSearch);
  }

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(function () {
        performSearch(searchInput.value.trim());
      }, 200);
    });
  }

  if (searchOverlay) {
    searchOverlay.addEventListener("click", function (e) {
      if (e.target === searchOverlay) closeSearch();
    });
  }

  document.addEventListener("keydown", function (e) {
    if ((e.ctrlKey || e.metaKey) && e.key === "k") {
      e.preventDefault();
      if (searchOverlay && searchOverlay.classList.contains("visible")) {
        closeSearch();
      } else {
        openSearch();
      }
    }
    if (e.key === "Escape") {
      if (searchOverlay && searchOverlay.classList.contains("visible")) {
        closeSearch();
      } else {
        closeSidebars();
      }
    }
  });

  var tocLinks = document.querySelectorAll(".local-toc a");
  if (tocLinks.length > 0) {
    var topbar = document.querySelector(".topbar");
    function getOffset() {
      var rootStyles = window.getComputedStyle(document.documentElement);
      var scrollPaddingTop = parseFloat(rootStyles.scrollPaddingTop || "0");
      if (!Number.isNaN(scrollPaddingTop) && scrollPaddingTop > 0) {
        return scrollPaddingTop;
      }
      return (topbar ? topbar.offsetHeight : 56) + 16;
    }

    var hashActivationSlack = 48;
    var pendingTargetId = null;
    var pendingTargetUntil = 0;
    var headingEls = [];
    var headingMap = {};

    tocLinks.forEach(function (link) {
      var id = link.getAttribute("href");
      if (id && id.startsWith("#")) {
        var el = document.getElementById(id.slice(1));
        if (el) {
          headingEls.push(el);
          headingMap[el.id] = link;
        }
      }
    });

    var ticking = false;
    function updateSpy() {
      ticking = false;
      var current = null;
      var offset = getOffset();
      var now = (window.performance && typeof window.performance.now === "function")
        ? window.performance.now()
        : Date.now();

      if (pendingTargetId && now <= pendingTargetUntil) {
        var pendingTarget = document.getElementById(pendingTargetId);
        if (pendingTarget && headingMap[pendingTarget.id]) {
          var pendingRect = pendingTarget.getBoundingClientRect();
          if (pendingRect.bottom > 0 && pendingRect.top < window.innerHeight) {
            current = pendingTarget;
            if (Math.abs(pendingRect.top - offset) <= hashActivationSlack + 8) {
              pendingTargetId = null;
              pendingTargetUntil = 0;
            }
          }
        }
      } else if (pendingTargetId) {
        pendingTargetId = null;
        pendingTargetUntil = 0;
      }

      var hash = window.location.hash;
      if (!current && hash && hash.length > 1) {
        var hashTarget = document.getElementById(hash.slice(1));
        if (hashTarget && headingMap[hashTarget.id]) {
          var targetRect = hashTarget.getBoundingClientRect();
          if (targetRect.top <= offset + hashActivationSlack && targetRect.bottom > 0) {
            current = hashTarget;
          }
        }
      }

      if (!current) {
        var best = null;
        var bestScore = Infinity;
        for (var i = 0; i < headingEls.length; i++) {
          var rect = headingEls[i].getBoundingClientRect();
          if (rect.bottom <= 0) {
            continue;
          }

          var score = Math.abs(rect.top - offset);

          if (rect.top < offset) {
            score += 12;
          }

          if (score < bestScore) {
            best = headingEls[i];
            bestScore = score;
          }
        }
        current = best;
      }
      tocLinks.forEach(function (l) { l.classList.remove("active"); });
      if (current && headingMap[current.id]) {
        headingMap[current.id].classList.add("active");
      }
    }

    window.addEventListener("scroll", function () {
      if (!ticking) {
        requestAnimationFrame(updateSpy);
        ticking = true;
      }
    });

    window.addEventListener("hashchange", function () {
      var hash = window.location.hash;
      pendingTargetId = hash && hash.length > 1 ? hash.slice(1) : null;
      pendingTargetUntil = pendingTargetId ? (
        ((window.performance && typeof window.performance.now === "function")
          ? window.performance.now()
          : Date.now()) + 1200
      ) : 0;
      requestAnimationFrame(updateSpy);
    });

    tocLinks.forEach(function (link) {
      link.addEventListener("click", function () {
        var href = link.getAttribute("href");
        pendingTargetId = href && href.startsWith("#") ? href.slice(1) : null;
        pendingTargetUntil = pendingTargetId ? (
          ((window.performance && typeof window.performance.now === "function")
            ? window.performance.now()
            : Date.now()) + 1200
        ) : 0;
        requestAnimationFrame(function () {
          requestAnimationFrame(updateSpy);
        });
      });
    });

    updateSpy();
  }

  document.querySelectorAll('.thm-proof, .thm-solution').forEach(block => {
    const qedPara = block.querySelector('p.qed');
    if (!qedPara) return;

    const prev = qedPara.previousElementSibling;
    if (!prev || !(prev.tagName === 'P' || prev.tagName === 'SVG')) return;
    const target = prev;

    const qedContent = qedPara.querySelector('span, svg');
    if (qedContent) {
      const wrapper = document.createElement('span');
      wrapper.style.cssText = 'float:right; margin-left:0.5em; line-height:1;';
      wrapper.appendChild(qedContent.cloneNode(true));
      target.appendChild(wrapper);
    }
    qedPara.remove();
  });

  document.querySelectorAll('ul.itemize-ul-list').forEach(ul => {
    const temp = document.createElement('span');
    temp.style.cssText = 'position:absolute;visibility:hidden;white-space:nowrap;';
    document.body.appendChild(temp);

    let maxWidth = 0;
    ul.querySelectorAll('.data-marker-item').forEach(li => {
      temp.textContent = li.dataset.marker ?? '';
      maxWidth = Math.max(maxWidth, temp.offsetWidth);
    });

    document.body.removeChild(temp);
    ul.style.setProperty('--marker-slot', `${maxWidth + 20}px`);
  });
})();
