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
      if (node.closest(".page-source-heading")) return;

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

  normalizeDisplayMath();
  buildLocalToc();
  fillTheoremLeaders();
  addEventListener("resize", function () {
    fillTheoremLeaders();
  });
  addEventListener("load", function () {
    fillTheoremLeaders();
  });
})();
