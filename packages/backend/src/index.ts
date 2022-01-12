/*
 * Hi!
 *
 * Note that this is an EXAMPLE Backstage backend. Please check the README.
 *
 * Happy hacking!
 */

import Router from 'express-promise-router';
import {
  createServiceBuilder,
  loadBackendConfig,
  getRootLogger,
  useHotMemoize,
  notFoundHandler,
  CacheManager,
  DatabaseManager,
  SingleHostDiscovery,
  UrlReaders,
  ServerTokenManager,
} from '@backstage/backend-common';
import { Config } from '@backstage/config';
// import app from './plugins/app';
import auth from './plugins/auth';
import healthcheck from './plugins/healthcheck';
import catalog from './plugins/catalog';
import scaffolder from './plugins/scaffolder';
import proxy from './plugins/proxy';
import techdocs from './plugins/techdocs';
import search from './plugins/search';
import { PluginEnvironment } from './types';

function makeCreateEnv(config: Config) {
  const root = getRootLogger();
  const reader = UrlReaders.default({ logger: root, config });
  const discovery = SingleHostDiscovery.fromConfig(config);

  root.info(`Created UrlReader ${reader}`);

  const cacheManager = CacheManager.fromConfig(config);
  const databaseManager = DatabaseManager.fromConfig(config);
  const tokenManager = ServerTokenManager.noop();

  return (plugin: string): PluginEnvironment => {
    const logger = root.child({ type: 'plugin', plugin });
    const database = databaseManager.forPlugin(plugin);
    const cache = cacheManager.forPlugin(plugin);
    return { logger, database, cache, config, reader, discovery, tokenManager };
  };
}

async function main() {
  const config = await loadBackendConfig({
    argv: process.argv,
    logger: getRootLogger(),
  });
  const createEnv = makeCreateEnv(config);

  const authEnv = useHotMemoize(module, () => createEnv('auth'));
  const catalogEnv = useHotMemoize(module, () => createEnv('catalog'));
  const healthcheckEnv = useHotMemoize(module, () => createEnv('healthcheck'));
  const proxyEnv = useHotMemoize(module, () => createEnv('proxy'));
  const scaffolderEnv = useHotMemoize(module, () => createEnv('scaffolder'));
  const searchEnv = useHotMemoize(module, () => createEnv('search'));
  const techdocsEnv = useHotMemoize(module, () => createEnv('techdocs'));

  const apiRouter = Router();
  apiRouter.use('/auth', await auth(authEnv));
  apiRouter.use('/catalog', await catalog(catalogEnv));
  apiRouter.use('/proxy', await proxy(proxyEnv));
  apiRouter.use('/scaffolder', await scaffolder(scaffolderEnv));
  apiRouter.use('/search', await search(searchEnv));
  apiRouter.use('/techdocs', await techdocs(techdocsEnv));
  apiRouter.use(notFoundHandler());

  const service = createServiceBuilder(module)
    .loadConfig(config)
    .addRouter('', await healthcheck(healthcheckEnv))
    .addRouter('/api', apiRouter);
  // .addRouter('', await app(appEnv));

  await service.start().catch(err => {
    console.log(err);
    process.exit(1);
  });
}

module.hot?.accept();
main().catch(error => {
  console.error(`Backend failed to start up, ${error}`);
  process.exit(1);
});