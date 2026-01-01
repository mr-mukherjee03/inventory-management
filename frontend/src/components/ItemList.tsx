import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { itemsApi } from '../api/api';

export function ItemList() {
    const [expandedItemId, setExpandedItemId] = useState<number | null>(null);

    const { data: items, isLoading, error } = useQuery({
        queryKey: ['items'],
        queryFn: itemsApi.getAll,
    });

    if (isLoading) {
        return <div className="loading">Loading items...</div>;
    }

    if (error) {
        return <div className="error">Error loading items: {(error as Error).message}</div>;
    }

    return (
        <div className="item-list">
            <h2>Inventory Items</h2>

            {items && items.length === 0 ? (
                <p className="empty-state">No items yet. Create one to get started!</p>
            ) : (
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>SKU</th>
                            <th>Unit</th>
                            <th>Current Stock</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items?.map((item) => (
                            <tr key={item.id} className={expandedItemId === item.id ? 'selected' : ''}>
                                <td>{item.id}</td>
                                <td>{item.name}</td>
                                <td><code>{item.sku}</code></td>
                                <td>{item.unit}</td>
                                <td className="stock">
                                    <strong>{parseFloat(item.current_stock).toFixed(2)}</strong>
                                </td>
                                <td>
                                    <button
                                        onClick={() => setExpandedItemId(item.id === expandedItemId ? null : item.id)}
                                        className="btn-secondary"
                                    >
                                        {expandedItemId === item.id ? 'Hide' : 'View'} History
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}

            {expandedItemId && (
                <ItemDetail itemId={expandedItemId} onClose={() => setExpandedItemId(null)} />
            )}
        </div>
    );
}

function ItemDetail({ itemId, onClose }: { itemId: number; onClose: () => void }) {
    const { data: movements, isLoading, error } = useQuery({
        queryKey: ['movements', itemId],
        queryFn: () => itemsApi.getById(itemId).then(async () => {
            const { movementsApi } = await import('../api/api');
            return movementsApi.getByItemId(itemId);
        }),
    });

    return (
        <div className="item-detail">
            <div className="detail-header">
                <h3>Movement History</h3>
                <button onClick={onClose} className="btn-close">×</button>
            </div>

            {isLoading && <p>Loading movements...</p>}
            {error && <p className="error">Error: {(error as Error).message}</p>}

            {movements && movements.length === 0 && (
                <p className="empty-state">No movements recorded yet.</p>
            )}

            {movements && movements.length > 0 && (
                <table className="movements-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Quantity</th>
                        </tr>
                    </thead>
                    <tbody>
                        {movements.map((movement) => (
                            <tr key={movement.id}>
                                <td>{new Date(movement.created_at).toLocaleString()}</td>
                                <td>
                                    <span className={`badge badge-${movement.movement_type.toLowerCase()}`}>
                                        {movement.movement_type}
                                    </span>
                                </td>
                                <td>{parseFloat(movement.quantity).toFixed(2)}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}
