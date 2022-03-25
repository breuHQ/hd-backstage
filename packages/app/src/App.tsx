import { createApp } from '@backstage/app-defaults';
import {
  AppComponents,
  AppRouteBinder,
  FlatRoutes,
} from '@backstage/core-app-api';
import {
  AlertDisplay,
  OAuthRequestDialog,
  SignInPage,
  SignInProviderConfig,
} from '@backstage/core-components';
import { oneloginAuthApiRef } from '@backstage/core-plugin-api';
import { apiDocsPlugin, ApiExplorerPage } from '@backstage/plugin-api-docs';
import {
  CatalogEntityPage,
  CatalogIndexPage,
  catalogPlugin,
} from '@backstage/plugin-catalog';
import { catalogEntityCreatePermission } from '@backstage/plugin-catalog-common/alpha';
import { CatalogGraphPage } from '@backstage/plugin-catalog-graph';
import {
  CatalogImportPage,
  catalogImportPlugin,
} from '@backstage/plugin-catalog-import';
import { orgPlugin } from '@backstage/plugin-org';
import { PermissionedRoute } from '@backstage/plugin-permission-react';
import { ScaffolderPage, scaffolderPlugin } from '@backstage/plugin-scaffolder';
import { SearchPage } from '@backstage/plugin-search';
import { TechRadarPage } from '@backstage/plugin-tech-radar';
import {
  TechDocsIndexPage,
  techdocsPlugin,
  TechDocsReaderPage,
} from '@backstage/plugin-techdocs';
import { UserSettingsPage } from '@backstage/plugin-user-settings';
import React from 'react';
import { Navigate, Route } from 'react-router';
import { apis } from './apis';
import { entityPage } from './components/catalog/EntityPage';
import { Root } from './components/root';
import { searchPage } from './components/search/SearchPage';

/**
 * Configures Onelogin authentication.
 */
const oneloginProver: SignInProviderConfig = {
  id: 'onelogin-auth-provider',
  title: 'OneLogin',
  message: 'Signin Using OneLogin',
  apiRef: oneloginAuthApiRef,
};

/**
 * Update components to be included in the app.
 */
const components: Partial<AppComponents> = {
  SignInPage: props => <SignInPage {...props} auto provider={oneloginProver} />,
};

/**
 * Configures the routes for the app.
 */
const bindRoutes: (context: { bind: AppRouteBinder }) => void = ({ bind }) => {
  bind(catalogPlugin.externalRoutes, {
    createComponent: scaffolderPlugin.routes.root,
    viewTechDoc: techdocsPlugin.routes.docRoot,
  });
  bind(apiDocsPlugin.externalRoutes, {
    registerApi: catalogImportPlugin.routes.importPage,
  });
  bind(scaffolderPlugin.externalRoutes, {
    registerComponent: catalogImportPlugin.routes.importPage,
  });
  bind(orgPlugin.externalRoutes, {
    catalogIndex: catalogPlugin.routes.catalogIndex,
  });
};

/**
 * Create the app configuration signleton
 */
const app = createApp({
  apis,
  components,
  bindRoutes,
});

const AppProvider = app.getProvider();
const AppRouter = app.getRouter();

/**
 * Populate the app routing component
 */
const routes = (
  <FlatRoutes>
    <Navigate key="/" to="catalog" />
    <Route path="/catalog" element={<CatalogIndexPage />} />
    <Route
      path="/catalog/:namespace/:kind/:name"
      element={<CatalogEntityPage />}
    >
      {entityPage}
    </Route>
    <Route path="/docs" element={<TechDocsIndexPage />} />
    <Route
      path="/docs/:namespace/:kind/:name/*"
      element={<TechDocsReaderPage />}
    />
    <Route path="/create" element={<ScaffolderPage />} />
    <Route path="/api-docs" element={<ApiExplorerPage />} />
    <Route
      path="/tech-radar"
      element={<TechRadarPage width={1500} height={800} />}
    />
    <PermissionedRoute
      path="/catalog-import"
      permission={catalogEntityCreatePermission}
      element={<CatalogImportPage />}
    />
    <Route path="/search" element={<SearchPage />}>
      {searchPage}
    </Route>
    <Route path="/settings" element={<UserSettingsPage />} />
    <Route path="/catalog-graph" element={<CatalogGraphPage />} />
  </FlatRoutes>
);

/**
 * Render the app
 */
const App = () => (
  <AppProvider>
    <AlertDisplay />
    <OAuthRequestDialog />
    <AppRouter>
      <Root>{routes}</Root>
    </AppRouter>
  </AppProvider>
);

export default App;
