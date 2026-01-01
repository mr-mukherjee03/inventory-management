
export enum Unit {
    PCS = 'pcs',
    KG = 'kg',
    LITRE = 'litre',
}

export enum MovementType {
    IN = 'IN',
    OUT = 'OUT',
    ADJUSTMENT = 'ADJUSTMENT',
}

export interface Item {
    id: number;
    name: string;
    sku: string;
    unit: Unit;
    current_stock: string;
    inserted_at: string;
    updated_at: string;
}

export interface Movement {
    id: number;
    item_id: number;
    quantity: string; // Decimal as string
    movement_type: MovementType;
    created_at: string;
    item?: {
        id: number;
        name: string;
        sku: string;
        unit: Unit;
    };
}

export interface CreateItemRequest {
    name: string;
    sku: string;
    unit: Unit;
}

export interface CreateMovementRequest {
    item_id: number;
    quantity: number | string;
    movement_type: MovementType;
}

export interface ApiResponse<T> {
    data: T;
}

export interface ApiError {
    error: {
        code: string;
        message: string;
        details?: Record<string, string[]>;
    };
}
