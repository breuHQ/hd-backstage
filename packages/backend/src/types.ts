import { Logger } from 'winston';
import { Config } from '@backstage/config';
import {
  PluginCacheManager,
  PluginDatabaseManager,
  PluginEndpointDiscovery,
  TokenManager,
  UrlReader,
} from '@backstage/backend-common';
import { PluginTaskScheduler } from '@backstage/backend-tasks';
import { PermissionEvaluator } from '@backstage/plugin-permission-common';
import { Router } from 'express';

export type PluginEnvironment = {
  logger: Logger;
  database: PluginDatabaseManager;
  cache: PluginCacheManager;
  config: Config;
  reader: UrlReader;
  discovery: PluginEndpointDiscovery;
  tokenManager: TokenManager;
  scheduler: PluginTaskScheduler;
  permissions: PermissionEvaluator;
};

export type CreatePluginRouterFn = (env: PluginEnvironment) => Promise<Router>;
