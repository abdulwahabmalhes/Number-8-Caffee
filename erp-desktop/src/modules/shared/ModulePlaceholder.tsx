export function ModulePlaceholder({ title, description }: { title: string; description: string }) {
  return <div className="placeholder panel"><span className="section-label">Foundation contract ready</span><h1>{title}</h1><p>{description}</p><div className="empty-illustration"><span>8</span></div><small>UI and data shown in this foundation are explicitly non-operational.</small></div>;
}
