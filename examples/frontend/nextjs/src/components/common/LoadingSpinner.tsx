/**
 * @file Reusable loading spinner component.
 *
 * Renders a lightweight, CSS-only spinning indicator to communicate
 * an in-progress asynchronous operation (e.g. authentication
 * initialisation, data fetching).
 */

/**
 * Displays a centred CSS loading spinner.
 *
 * The spinner is implemented as a `<div>` with a rotating border.
 * It is wrapped in a full-height container so it centres itself
 * within the available space.
 *
 * @returns The rendered loading spinner element.
 */
export function LoadingSpinner(): React.JSX.Element {
  return (
    <div className="loading-spinner-container">
      <div className="loading-spinner" aria-label="Loading" role="status">
        <span className="sr-only">Loading...</span>
      </div>
    </div>
  );
}
