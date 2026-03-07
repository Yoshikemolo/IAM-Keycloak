/**
 * @file HTTP server entry point.
 *
 * Starts the Express application on the configured port and logs
 * the listening address to the console.
 */

import { createApp } from "./app.js";

const PORT = parseInt(process.env.PORT ?? "3000", 10);

const app = createApp();

app.listen(PORT, () => {
  console.log(`IAM Express example listening on http://localhost:${PORT}`);
});
