import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { itemsApi } from '../api/api';
import { Unit, type CreateItemRequest } from '../api/types';

export function ItemForm() {
    const [formData, setFormData] = useState<CreateItemRequest>({
        name: '',
        sku: '',
        unit: Unit.PCS,
    });
    const [error, setError] = useState<string | null>(null);

    const queryClient = useQueryClient();

    const createMutation = useMutation({
        mutationFn: itemsApi.create,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['items'] });
            setFormData({ name: '', sku: '', unit: Unit.PCS });
            setError(null);

            alert('Item created successfully.');
        },
        onError: (err: Error & { details?: Record<string, string[]> }) => {
            console.error('Error creating item:', err);
            if (err.details) {
                const errorMessages = Object.entries(err.details)
                    .map(([field, messages]) => `${field}: ${messages.join(', ')}`)
                    .join('\n');
                setError(errorMessages);
            } else {
                setError(err.message || 'Failed to create item');
            }
        },
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);

        if (!formData.name.trim()) {
            setError('Name is required');
            return;
        }
        if (!formData.sku.trim()) {
            setError('SKU is required');
            return;
        }

        createMutation.mutate(formData);
    };

    return (
        <div className="item-form">
            <h2>Create New Item</h2>

            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="name">Name *</label>
                    <input
                        id="name"
                        type="text"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        placeholder="e.g., Widget A"
                        disabled={createMutation.isPending}
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="sku">SKU *</label>
                    <input
                        id="sku"
                        type="text"
                        value={formData.sku}
                        onChange={(e) => setFormData({ ...formData, sku: e.target.value.toUpperCase() })}
                        placeholder="e.g., WGT-001"
                        disabled={createMutation.isPending}
                    />
                    <small>Letters, numbers, hyphens, and underscores only</small>
                </div>

                <div className="form-group">
                    <label htmlFor="unit">Unit *</label>
                    <select
                        id="unit"
                        value={formData.unit}
                        onChange={(e) => setFormData({ ...formData, unit: e.target.value as Unit })}
                        disabled={createMutation.isPending}
                    >
                        <option value={Unit.PCS}>Pieces (pcs)</option>
                        <option value={Unit.KG}>Kilograms (kg)</option>
                        <option value={Unit.LITRE}>Litres (litre)</option>
                    </select>
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
                    disabled={createMutation.isPending}
                >
                    {createMutation.isPending ? 'Creating...' : 'Create Item'}
                </button>
            </form>
        </div>
    );
}
