import { Component, type ErrorInfo, type ReactNode } from 'react';

export class ErrorBoundary extends Component<{ children: ReactNode }, { failed: boolean }> {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  componentDidCatch(error: Error, info: ErrorInfo) { console.error('ERP UI failure', error, info.componentStack); }
  render() {
    if (this.state.failed) return <main className="fatal-error"><h1>We could not load this workspace.</h1><p>No operational data was changed. Refresh the page or contact your administrator.</p><button onClick={() => location.reload()}>Reload workspace</button></main>;
    return this.props.children;
  }
}
