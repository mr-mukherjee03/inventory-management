import axios, { AxiosError } from 'axios';
import type {
    Item,
    Movement,
    CreateItemRequest,
    CreateMovementRequest,
    ApiResponse,
    ApiError,
} from './types';


const api = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 10000,
});


api.interceptors.request.use(
    (config) => {
        console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`, config.data);
        return config;
    },
    (error) => {
        console.error('[API Request Error]', error);
        return Promise.reject(error);
    }
);

api.interceptors.response.use(
    (response) => {
        console.log(`[API Response] ${response.config.url}`, response.data);
        return response;
    },
    (error: AxiosError<ApiError>) => {
        console.error('[API Response Error]', error.response?.data || error.message);

        const errorMessage = error.response?.data?.error?.message || 'An unexpected error occurred';

        const enhancedError = new Error(errorMessage) as Error & { details?: unknown; code?: string };
        enhancedError.details = error.response?.data?.error?.details;
        enhancedError.code = error.response?.data?.error?.code;
        return Promise.reject(enhancedError);
    }
);

/**
 * Item API methods
 */
export const itemsApi = {
    /**
     * Get all items with their current stock
     */
    getAll: async (): Promise<Item[]> => {
        const response = await api.get<ApiResponse<Item[]>>('/items');
        return response.data.data;
    },

    /**
     * Get a single item by ID
     */
    getById: async (id: number): Promise<Item> => {
        const response = await api.get<ApiResponse<Item>>(`/items/${id}`);
        return response.data.data;
    },

    /**
     * Create a new item
     */
    create: async (data: CreateItemRequest): Promise<Item> => {
        const response = await api.post<ApiResponse<Item>>('/items', data);
        return response.data.data;
    },
};

/**
 * Movement API methods
 */
export const movementsApi = {
    /**
     * Get all movements
     */
    getAll: async (): Promise<Movement[]> => {
        const response = await api.get<ApiResponse<Movement[]>>('/movements');
        return response.data.data;
    },

    /**
     * Get movements for a specific item
     */
    getByItemId: async (itemId: number): Promise<Movement[]> => {
        const response = await api.get<ApiResponse<Movement[]>>(`/items/${itemId}/movements`);
        return response.data.data;
    },

    /**
     * Record a new movement
     */
    create: async (data: CreateMovementRequest): Promise<Movement> => {
        const response = await api.post<ApiResponse<Movement>>('/movements', data);
        return response.data.data;
    },
};

export default api;
