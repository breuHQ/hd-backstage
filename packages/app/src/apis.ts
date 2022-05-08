import { Config } from '@backstage/config';
import {
  AnyApiFactory,
  configApiRef,
  createApiFactory,
} from '@backstage/core-plugin-api';
import {
  ScmAuth,
  ScmIntegrationsApi,
  scmIntegrationsApiRef,
} from '@backstage/integration-react';
import {
  TechRadarApi,
  techRadarApiRef,
  TechRadarLoaderResponse,
} from '@backstage/plugin-tech-radar';

class TechRadarApiClient implements TechRadarApi {
  private _config: Config;

  constructor(config: Config) {
    this._config = config;
  }

  async load(id: string | undefined): Promise<TechRadarLoaderResponse> {
    const backendBaseUrl = this._config.getString('backend.baseUrl');
    const filename = id || 'data';
    const techRadarUrl = `${backendBaseUrl}/api/assets/techradar/${filename}.json`;
    const response = await fetch(techRadarUrl).then(res => res.json());
    return response;
  }
}

export const apis: AnyApiFactory[] = [
  createApiFactory({
    api: scmIntegrationsApiRef,
    deps: { configApi: configApiRef },
    factory: ({ configApi }) => ScmIntegrationsApi.fromConfig(configApi),
  }),
  createApiFactory({
    api: techRadarApiRef,
    deps: { configApi: configApiRef },
    factory: ({ configApi }) => new TechRadarApiClient(configApi),
  }),
  ScmAuth.createDefaultApiFactory(),
];
