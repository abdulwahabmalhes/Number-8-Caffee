import { ArrowDownToLine, ArrowLeftRight, ClipboardCheck, PackagePlus } from 'lucide-react';
import { StatusPill } from '../../components/StatusPill';
import type { InventoryItem } from '../../types/erp';

const inventory: InventoryItem[] = [
  { id: '1', name: 'Ethiopia Guji beans', quantity: 8.4, unit: 'kg', reorderAt: 6, valueMinor: 176400 },
  { id: '2', name: 'Oat milk', quantity: 18, unit: 'cartons', reorderAt: 24, valueMinor: 39600 },
  { id: '3', name: 'Pistachio paste', quantity: 2.1, unit: 'kg', reorderAt: 3, valueMinor: 56700 },
  { id: '4', name: '12oz hot cups', quantity: 420, unit: 'pcs', reorderAt: 250, valueMinor: 29400 },
];

export function InventoryPage() {
  return <><div className="page-heading"><div><p className="eyebrow">Main store · Dubai Flagship</p><h1>Inventory control</h1><p>Traceable stock, receiving, transfers and variance review.</p></div><button className="primary-button"><PackagePlus size={17}/>New movement</button></div><div className="action-strip"><button><ArrowDownToLine/>Receive purchase</button><button><ArrowLeftRight/>Transfer stock</button><button><ClipboardCheck/>Start stock count</button></div><section className="panel inventory-panel"><div className="panel__header"><div><span className="section-label">Live balance mock</span><h2>Ingredients & supplies</h2></div><div className="filters"><input aria-label="Filter inventory items" placeholder="Filter items"/><select aria-label="Stock location"><option>All locations</option></select></div></div><div className="table-wrap"><table><thead><tr><th>Item</th><th>On hand</th><th>Reorder point</th><th>Inventory value</th><th>State</th></tr></thead><tbody>{inventory.map((item) => { const low = item.quantity < item.reorderAt; return <tr key={item.id}><td><strong>{item.name}</strong><small className="sku">ING-{item.id.padStart(4, '0')}</small></td><td>{item.quantity} {item.unit}</td><td>{item.reorderAt} {item.unit}</td><td>AED {(item.valueMinor / 100).toFixed(2)}</td><td><StatusPill tone={low ? 'critical' : 'positive'}>{low ? 'Reorder' : 'Healthy'}</StatusPill></td></tr>; })}</tbody></table></div></section></>;
}
