import { useState, useEffect } from 'react';
import { Bell, CheckCircle2, Clock, Flame, Play, RefreshCw, Volume2, VolumeX } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';

export type TicketStatus = 'new' | 'preparing' | 'ready' | 'completed';
export type StationCode = 'ALL' | 'HOT_BAR' | 'COLD_BAR' | 'PASTRY';

export interface KitchenTicketItem {
  id: string;
  nameEn: string;
  nameAr: string;
  quantity: number;
  modifiers?: string[];
}

export interface KitchenTicket {
  id: string;
  ticketNumber: string;
  orderNumber: string;
  orderType: 'dine_in' | 'takeaway' | 'car_pickup';
  tableOrVehicle?: string;
  station: 'HOT_BAR' | 'COLD_BAR' | 'PASTRY';
  status: TicketStatus;
  createdAt: number; // timestamp
  items: KitchenTicketItem[];
  notes?: string;
}

const initialTickets: KitchenTicket[] = [
  {
    id: 'kt-1',
    ticketNumber: '#K-101',
    orderNumber: '#NE1042',
    orderType: 'dine_in',
    tableOrVehicle: 'T-04',
    station: 'HOT_BAR',
    status: 'new',
    createdAt: Date.now() - 3 * 60 * 1000, // 3 mins ago
    items: [
      { id: 'i-1', nameEn: 'Flat White', nameAr: 'فلات وايت', quantity: 2, modifiers: ['Oat Milk / حليب شوفان', 'Double Shot / دبل شوت'] },
      { id: 'i-2', nameEn: 'Cortado', nameAr: 'كورتادو', quantity: 1 },
    ],
    notes: 'Extra hot on flat white please.',
  },
  {
    id: 'kt-2',
    ticketNumber: '#K-102',
    orderNumber: '#NE1043',
    orderType: 'car_pickup',
    tableOrVehicle: 'Dubai A-58921',
    station: 'COLD_BAR',
    status: 'preparing',
    createdAt: Date.now() - 7 * 60 * 1000, // 7 mins ago (warning)
    items: [
      { id: 'i-3', nameEn: 'Spanish Iced Latte', nameAr: 'سبانش لاتيه بارد', quantity: 2, modifiers: ['Less Ice / ثلج أقل'] },
      { id: 'i-4', nameEn: 'V60 Cold Drip', nameAr: 'قهوة مقطرة باردة', quantity: 1, modifiers: ['Ethiopia Yirgacheffe'] },
    ],
  },
  {
    id: 'kt-3',
    ticketNumber: '#K-103',
    orderNumber: '#NE1044',
    orderType: 'takeaway',
    station: 'PASTRY',
    status: 'preparing',
    createdAt: Date.now() - 12 * 60 * 1000, // 12 mins ago (urgent)
    items: [
      { id: 'i-5', nameEn: 'Almond Croissant', nameAr: 'كرواسون لوز', quantity: 2, modifiers: ['Warmed / مسخّن'] },
      { id: 'i-6', nameEn: 'Pistachio Basque Cheesecake', nameAr: 'تشيز كيك فستق', quantity: 1 },
    ],
  },
  {
    id: 'kt-4',
    ticketNumber: '#K-104',
    orderNumber: '#NE1040',
    orderType: 'dine_in',
    tableOrVehicle: 'T-01',
    station: 'HOT_BAR',
    status: 'ready',
    createdAt: Date.now() - 15 * 60 * 1000,
    items: [
      { id: 'i-7', nameEn: 'Signature Chemex (2 cups)', nameAr: 'كيمكس توقيع (كوبين)', quantity: 1 },
    ],
  },
];

