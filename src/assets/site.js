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

  function wrapDisplayMath() {
    document.querySelectorAll('math[display="block"]').forEach(function (math) {
      math.setAttribute("overflow", "scroll");
      math.querySelectorAll("mo, mspace, mtext").forEach(function (node) {
        node.setAttribute("linebreak", "nobreak");
      });
      if (math.parentElement && math.parentElement.classList.contains("math-scroll")) return;
      var wrapper = document.createElement("div");
      wrapper.className = "math-scroll";
      math.replaceWith(wrapper);
      wrapper.appendChild(math);
    });
  }

  function normalizeText(text) {
    return (text || "").replace(/\s+/g, " ").replace(/\.$/, "").trim();
  }

  function replaceWithLink(node, target) {
    if (!node || !target || !target.id) return;
    var link = document.createElement("a");
    link.href = "#" + target.id;
    link.textContent = node.textContent;
    node.replaceWith(link);
  }

  function wireLocalToc() {
    var main = document.querySelector("main.content");
    if (!main) return;

    var headings = Array.from(main.querySelectorAll("h1, h2, h3, h4, h5, h6"))
      .filter(function (heading) { return heading.id; });
    var theoremBoxes = Array.from(main.querySelectorAll(".thm-box"));

    document.querySelectorAll(".local-toc li").forEach(function (item) {
      var textNode = item.querySelector("span");
      if (!textNode) return;

      var text = normalizeText(textNode.textContent);
      var target = null;

      if (item.classList.contains("toc-heading")) {
        target = headings.find(function (heading) {
          return normalizeText(heading.textContent) === text;
        });
      } else if (item.classList.contains("toc-theorem")) {
        var theorem = theoremBoxes.find(function (box) {
          var head = box.querySelector(".thm-head");
          return head && normalizeText(head.textContent) === text;
        });
        if (theorem) {
          var previous = theorem.previousElementSibling;
          target = previous && previous.id ? previous : theorem;
        }
      }

      replaceWithLink(textNode, target);
    });
  }

  wrapDisplayMath();
  wireLocalToc();
})();
