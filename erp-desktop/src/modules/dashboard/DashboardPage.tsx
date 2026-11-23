import { Banknote, ReceiptText, ShoppingBag, TimerReset } from 'lucide-react';
import { MetricCard } from '../../components/MetricCard';
import { StatusPill } from '../../components/StatusPill';

const recent = [
  ['ERP-1048', 'Table 12', 'Preparing', 'AED 86.00'],
  ['ERP-1047', 'Car pickup', 'Ready', 'AED 42.50'],
  ['ERP-1046', 'Takeaway', 'Completed', 'AED 68.00'],
  ['ERP-1045', 'Table 03', 'Delayed', 'AED 124.00'],
];

export function DashboardPage() {
  return <>
    <div className="page-heading"><div><p className="eyebrow">Monday, 23 November</p><h1>Good morning, Mariam</h1><p>Here is the operational pulse for Dubai Flagship.</p></div><button className="primary-button">Open shift report</button></div>
    <section className="metrics-grid" aria-label="Key metrics">
      <MetricCard icon={Banknote} label="Net sales" value="AED 18,420" trend="↑ 8.4% vs. last Monday" />
      <MetricCard icon={ReceiptText} label="Orders" value="326" trend="Average ticket AED 56.50" />
      <MetricCard icon={TimerReset} label="Average prep" value="08:42" trend="Within 10 min target" />
      <MetricCard icon={ShoppingBag} label="Low stock" value="7 items" trend="2 require action today" />
    </section>
    <section className="dashboard-grid">
      <article className="panel chart-panel"><div className="panel__header"><div><span className="section-label">Sales cadence</span><h2>Revenue by hour</h2></div><button className="ghost-button">Today</button></div><div className="bar-chart" aria-label="Mock hourly revenue chart">{[32,44,38,58,72,66,84,76,94,62,48,34].map((height, i) => <div key={i} style={{ height: `${height}%` }}><span>{i + 8}:00</span></div>)}</div></article>
      <article className="panel channel-panel"><div className="panel__header"><div><span className="section-label">Order mix</span><h2>Sales channels</h2></div></div><div className="donut" aria-label="Mock channel distribution"><span><strong>326</strong><small>orders</small></span></div><ul className="legend"><li><i className="gold" />Dine-in <strong>48%</strong></li><li><i className="dark" />Takeaway <strong>31%</strong></li><li><i className="soft" />Car & QR <strong>21%</strong></li></ul></article>
      <article className="panel orders-panel"><div className="panel__header"><div><span className="section-label">Live operations</span><h2>Recent orders</h2></div><button className="ghost-button">View all</button></div><div className="table-wrap"><table><thead><tr><th>Order</th><th>Channel</th><th>Status</th><th>Total</th></tr></thead><tbody>{recent.map(([id, channel, status, total]) => <tr key={id}><td><strong>{id}</strong></td><td>{channel}</td><td><StatusPill tone={status === 'Delayed' ? 'critical' : status === 'Ready' || status === 'Completed' ? 'positive' : 'warning'}>{status}</StatusPill></td><td>{total}</td></tr>)}</tbody></table></div></article>
    </section>
  </>;
}
