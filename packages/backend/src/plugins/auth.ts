import {
  DEFAULT_NAMESPACE,
  stringifyEntityRef,
} from '@backstage/catalog-model';
import {
  createRouter,
  providers,
  defaultAuthProviderFactories,
} from '@backstage/plugin-auth-backend';
import { CreatePluginRouterFn } from '../types';

const onelogin = providers.onelogin.create({
  signIn: {
    async resolver(result, ctx) {
      const entityRef = stringifyEntityRef({
        namespace: DEFAULT_NAMESPACE,
        kind: 'user',
        name: result.profile.email || '',
      });
      return ctx.issueToken({
        claims: {
          sub: entityRef,
          ent: [entityRef],
        },
      });
    },
  },
});

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
    providerFactories: {
      ...defaultAuthProviderFactories,
      onelogin,
    },
  });
