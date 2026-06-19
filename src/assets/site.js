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

      var tag = math.querySelector(".eq-tag, .equation-tag");
      if (tag) {
        tag.classList.add("equation-tag");
        wrapper.appendChild(tag);
      }
    });
  }

  function hydrateLocalTocHeadings() {
    document.querySelectorAll('.local-toc .toc-heading a[href^="#"]').forEach(function (link) {
      var target = document.getElementById(link.getAttribute("href").slice(1));
      if (!target) return;
      var prefix = link.textContent.trim().charAt(0) === "§" ? "§" : "";
      link.innerHTML = prefix + target.innerHTML;
    });
  }

  normalizeDisplayMath();
  hydrateLocalTocHeadings();
  fillTheoremLeaders();
  addEventListener("resize", function () {
    fillTheoremLeaders();
  });
})();
