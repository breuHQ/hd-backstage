import { CatalogClient } from '@backstage/catalog-client';
import { createRouter } from '@backstage/plugin-scaffolder-backend';
import type { CreatePluginRouterFn } from '../types';

export const scaffolder: CreatePluginRouterFn = async env => {
  const catalogClient = new CatalogClient({
    discoveryApi: env.discovery,
  });
  return await createRouter({
    logger: env.logger,
    config: env.config,
    database: env.database,
    reader: env.reader,
    catalogClient,
  });
};
