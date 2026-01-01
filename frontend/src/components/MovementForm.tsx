import { useState, useEffect } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { movementsApi, itemsApi } from '../api/api';
import { MovementType, type CreateMovementRequest } from '../api/types';

export function MovementForm() {
    const [formData, setFormData] = useState<CreateMovementRequest>({
        item_id: 0,
        quantity: '',
        movement_type: MovementType.IN,
    });
    const [error, setError] = useState<string | null>(null);

    const queryClient = useQueryClient();

    // Fetch items for dropdown
    const { data: items } = useQuery({
        queryKey: ['items'],
        queryFn: itemsApi.getAll,
    });

    // Auto-select first item if available
    useEffect(() => {
        if (items && items.length > 0 && formData.item_id === 0) {
            setFormData((prev) => ({ ...prev, item_id: items[0].id }));
        }
    }, [items, formData.item_id]);

    const createMutation = useMutation({
        mutationFn: movementsApi.create,
        onSuccess: () => {
            // Invalidate both items and movements queries
            queryClient.invalidateQueries({ queryKey: ['items'] });
            queryClient.invalidateQueries({ queryKey: ['movements'] });

            // Reset quantity but keep item and type selected
            setFormData((prev) => ({ ...prev, quantity: '' }));
            setError(null);

            alert('Movement recorded successfully!');
        },
        onError: (err: any) => {
            console.error('Error recording movement:', err);

            // Handle specific error codes
            if (err.code === 'insufficient_stock') {
                setError('❌ ' + err.message);
            } else if (err.details) {
                const errorMessages = Object.entries(err.details)
                    .map(([field, messages]) => `${field}: ${(messages as string[]).join(', ')}`)
                    .join('\n');
                setError(errorMessages);
            } else {
                setError(err.message || 'Failed to record movement');
            }
        },
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);

        // Client-side validation
        if (formData.item_id === 0) {
            setError('Please select an item');
            return;
        }

        const quantity = parseFloat(formData.quantity.toString());
        if (isNaN(quantity) || quantity <= 0) {
            setError('Quantity must be a positive number');
            return;
        }

        createMutation.mutate({
            ...formData,
            quantity,
        });
    };

    const selectedItem = items?.find((item) => item.id === formData.item_id);

    return (
        <div className="movement-form">
            <h2>Record Inventory Movement</h2>

            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="item">Item *</label>
                    <select
                        id="item"
                        value={formData.item_id}
                        onChange={(e) => setFormData({ ...formData, item_id: parseInt(e.target.value) })}
                        disabled={createMutation.isPending || !items || items.length === 0}
                    >
                        {!items || items.length === 0 ? (
                            <option value={0}>No items available</option>
                        ) : (
                            items.map((item) => (
                                <option key={item.id} value={item.id}>
                                    {item.name} ({item.sku}) - Stock: {parseFloat(item.current_stock).toFixed(2)} {item.unit}
                                </option>
                            ))
                        )}
                    </select>
                </div>

                <div className="form-group">
                    <label htmlFor="movement_type">Movement Type *</label>
                    <select
                        id="movement_type"
                        value={formData.movement_type}
                        onChange={(e) => setFormData({ ...formData, movement_type: e.target.value as MovementType })}
                        disabled={createMutation.isPending}
                    >
                        <option value={MovementType.IN}>IN - Add to stock</option>
                        <option value={MovementType.OUT}>OUT - Remove from stock</option>
                        <option value={MovementType.ADJUSTMENT}>ADJUSTMENT - Adjust stock</option>
                    </select>
                </div>

                <div className="form-group">
                    <label htmlFor="quantity">Quantity *</label>
                    <input
                        id="quantity"
                        type="number"
                        step="0.01"
                        min="0.01"
                        value={formData.quantity}
                        onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                        placeholder="e.g., 100"
                        disabled={createMutation.isPending}
                    />
                    {selectedItem && (
                        <small>
                            Current stock: <strong>{parseFloat(selectedItem.current_stock).toFixed(2)}</strong> {selectedItem.unit}
                        </small>
                    )}
                </div>

                {error && (
                    <div className="error-message">
                        {error.split('\n').map((line, i) => (
                            <div key={i}>{line}</div>
                        ))}
                    </div>
                )}

                <button
                    type="submit"
                    className="btn-primary"
                    disabled={createMutation.isPending || !items || items.length === 0}
                >
                    {createMutation.isPending ? 'Recording...' : 'Record Movement'}
                </button>
            </form>
        </div>
    );
}
