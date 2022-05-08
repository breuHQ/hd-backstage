import { createRouter } from '@backstage/plugin-auth-backend';
import { CreatePluginRouterFn } from '../types';

export const auth: CreatePluginRouterFn = async ({
  logger,
  config,
  database,
  discovery,
  tokenManager,
}) =>
  await createRouter({
    logger,
    config,
    database,
    discovery,
    tokenManager,
  });
