import { CatalogBuilder } from '@backstage/plugin-catalog-backend';
import { GitLabDiscoveryProcessor } from '@backstage/plugin-catalog-backend-module-gitlab';
import { ScaffolderEntitiesProcessor } from '@backstage/plugin-scaffolder-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';

export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  const builder = await CatalogBuilder.create(env);
  builder.addProcessor(new ScaffolderEntitiesProcessor());
  builder.addProcessor(
    GitLabDiscoveryProcessor.fromConfig(env.config, { logger: env.logger }),
  );
  const { processingEngine, router } = await builder.build();
  await processingEngine.start();
  return router;
}
