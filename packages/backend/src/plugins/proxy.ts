import { createRouter } from '@backstage/plugin-proxy-backend';
import { CreatePluginRouterFn } from '../types';

export const proxy: CreatePluginRouterFn = async ({
  logger,
  config,
  discovery,
}) => await createRouter({ logger, config, discovery });
