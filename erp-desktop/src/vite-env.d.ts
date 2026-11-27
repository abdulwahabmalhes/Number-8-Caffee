/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_ERP_API_BASE_URL?: string;
  readonly VITE_ERP_DEMO_MODE?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
