import type { LucideIcon } from 'lucide-react';

export function MetricCard({ icon: Icon, label, value, trend }: { icon: LucideIcon; label: string; value: string; trend: string }) {
  return (
    <article className="metric-card">
      <div className="metric-card__top"><span>{label}</span><Icon size={19} aria-hidden="true" /></div>
      <strong>{value}</strong>
      <small>{trend}</small>
    </article>
  );
}
