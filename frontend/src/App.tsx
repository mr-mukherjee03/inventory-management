import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ErrorBoundary } from './components/ErrorBoundary';
import { ItemList } from './components/ItemList';
import { ItemForm } from './components/ItemForm';
import { MovementForm } from './components/MovementForm';
import './index.css';

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            refetchOnWindowFocus: false,
            retry: 1,
            staleTime: 5000,
        },
    },
});

function App() {
    return (
        <QueryClientProvider client={queryClient}>
            <ErrorBoundary>
                <div className="app">
                    <header className="app-header">
                        <h1>Inventory Management System</h1>
                        <p>Simple inventory tracking with stock management</p>
                    </header>

                    <main className="app-main">
                        <div className="forms-section">
                            <ItemForm />
                            <MovementForm />
                        </div>

                        <div className="list-section">
                            <ItemList />
                        </div>
                    </main>

                    <footer className="app-footer">
                        <p>Built with React + TypeScript + Elixir/Phoenix</p>
                    </footer>
                </div>
            </ErrorBoundary>
        </QueryClientProvider>
    );
}

export default App;
