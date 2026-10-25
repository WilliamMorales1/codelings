// Runs compiled checks in node: prints each failure and exits non-zero if any, or if the checks crash.
const path = require("path");

// Stays 1 unless the report port fires, so a check that never reports can't pass.
process.exitCode = 1;
console.warn = () => {}; // silences the "Compiled in DEV mode" notice

try {
  const { Elm } = require(path.resolve(process.argv[2]));
  const app = Elm.Main.init();
  app.ports.report.subscribe((failures) => {
    for (const f of failures) console.log("x " + f);
    process.exitCode = failures.length ? 1 : 0;
  });
  // Asking only after subscribing means the answer can't be sent before anyone listens.
  app.ports.start.send(0);
} catch (e) {
  console.log(e instanceof RangeError ? "Stack overflow: " + e.message : e.message);
}
