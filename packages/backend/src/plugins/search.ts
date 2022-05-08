import { useHotCleanup } from '@backstage/backend-common';
import { DefaultCatalogCollatorFactory } from '@backstage/plugin-catalog-backend';
import { createRouter } from '@backstage/plugin-search-backend';
import {
  IndexBuilder,
  LunrSearchEngine,
} from '@backstage/plugin-search-backend-node';
import { DefaultTechDocsCollatorFactory } from '@backstage/plugin-techdocs-backend';
import { Duration } from 'luxon';
import { CreatePluginRouterFn } from '../types';

export const search: CreatePluginRouterFn = async ({
  logger,
  permissions,
  discovery,
  config,
  tokenManager,
  scheduler,
}) => {
  // Initialize a connection to a search engine.
  const searchEngine = new LunrSearchEngine({ logger });
  const indexBuilder = new IndexBuilder({ logger, searchEngine });

  // Creating the scheduler task to build the index.
  const schedule = scheduler.createScheduledTaskRunner({
    frequency: Duration.fromObject({ seconds: 600 }),
    timeout: Duration.fromObject({ seconds: 900 }),
    initialDelay: Duration.fromObject({ seconds: 3 }),
  });

  // Collators are responsible for gathering documents known to plugins. This
  // collator gathers entities from the software catalog.
  indexBuilder.addCollator({
    schedule,
    factory: DefaultCatalogCollatorFactory.fromConfig(config, {
      discovery,
      tokenManager,
    }),
  });

  // collator gathers entities from techdocs.
  indexBuilder.addCollator({
    schedule,
    factory: DefaultTechDocsCollatorFactory.fromConfig(config, {
      discovery,
      logger,
      tokenManager,
    }),
  });

  const builder = await indexBuilder.build();
  builder.scheduler.start();
  useHotCleanup(module, () => builder.scheduler.stop());

  return await createRouter({
    engine: indexBuilder.getSearchEngine(),
    types: indexBuilder.getDocumentTypes(),
    permissions,
    config,
    logger,
  });
};
