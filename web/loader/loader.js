window.addEventListener("DOMContentLoaded", () => {
  const progressEl = document.getElementById("progress");
  const textEl = document.getElementById("loading-text");
  const loading = document.getElementById("loading");

  let done = false;
  let timeouts = [];

  function setProgress(val) {
    progressEl.style.width = val + "%";
  }

  function schedule(fn, delay) {
    const id = setTimeout(fn, delay);
    timeouts.push(id);
  }

  function clearAllTimers() {
    timeouts.forEach(clearTimeout);
    timeouts = [];
  }

  // Simulated staged loading
  setProgress(10);

  schedule(() => {
    if (done) return;
    setProgress(50);
    textEl.textContent = "Initializing...";
  }, 1500);

  schedule(() => {
    if (done) return;
    setProgress(70);
    textEl.textContent = "Loading assets...";
  }, 3600);

  schedule(() => {
    if (done) return;
    setProgress(85);
    textEl.textContent = "Still loading...";
  }, 6000);

  // Flutter ready signal
  window.addEventListener("flutter-first-frame", () => {
    if (done) return;
    done = true;

    clearAllTimers();

    setProgress(100);
    textEl.textContent = "Ready";

    setTimeout(() => {
      loading.style.opacity = 0;

      setTimeout(() => {
        loading.remove();
      }, 400);
    }, 600);
  });
});
