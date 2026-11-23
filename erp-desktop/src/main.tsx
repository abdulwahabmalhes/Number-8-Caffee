import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';
import { AuthProvider } from './app/auth';
import { ErrorBoundary } from './app/ErrorBoundary';
import { router } from './app/router';
import { I18nProvider } from './i18n/I18nProvider';
import './styles/index.css';

createRoot(document.getElementById('root')!).render(<StrictMode><ErrorBoundary><AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider></ErrorBoundary></StrictMode>);
