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
    ruler.style.cssText = "position:absolute;visibility:hidden;font-family:var(--sans);white-space:nowrap;";
    ruler.textContent = "..........";
    document.body.appendChild(ruler);
    var dotWidth = Math.max(1, ruler.getBoundingClientRect().width / 10);
    ruler.remove();

    document.querySelectorAll(".theorem-list-entry").forEach(function (entry) {
      var dots = entry.querySelector(".theorem-list-dots");
      var marker = entry.querySelector(".theorem-list-end");
      var page = entry.querySelector(".theorem-list-page");
      if (!dots || !marker || !page) return;

      dots.textContent = "";
      var entryRect = entry.getBoundingClientRect();
      var markerRect = marker.getBoundingClientRect();
      var pageWidth = page.getBoundingClientRect().width;
      var remaining = entryRect.right - markerRect.right - pageWidth;
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

      var scroll = math.closest(".equation-scroll");
      if (!scroll || !wrapper.contains(scroll)) {
        scroll = document.createElement("div");
        scroll.className = "equation-scroll";
        math.parentNode.insertBefore(scroll, math);
        scroll.appendChild(math);
      }

      setupDisplayMathTags(wrapper, math);
    });
  }

  function tagGroupTop(items) {
    return items.reduce(function (sum, item) {
      return sum + item.top;
    }, 0) / items.length;
  }

  function setMathSpaceWidth(space, width) {
    var value = Math.max(0, Math.ceil(width + 8)) + "px";
    space.setAttribute("width", value);
    space.style.width = value;
  }

  function placeEquationTagGroups(wrapper) {
    var layer = wrapper.querySelector(":scope > .equation-tag-layer");
    if (!layer) return;

    var wrapperRect = wrapper.getBoundingClientRect();
    layer.querySelectorAll(".equation-tag-group").forEach(function (group) {
      var anchors = Array.from(group.querySelectorAll(".equation-tag")).map(function (tag) {
        return tag._equationTagAnchor;
      }).filter(Boolean);
      if (anchors.length === 0) return;

      var top = anchors.reduce(function (sum, anchor) {
        var rect = anchor.getBoundingClientRect();
        return sum + rect.top + rect.height / 2 - wrapperRect.top;
      }, 0) / anchors.length;

      group.style.top = top + "px";
      var width = group.getBoundingClientRect().width;
      anchors.forEach(function (anchor) {
        if (anchor.tagName && anchor.tagName.toLowerCase() === "mspace") {
          setMathSpaceWidth(anchor, width);
        }
      });
    });
  }

  function setupDisplayMathTags(wrapper, math) {
    if (wrapper.dataset.equationTagsReady === "true") {
      placeEquationTagGroups(wrapper);
      return;
    }

    var tags = Array.from(wrapper.querySelectorAll(".eq-tag, .equation-tag")).filter(function (tag) {
      return !tag.closest(".equation-tag-layer");
    });
    if (tags.length === 0) return;

    var mathmlNs = "http://www.w3.org/1998/Math/MathML";
    var wrapperRect = wrapper.getBoundingClientRect();
    var items = tags.map(function (tag) {
      var tagRect = tag.getBoundingClientRect();
      var isInsideMath = math.contains(tag);
      var anchor = tag;

      tag.classList.add("equation-tag");

      if (isInsideMath) {
        anchor = document.createElementNS(mathmlNs, "mspace");
        anchor.setAttribute("class", "equation-tag-space");
        anchor.setAttribute("width", "0px");
        tag.parentNode.insertBefore(anchor, tag);
      } else {
        anchor = document.createElement("span");
        anchor.className = "equation-tag-anchor";
        var parent = tag.parentNode;
        var holder = parent && parent !== wrapper && parent.children.length === 1 ? parent : tag;
        holder.parentNode.insertBefore(anchor, holder);
        if (holder !== tag) {
          holder.classList.add("equation-tag-holder");
        }
      }

      tag._equationTagAnchor = anchor;
      return {
        tag: tag,
        anchor: anchor,
        top: tagRect.top - wrapperRect.top + wrapper.scrollTop
      };
    }).sort(function (a, b) {
      return a.top - b.top;
    });

    var groups = [];
    var lineThreshold = 12;
    items.forEach(function (item) {
      var last = groups[groups.length - 1];
      if (last && Math.abs(item.top - tagGroupTop(last)) <= lineThreshold) {
        last.push(item);
      } else {
        groups.push([item]);
      }
    });

    var layer = document.createElement("div");
    layer.className = "equation-tag-layer";
    wrapper.appendChild(layer);

    groups.forEach(function (groupItems) {
      var group = document.createElement("div");
      group.className = "equation-tag-group";
      groupItems.forEach(function (item) {
        group.appendChild(externalEquationTag(item.tag, item.anchor));
      });
      layer.appendChild(group);
    });

    wrapper.dataset.equationTagsReady = "true";
    placeEquationTagGroups(wrapper);
  }

  function externalEquationTag(tag, anchor) {
    if (tag.tagName && tag.tagName.toLowerCase() !== "a") {
      tag._equationTagAnchor = anchor;
      return tag;
    }

    var replacement = document.createElement("div");
    Array.from(tag.attributes).forEach(function (attr) {
      if (attr.name !== "href") {
        replacement.setAttribute(attr.name, attr.value);
      }
    });
    replacement.classList.add("equation-tag");
    replacement.innerHTML = tag.innerHTML;
    replacement._equationTagAnchor = anchor;
    tag.remove();
    return replacement;
  }

  function safeReadJson(key, fallback) {
    try {
      return JSON.parse(localStorage.getItem(key) || "null") || fallback;
    } catch (_error) {
      return fallback;
    }
  }

  function safeWriteJson(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (_error) {
      // Keep navigation usable even when storage is unavailable.
    }
  }

  function navItemDepth(item) {
    var value = item.style.getPropertyValue("--depth") || "0";
    var depth = Number(value.trim());
    return Number.isFinite(depth) ? depth : 0;
  }

  function navStorageKeyForLink(link) {
    var href = link.getAttribute("href") || "";
    try {
      var url = new URL(href, window.location.href);
      return url.pathname.replace(/\/index\.html$/, "/");
    } catch (_error) {
      return href || link.textContent.trim();
    }
  }

  function setupGlobalNavCollapse() {
    var nav = document.querySelector(".global-nav");
    if (!nav) return;

    var items = Array.from(nav.querySelectorAll(".nav-item"));
    if (items.length === 0) return;

    var storageKey = "globalNavCollapsed";
    var collapsed = new Set(safeReadJson(storageKey, []));
    var parentItems = [];

    items.forEach(function (item, index) {
      var next = items[index + 1];
      var depth = navItemDepth(item);
      if (!next || navItemDepth(next) <= depth) return;

      var link = item.querySelector("a[href]");
      if (!link) return;

      var key = navStorageKeyForLink(link);
      var button = document.createElement("button");
      button.type = "button";
      button.className = "nav-collapse-toggle";
      button.setAttribute("aria-label", "Toggle " + link.textContent.trim());
      button.dataset.navKey = key;
      item.classList.add("has-children");
      item.appendChild(button);
      parentItems.push(item);

      button.addEventListener("click", function () {
        if (collapsed.has(key)) {
          collapsed.delete(key);
        } else {
          collapsed.add(key);
        }
        safeWriteJson(storageKey, Array.from(collapsed));
        applyGlobalNavCollapse();
      });
    });

    function applyGlobalNavCollapse() {
      var collapsedDepths = [];
      items.forEach(function (item) {
        var depth = navItemDepth(item);
        collapsedDepths = collapsedDepths.filter(function (parentDepth) {
          return parentDepth < depth;
        });

        item.hidden = collapsedDepths.length > 0;

        var button = item.querySelector(":scope > .nav-collapse-toggle");
        if (button) {
          var key = button.dataset.navKey;
          var isCollapsed = collapsed.has(key);
          item.classList.toggle("is-collapsed", isCollapsed);
          button.setAttribute("aria-expanded", String(!isCollapsed));
          if (isCollapsed) {
            collapsedDepths.push(depth);
          }
        }
      });
    }

    if (parentItems.length > 0) {
      applyGlobalNavCollapse();
    }
  }

  function upgradeMathLinks() {
    var mathmlNs = "http://www.w3.org/1998/Math/MathML";

    document.querySelectorAll("math a[href]").forEach(function (anchor) {
      var mtext = document.createElementNS(mathmlNs, "mtext");
      mtext.setAttribute("class", "math-link");
      mtext.setAttribute("role", "link");
      mtext.setAttribute("tabindex", "0");
      mtext.setAttribute("data-href", anchor.getAttribute("href") || "");
      if (anchor.hasAttribute("title")) {
        mtext.setAttribute("title", anchor.getAttribute("title"));
      }
      if (anchor.hasAttribute("aria-label")) {
        mtext.setAttribute("aria-label", anchor.getAttribute("aria-label"));
      }
      mtext.textContent = anchor.textContent;
      anchor.replaceWith(mtext);
    });
  }

  function moveFootnotesAbovePageNav() {
    var endnotes = document.querySelector('section[role="doc-endnotes"]');
    var main = document.querySelector(".content");
    if (!endnotes || !main) return;

    var pageNav = main.querySelector(".page-nav");
    // typst appends endnotes after the main content
    // move them so they render before the previous/next cards.
    if (pageNav) {
      main.insertBefore(endnotes, pageNav);
    } else {
      main.appendChild(endnotes);
    }
  }

  function whenDomReady(callback) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", callback, { once: true });
    } else {
      callback();
    }
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

  function setupReferenceTooltips() {
    var tooltip = document.createElement("div");
    tooltip.className = "ref-tooltip";
    tooltip.setAttribute("role", "tooltip");
    tooltip.hidden = true;
    document.body.appendChild(tooltip);

    var activeTrigger = null;
    var hideTimer = null;

    function clearHideTimer() {
      if (hideTimer) {
        clearTimeout(hideTimer);
        hideTimer = null;
      }
    }

    function scheduleHide() {
      clearHideTimer();
      hideTimer = setTimeout(function () {
        tooltip.hidden = true;
        activeTrigger = null;
      }, 300);
    }

    function linkLabel(link, index, links) {
      var href = link.getAttribute("href") || link.getAttribute("data-href") || "";
      if (links.length === 1) return "Open";
      if (index === 0 || /\.pdf(?:#|$)/i.test(href)) return "PDF";
      if (index === links.length - 1) return "HTML";
      return "Link " + (index + 1);
    }

    function placeTooltip(trigger) {
      var rect = trigger.getBoundingClientRect();
      var tipRect = tooltip.getBoundingClientRect();
      var gap = 8;
      var left = rect.left + rect.width / 2 - tipRect.width / 2;
      left = Math.max(8, Math.min(left, window.innerWidth - tipRect.width - 8));
      tooltip.style.left = left + "px";
      tooltip.style.top = Math.min(rect.bottom + gap, window.innerHeight - tipRect.height - 8) + "px";
    }

    function showTooltip(trigger, linksData) {
      clearHideTimer();
      activeTrigger = trigger;
      tooltip.textContent = "";

      linksData.forEach(function (data) {
        var item = document.createElement("a");
        item.href = data.href;
        item.textContent = data.label;
        tooltip.appendChild(item);
      });

      tooltip.hidden = linksData.length === 0;
      if (!tooltip.hidden) {
        placeTooltip(trigger);
      }
    }

    document.querySelectorAll(".typst-multi-label-list").forEach(function (source) {
      let trigger = source.previousElementSibling;
      while (trigger && !(trigger.matches("a[href]") || trigger.matches(".math-link"))) {
        trigger = trigger.previousElementSibling;
      }
      if (!trigger) return;

      var links = Array.from(source.querySelectorAll("a[href], .math-link"));
      var linksData = links.map(function (link, index) {
        return {
          href: link.getAttribute("href") || link.getAttribute("data-href"),
          label: linkLabel(link, index, links)
        };
      });

      source.remove();

      trigger.classList.add("ref-with-tooltip");

      trigger.addEventListener("mouseenter", function () {
        showTooltip(trigger, linksData);
      });
      trigger.addEventListener("mouseleave", scheduleHide);
      trigger.addEventListener("focus", function () {
        showTooltip(trigger, linksData);
      });
      trigger.addEventListener("blur", scheduleHide);
    });

    tooltip.addEventListener("mouseenter", clearHideTimer);
    tooltip.addEventListener("mouseleave", scheduleHide);
    tooltip.addEventListener("focusin", clearHideTimer);
    tooltip.addEventListener("focusout", scheduleHide);
    addEventListener("scroll", function () {
      if (!tooltip.hidden && activeTrigger) {
        placeTooltip(activeTrigger);
      }
    }, { passive: true });
    addEventListener("resize", function () {
      if (!tooltip.hidden && activeTrigger) {
        placeTooltip(activeTrigger);
      }
    });
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        tooltip.hidden = true;
        activeTrigger = null;
      }
    });
  }

  function setupMathLinkNavigation() {
    function openMathLink(link, event) {
      var href = link.getAttribute("data-href");
      if (!href) return;
      if (event.type === "click") {
        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        window.location.href = href;
      } else if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        window.location.href = href;
      }
    }

    document.addEventListener("click", function (event) {
      var link = event.target.closest && event.target.closest(".math-link");
      if (link) {
        openMathLink(link, event);
      }
    });

    document.addEventListener("keydown", function (event) {
      var link = event.target.closest && event.target.closest(".math-link");
      if (link) {
        openMathLink(link, event);
      }
    });
  }

  upgradeMathLinks();
  normalizeDisplayMath();
  setupGlobalNavCollapse();
  whenDomReady(moveFootnotesAbovePageNav);
  setupReferenceTooltips();
  setupMathLinkNavigation();
  fillTheoremLeaders();
  addEventListener("resize", function () {
    fillTheoremLeaders();
    document.querySelectorAll(".display-math").forEach(placeEquationTagGroups);
  });
  addEventListener("load", function () {
    fillTheoremLeaders();
    document.querySelectorAll(".display-math").forEach(placeEquationTagGroups);
  });
})();
