# Inventory Management System - Frontend

React + TypeScript frontend with clean component architecture, type safety, and proper error handling.

## Architecture

```
src/
├── api/
│   ├── types.ts          # TypeScript type definitions
│   └── api.ts            # API client with axios
├── components/
│   ├── ItemList.tsx      # Display items with stock
│   ├── ItemForm.tsx      # Create new items
│   ├── MovementForm.tsx  # Record movements
│   └── ErrorBoundary.tsx # Error handling
├── App.tsx               # Main application
├── main.tsx              # Entry point
└── index.css             # Styles
```

## Setup Instructions

### Prerequisites
- Node.js 18+ and npm

### Installation

1. **Install dependencies:**
   ```bash
   cd frontend
   npm install
   ```

2. **Start development server:**
   ```bash
   npm run dev
   ```
   
   Frontend will start on http://localhost:5173

3. **Build for production:**
   ```bash
   npm run build
   ```

## Features

- List all items with current stock
- Create new items with validation
- Record inventory movements (IN/OUT/ADJUSTMENT)
- View movement history for each item
- Real-time stock updates
- Error handling for insufficient stock
- Loading states and error messages
- Responsive design

## Technology Stack

- **React 18**: UI library
- **TypeScript**: Type safety
- **Vite**: Build tool and dev server
- **React Query**: Server state management
- **Axios**: HTTP client
- **CSS**: Styling (no framework, as per requirements)

## API Integration

The frontend communicates with the backend via proxy configuration in `vite.config.ts`:

```typescript
proxy: {
  '/api': {
    target: 'http://localhost:4000',
    changeOrigin: true,
  },
}
```

All API calls are made through the `api.ts` client with:
- Request/response logging
- Error handling and transformation
- Type-safe methods

## Development

### Linting
```bash
npm run lint
```

### Preview production build
```bash
npm run preview
```

## Component Overview

### ItemList
- Fetches and displays all items
- Shows current stock for each item
- Expandable movement history
- Uses React Query for data fetching

### ItemForm
- Creates new items
- Client and server-side validation
- Error display for validation failures
- Optimistic UI updates

### MovementForm
- Records inventory movements
- Dropdown for item selection
- Shows current stock
- Prevents negative stock with clear error messages
- Supports IN, OUT, and ADJUSTMENT types

### ErrorBoundary
- Catches React errors
- Displays user-friendly error message
- Provides reload option

## Design Decisions

1. **React Query**: Automatic caching, refetching, and state management
2. **TypeScript**: Full type safety matching backend API
3. **No UI Framework**: Clean, simple CSS as per requirements
4. **Error Handling**: Multi-layer (client validation, API errors, React errors)
5. **Responsive Design**: Works on desktop and mobile
6. **Optimistic Updates**: Immediate UI feedback

## Responsive Breakpoints

- Desktop: > 968px (side-by-side layout)
- Tablet: 640px - 968px (stacked layout)
- Mobile: < 640px (compact layout)

## Troubleshooting

**API connection error:**
- Ensure backend is running on port 4000
- Check proxy configuration in `vite.config.ts`

**Build errors:**
```bash
rm -rf node_modules package-lock.json
npm install
```

## Future Enhancements

- [ ] Pagination for large item lists
- [ ] Search and filter functionality
- [ ] Export data to CSV
- [ ] Charts and analytics
- [ ] Dark mode
- [ ] Keyboard shortcuts
- [ ] Accessibility improvements (ARIA labels)