export function KitchenPage() {
  const { locale } = useI18n();
  const [tickets, setTickets] = useState<KitchenTicket[]>(initialTickets);
  const [selectedStation, setSelectedStation] = useState<StationCode>('ALL');
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [currentTime, setCurrentTime] = useState(Date.now());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  const loadTickets = async () => {
    if (sessionAdapter.isDemoMode()) return;
    try {
      const res = await apiClient.request<{ tickets: any[] }>('kitchen/tickets');
      if (res && res.tickets) {
        setTickets(
          res.tickets.map((t: any) => ({
            id: String(t.id),
            ticketNumber: t.ticket_number || `#K-${t.id}`,
            orderNumber: t.order?.order_number || `#ORD-${t.order_id}`,
            orderType: (t.order?.order_type as any) || 'dine_in',
            tableOrVehicle: t.table_number || undefined,
            station: (t.station_code || 'HOT_BAR') as any,
            status: t.status as TicketStatus,
            createdAt: new Date(t.created_at).getTime(),
            items: (t.order?.items || []).map((it: any, idx: number) => ({
              id: String(it.id || idx),
              nameEn: it.product_name_en || it.item_name || 'Item',
              nameAr: it.product_name_ar || it.item_name || 'صنف',
              quantity: it.quantity || 1,
              modifiers: it.notes ? [it.notes] : undefined,
            })),
            notes: t.notes || t.order?.notes || undefined,
          }))
        );
      }
    } catch {
      // Fallback gracefully on network / auth pause
    }
  };

  useEffect(() => {
    loadTickets();
    const pollInterval = setInterval(() => {
      loadTickets();
    }, 6000);
    return () => clearInterval(pollInterval);
  }, []);

  const updateStatus = async (ticketId: string, nextStatus: TicketStatus) => {
    setTickets((prev) =>
      prev.map((t) => (t.id === ticketId ? { ...t, status: nextStatus } : t))
    );

    if (!sessionAdapter.isDemoMode()) {
      try {
        await apiClient.request(`kitchen/tickets/${ticketId}/status`, {
          method: 'POST',
          body: JSON.stringify({ status: nextStatus }),
        });
        loadTickets();
      } catch {
        // Fallback gracefully in case of mock/demo
      }
    }
  };

  const filteredTickets = tickets
    .filter((t) => t.status !== 'completed')
    .filter((t) => selectedStation === 'ALL' || t.station === selectedStation);

  const getElapsedMinutes = (createdAt: number) => {
    return Math.floor((currentTime - createdAt) / 60000);
  };

  const getTimerClass = (minutes: number) => {
    if (minutes >= 10) return 'timer-urgent';
    if (minutes >= 5) return 'timer-warning';
    return 'timer-normal';
  };

  return (
    <div className="kitchen-page">
      <div className="page-header">
        <div>
          <h2>{locale === 'ar' ? 'شاشة المطبخ وإعداد الطلبات (KDS)' : 'Kitchen Display System (KDS)'}</h2>
          <p className="page-subtitle">
            {locale === 'ar'
              ? 'تتبع أوقات التحضير ومحطات البار وإدارة تدفق طلبات الفرع في الوقت الفعلي'
              : 'Real-time station routing, preparation timers, and order fulfillment flow'}
          </p>
        </div>
        <div className="header-actions">
          <button
            className={`btn-icon ${soundEnabled ? 'active' : ''}`}
            onClick={() => setSoundEnabled(!soundEnabled)}
            title={soundEnabled ? 'Mute Alerts' : 'Unmute Alerts'}
          >
            {soundEnabled ? <Volume2 size={18} /> : <VolumeX size={18} />}
          </button>
          <button className="btn-secondary" onClick={() => setTickets(initialTickets)}>
            <RefreshCw size={16} />
            <span>{locale === 'ar' ? 'تحديث' : 'Refresh'}</span>
          </button>
        </div>
      </div>

      <div className="kitchen-controls">
        <div className="station-filters">
          <button
            className={`station-pill ${selectedStation === 'ALL' ? 'active' : ''}`}
            onClick={() => setSelectedStation('ALL')}
          >
            {locale === 'ar' ? 'جميع المحطات' : 'All Stations'} ({tickets.filter((t) => t.status !== 'completed').length})
          </button>
          <button
            className={`station-pill ${selectedStation === 'HOT_BAR' ? 'active' : ''}`}
            onClick={() => setSelectedStation('HOT_BAR')}
          >
            ☕ {locale === 'ar' ? 'البار الساخن' : 'Hot Bar'}
          </button>
          <button
            className={`station-pill ${selectedStation === 'COLD_BAR' ? 'active' : ''}`}
            onClick={() => setSelectedStation('COLD_BAR')}
          >
            🧊 {locale === 'ar' ? 'البار البارد' : 'Cold Bar'}
          </button>
          <button
            className={`station-pill ${selectedStation === 'PASTRY' ? 'active' : ''}`}
            onClick={() => setSelectedStation('PASTRY')}
          >
            🥐 {locale === 'ar' ? 'المخبوزات' : 'Pastry'}
          </button>
        </div>

        <div className="kds-metrics">
          <span className="metric-tag">
            <Flame size={14} className="text-warning" />
            <span>{locale === 'ar' ? 'متوسط التحضير: 4.8 دقيقة' : 'Avg Prep: 4.8m'}</span>
          </span>
          <span className="metric-tag">
            <Bell size={14} />
            <span>{filteredTickets.length} {locale === 'ar' ? 'تذاكر نشطة' : 'active tickets'}</span>
          </span>
        </div>
      </div>

      <div className="tickets-grid">
        {filteredTickets.map((ticket) => {
          const minutes = getElapsedMinutes(ticket.createdAt);
          const timerClass = getTimerClass(minutes);

          return (
            <div key={ticket.id} className={`kds-ticket status-${ticket.status}`}>
              <div className="ticket-header">
                <div className="ticket-title-block">
                  <span className="ticket-number">{ticket.ticketNumber}</span>
                  <span className="order-ref">{ticket.orderNumber}</span>
                </div>
                <div className={`ticket-timer ${timerClass}`}>
                  <Clock size={15} />
                  <span>{minutes}m</span>
                </div>
              </div>

              <div className="ticket-subbar">
                <span className={`order-type-badge ${ticket.orderType}`}>
                  {ticket.orderType === 'dine_in' && (locale === 'ar' ? 'صالة' : 'Dine-In')}
                  {ticket.orderType === 'takeaway' && (locale === 'ar' ? 'سفري' : 'Takeaway')}
                  {ticket.orderType === 'car_pickup' && (locale === 'ar' ? 'استلام سيارة' : 'Car Pickup')}
                  {ticket.tableOrVehicle && ` • ${ticket.tableOrVehicle}`}
                </span>
                <span className="station-badge">{ticket.station.replace('_', ' ')}</span>
              </div>

              {ticket.notes && (
                <div className="ticket-notes">
                  ⚠️ {ticket.notes}
                </div>
              )}

              <ul className="ticket-items-list">
                {ticket.items.map((item) => (
                  <li key={item.id} className="ticket-item-row">
                    <span className="item-qty">{item.quantity}×</span>
                    <div className="item-details">
                      <span className="item-name">{locale === 'ar' ? item.nameAr : item.nameEn}</span>
                      {item.modifiers && item.modifiers.length > 0 && (
                        <div className="item-modifiers">
                          {item.modifiers.map((mod, idx) => (
                            <span key={idx} className="mod-pill">{mod}</span>
                          ))}
                        </div>
                      )}
                    </div>
                  </li>
                ))}
              </ul>

              <div className="ticket-actions">
                {ticket.status === 'new' && (
                  <button
                    className="btn-kds btn-start"
                    onClick={() => updateStatus(ticket.id, 'preparing')}
                  >
                    <Play size={16} />
                    <span>{locale === 'ar' ? 'بدء التحضير' : 'Start Prep'}</span>
                  </button>
                )}
                {ticket.status === 'preparing' && (
                  <button
                    className="btn-kds btn-ready"
                    onClick={() => updateStatus(ticket.id, 'ready')}
                  >
                    <CheckCircle2 size={16} />
                    <span>{locale === 'ar' ? 'جاهز للتسليم' : 'Mark Ready'}</span>
                  </button>
                )}
                {ticket.status === 'ready' && (
                  <button
                    className="btn-kds btn-complete"
                    onClick={() => updateStatus(ticket.id, 'completed')}
                  >
                    <CheckCircle2 size={16} />
                    <span>{locale === 'ar' ? 'تم التسليم' : 'Complete'}</span>
                  </button>
                )}
              </div>
            </div>
          );
        })}

        {filteredTickets.length === 0 && (
          <div className="empty-kds">
            <CheckCircle2 size={48} className="text-success" />
            <h3>{locale === 'ar' ? 'جميع الطلبات مكتملة!' : 'All orders completed!'}</h3>
            <p>{locale === 'ar' ? 'لا توجد تذاكر معلقة في هذه المحطة حالياً.' : 'No pending tickets in this station right now.'}</p>
          </div>
        )}
      </div>
    </div>
  );
}
