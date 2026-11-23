export function StatusPill({ tone = 'neutral', children }: { tone?: 'positive' | 'warning' | 'critical' | 'neutral'; children: React.ReactNode }) {
  return <span className={`status-pill status-pill--${tone}`}>{children}</span>;
}
