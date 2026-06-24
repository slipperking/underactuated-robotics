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

      var tag = math.querySelector(".eq-tag, .equation-tag");
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
      var href = link.getAttribute("href") || "";
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
      while (trigger && !(trigger.matches("a[href]"))) {
        trigger = trigger.previousElementSibling;
      }
      if (!trigger) return;

      var links = Array.from(source.querySelectorAll("a[href]"));
      var linksData = links.map(function (link, index) {
        return {
          href: link.getAttribute("href"),
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

  normalizeDisplayMath();
  setupReferenceTooltips();
  fillTheoremLeaders();
  addEventListener("resize", function () {
    fillTheoremLeaders();
  });
  addEventListener("load", function () {
    fillTheoremLeaders();
  });
})();
