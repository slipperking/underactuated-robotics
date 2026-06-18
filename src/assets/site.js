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

})();
